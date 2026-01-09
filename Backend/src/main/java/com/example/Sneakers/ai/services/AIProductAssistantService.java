package com.example.Sneakers.ai.services;

import com.example.Sneakers.models.Product;
import com.example.Sneakers.repositories.ProductRepository;
import dev.langchain4j.data.document.Document;
import dev.langchain4j.data.message.UserMessage;
import dev.langchain4j.model.chat.ChatModel;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Base64;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class AIProductAssistantService {

    private final ChatModel geminiChatModel;
    private final VectorSearchService vectorSearchService;
    private final ProductRepository productRepository;

    public String answerProductQuery(String userQuery) {
        log.info("Processing product query: {}", userQuery);

        // Basic Intent Classification
        String lowerQuery = userQuery.toLowerCase();
        
        // 1. Warranty Check
        // Keywords: bao hanh, chinh sach (policy)
        if (lowerQuery.contains("bảo hành") || lowerQuery.contains("bao hanh") || 
            (lowerQuery.contains("chính sách") && (lowerQuery.contains("đổi trả") || lowerQuery.contains("hoàn tiền")))) {
             log.info("Detected WARRANTY intent");
             return provideWarrantyAdvice(userQuery);
        }
        
        // 2. Diagnostic/Support Check
        // Keywords: lỗi, hư, không mở, kẹt, sửa, help
        if (lowerQuery.contains("lỗi") || lowerQuery.contains("hỏng") || lowerQuery.contains("không mở") || 
            lowerQuery.contains("kẹt") || lowerQuery.contains("sửa khóa") || lowerQuery.contains("hết pin")) {
            log.info("Detected DIAGNOSTIC intent");
            return diagnoseLockIssue(userQuery);
        }

        // Search for relevant products using vector search
        // Tăng số lượng sản phẩm tìm kiếm lên 20 để hỗ trợ tốt hơn cho các câu hỏi so sánh/lọc (như rẻ nhất, đắt nhất)
        List<Document> relevantDocuments = vectorSearchService.searchProducts(userQuery, 20);

        // Fallback: Nếu vector search không tìm thấy, thử tìm kiếm exact/partial match trong database
        if (relevantDocuments.isEmpty()) {
            log.info("Vector search returned no results, trying exact/partial match fallback");
            relevantDocuments = searchProductsByExactMatch(userQuery);
        }

        // Extract product information from documents
        String productContext = buildProductContext(relevantDocuments);

        // Create enhanced prompt with product context
        String enhancedPrompt = createEnhancedPrompt(userQuery, productContext);

        // Get response from Gemini
        var response = geminiChatModel.chat(UserMessage.from(enhancedPrompt));

        return response.aiMessage().text();
    }
    
    /**
     * Fallback search: Tìm kiếm sản phẩm bằng exact/partial match trong database
     * Đặc biệt hữu ích cho tên model ngắn như "F300-FH"
     */
    private List<Document> searchProductsByExactMatch(String query) {
        try {
            // Tìm kiếm sản phẩm có tên chứa query (case-insensitive)
            List<Product> products = productRepository.getProductsByKeyword(query);
            
            if (products.isEmpty()) {
                log.debug("No products found with keyword: {}", query);
                return List.of();
            }
            
            // Chuyển đổi Product thành Document để tương thích với logic hiện tại
            List<Document> documents = new ArrayList<>();
            for (Product product : products) {
                // Tạo metadata tương tự như khi index
                Map<String, Object> metadata = new java.util.HashMap<>();
                metadata.put("product_id", product.getId());
                metadata.put("product_name", product.getName());
                metadata.put("category_name", product.getCategory() != null ? product.getCategory().getName() : "");
                metadata.put("category_id", product.getCategory() != null ? product.getCategory().getId() : null);
                metadata.put("price", product.getPrice());
                metadata.put("discount", product.getDiscount() != null ? product.getDiscount() : 0);
                metadata.put("thumbnail", product.getThumbnail());
                metadata.put("type", "product");
                
                // Tạo description text tương tự như khi index
                String description = String.format(
                    "Product: %s\nDescription: %s\nCategory: %s\nPrice: %d VND\nDiscount: %d%%",
                    product.getName(),
                    product.getDescription() != null ? product.getDescription() : "",
                    product.getCategory() != null ? product.getCategory().getName() : "",
                    product.getPrice(),
                    product.getDiscount() != null ? product.getDiscount() : 0
                );
                
                Document doc = Document.from(description, dev.langchain4j.data.document.Metadata.from(metadata));
                documents.add(doc);
            }
            
            log.info("Found {} products using exact/partial match for query: {}", documents.size(), query);
            return documents;
        } catch (Exception e) {
            log.error("Error in fallback exact match search", e);
            return List.of();
        }
    }

    public String answerProductQueryWithImage(String base64Image, String mimeType, String userPrompt) {
        log.info("Processing product query with image: {}", userPrompt);

        // Step 1: Image -> embedding (Python CLIP) -> cosine search in Chroma
        byte[] imageBytes = decodeBase64Image(base64Image);
        // Tìm 20 sản phẩm tương đồng, nhưng sẽ chỉ lấy 1 sản phẩm tốt nhất để context
        List<Document> relevantDocuments = vectorSearchService.searchByImage(imageBytes, 20);

        // Nếu không có sản phẩm nào phù hợp (do score thấp bị lọc)
        if (relevantDocuments.isEmpty()) {
            return "Xin lỗi, tôi không tìm thấy sản phẩm nào trong cửa hàng giống với hình ảnh bạn cung cấp. Bạn có thể thử hình ảnh khác rõ nét hơn hoặc mô tả sản phẩm cho tôi nhé!";
        }

        // Lấy score cao nhất từ kết quả
        double maxScore = 0.0;
        try {
            Object scoreObj = relevantDocuments.get(0).metadata().toMap().get("similarity_score");
            if (scoreObj != null) {
                maxScore = Double.parseDouble(scoreObj.toString());
            }
        } catch (Exception e) {
            log.warn("Failed to parse similarity score", e);
        }

        log.info("Max similarity score: {}", maxScore);

        // Build high-quality context from matched product ids
        String productContext = buildProductContextFromMatches(relevantDocuments);

        // Nếu độ tương đồng rất cao (> 0.96), trả lời khẳng định luôn
        if (maxScore > 0.96) {
            String finalPrompt = String.format("""
                Bạn là chuyên gia tư vấn khóa điện tử của Locker Korea.
                
                Khách hàng đã gửi hình ảnh sản phẩm. Hệ thống nhận diện CHÍNH XÁC (Độ tin cậy cao) sản phẩm là:
                %s
                
                Câu hỏi của khách hàng: "%s"
                
                Nhiệm vụ:
                1. Xác nhận ngay với khách hàng đây chính là sản phẩm trong ảnh.
                2. Tư vấn chi tiết tính năng, lợi ích dựa trên thông tin đã cung cấp.
                3. Giọng điệu chắc chắn, chuyên nghiệp.
                """, productContext, userPrompt);
            var finalResponse = geminiChatModel.chat(UserMessage.from(finalPrompt));
            return finalResponse.aiMessage().text();
        }

        // Nếu độ tương đồng khá (0.90 - 0.96), trả lời dè dặt hơn
        String confidenceNote = (maxScore >= 0.90) 
            ? "Tôi thấy sản phẩm này rất giống với hình ảnh bạn gửi, nhưng để chắc chắn, bạn hãy kiểm tra kỹ các chi tiết nhé."
            : "Dựa trên hình ảnh, đây là sản phẩm có kiểu dáng tương đồng nhất mà tôi tìm thấy.";

        String finalPrompt = String.format("""
                Bạn là chuyên gia tư vấn khóa điện tử của Locker Korea.
                
                Khách hàng gửi ảnh tìm sản phẩm. Hệ thống tìm thấy sản phẩm tương đồng:
                %s
                
                Câu hỏi của khách hàng: "%s"
                
                Lưu ý quan trọng về giá: Giá trong dữ liệu LÀ GIÁ ĐÃ GIẢM (nếu có), không cần tự tính toán lại.
                
                Nhiệm vụ:
                1. Bắt đầu bằng câu: "%s"
                2. Giới thiệu sản phẩm tìm được (Tên, Giá, Tính năng).
                3. Trả lời câu hỏi của khách hàng.
                4. Nếu khách hỏi giá, hãy dùng giá trong context.
                """, productContext, userPrompt, confidenceNote);

        var finalResponse = geminiChatModel.chat(UserMessage.from(finalPrompt));

        return finalResponse.aiMessage().text();
    }

    private byte[] decodeBase64Image(String base64Image) {
        if (base64Image == null || base64Image.trim().isEmpty()) {
            throw new IllegalArgumentException("base64Image is empty");
        }

        String normalized = base64Image.trim();
        // Handle data URL format: data:image/png;base64,....
        int commaIndex = normalized.indexOf(',');
        if (normalized.startsWith("data:") && commaIndex > 0) {
            normalized = normalized.substring(commaIndex + 1);
        }
        return Base64.getDecoder().decode(normalized);
    }

    private String buildProductContextFromMatches(List<Document> documents) {
        if (documents == null || documents.isEmpty()) {
            return "No similar products found in the database.";
        }

        List<Long> productIdsInOrder = new ArrayList<>();
        Map<Long, Double> scoreMap = new HashMap<>();

        for (Document doc : documents) {
            Map<String, Object> md = doc.metadata().toMap();
            Object productIdObj = md.get("product_id");
            Object scoreObj = md.get("similarity_score");
            
            Optional<Long> parsedId = parseLongSafe(productIdObj);
            parsedId.ifPresent(id -> {
                if (!productIdsInOrder.contains(id)) {
                    productIdsInOrder.add(id);
                }
                
                if (scoreObj != null) {
                    try {
                        scoreMap.put(id, Double.parseDouble(scoreObj.toString()));
                    } catch (NumberFormatException e) {
                        scoreMap.put(id, 0.0);
                    }
                }
            });
        }

        if (productIdsInOrder.isEmpty()) {
            // Fallback: at least return whatever is in documents
            return buildProductContext(documents);
        }

        // Limit to top 1 product id as requested
        List<Long> topProductId = productIdsInOrder.subList(0, 1);

        List<Product> products = productRepository.findAllById(topProductId);
        Map<Long, Product> byId = products.stream()
                .filter(p -> p.getId() != null)
                .collect(Collectors.toMap(Product::getId, p -> p, (a, b) -> a));

        StringBuilder context = new StringBuilder("Here is the most similar product from our database (image search):\n\n");
        // Only iterate over the top 1 product
        for (Long id : topProductId) {
            Product p = byId.get(id);
            if (p == null) continue;

            // Removed similarity score and confidence text as requested
            context.append(String.format("Product: %s\n", p.getName()));
            context.append(String.format("   Price: %d VND\n", p.getPrice()));
            context.append(String.format("   Category: %s\n", p.getCategory() != null ? p.getCategory().getName() : "Unknown"));
            context.append(String.format("   Discount: %d%%\n", p.getDiscount() != null ? p.getDiscount() : 0));
            context.append(String.format("   Description: %s\n\n", p.getDescription()));
        }

        return context.toString();
    }

    private Optional<Long> parseLongSafe(Object value) {
        if (value == null) return Optional.empty();
        try {
            String s = value.toString().trim();
            if (s.isEmpty()) return Optional.empty();
            return Optional.of(Long.parseLong(s));
        } catch (Exception ignored) {
            return Optional.empty();
        }
    }

    public String answerProductQueryByCategory(String userQuery, String category) {
        log.info("Processing product query in category {}: {}", category, userQuery);

        // Search for relevant products in specific category
        List<Document> relevantDocuments = vectorSearchService.searchProductsByCategory(userQuery, category, 10);

        String productContext = buildProductContext(relevantDocuments);
        String enhancedPrompt = createCategoryPrompt(userQuery, category, productContext);

        var response = geminiChatModel.chat(UserMessage.from(enhancedPrompt));

        return response.aiMessage().text();
    }

    public String answerProductQueryByPriceRange(String userQuery, Long minPrice, Long maxPrice) {
        log.info("Processing product query with price range {}-{}: {}", minPrice, maxPrice, userQuery);

        // Search for relevant products in price range
        List<Document> relevantDocuments = vectorSearchService.searchProductsByPriceRange(userQuery, minPrice, maxPrice,
                10);

        String productContext = buildProductContext(relevantDocuments);
        String enhancedPrompt = createPriceRangePrompt(userQuery, minPrice, maxPrice, productContext);

        var response = geminiChatModel.chat(UserMessage.from(enhancedPrompt));

        return response.aiMessage().text();
    }

    public String compareProducts(List<Long> productIds) {
        log.info("Comparing products: {}", productIds);

        // Fetch products from database
        List<Product> products = productRepository.findAllById(productIds);

        if (products.isEmpty()) {
            return "Sorry, I couldn't find the products you want to compare.";
        }

        String comparisonContext = buildComparisonContext(products);
        String prompt = createComparisonPrompt(comparisonContext);

        var response = geminiChatModel.chat(UserMessage.from(prompt));

        return response.aiMessage().text();
    }

    public String provideProductRecommendations(String userPreferences) {
        log.info("Generating recommendations based on: {}", userPreferences);

        // Search for products matching preferences
        List<Document> relevantDocuments = vectorSearchService.searchProducts(userPreferences, 10);

        String productContext = buildProductContext(relevantDocuments);
        String prompt = createRecommendationPrompt(userPreferences, productContext);

        var response = geminiChatModel.chat(UserMessage.from(prompt));

        return response.aiMessage().text();
    }

    private String buildProductContext(List<Document> documents) {
        if (documents.isEmpty()) {
            return "No specific products found in the database.";
        }

        StringBuilder context = new StringBuilder("Here are the relevant products from our database:\n\n");

        for (int i = 0; i < documents.size(); i++) {
            Document doc = documents.get(i);
            Map<String, Object> metadata = doc.metadata().toMap();

            context.append(String.format("%d. Product: %s\n", i + 1, metadata.get("product_name")));
            context.append(String.format("   Price: %s VND\n", metadata.get("price")));
            context.append(String.format("   Category: %s\n", metadata.get("category_name")));
            context.append(String.format("   Discount: %s%%\n", metadata.get("discount")));
            context.append(String.format("   Description: %s\n\n", doc.text()));
        }

        return context.toString();
    }

    private String buildComparisonContext(List<Product> products) {
        StringBuilder context = new StringBuilder("Products to compare:\n\n");

        for (Product product : products) {
            context.append(String.format("Product: %s\n", product.getName()));
            context.append(String.format("Price: %d VND\n", product.getPrice()));
            context.append(String.format("Category: %s\n",
                    product.getCategory() != null ? product.getCategory().getName() : "Unknown"));
            context.append(String.format("Discount: %d%%\n",
                    product.getDiscount() != null ? product.getDiscount() : 0));
            context.append(String.format("Description: %s\n\n", product.getDescription()));
        }

        return context.toString();
    }

    private String createEnhancedPrompt(String userQuery, String productContext) {
        return String.format("""
                Bạn là chuyên gia tư vấn khóa điện tử của Locker Korea.
                
                Dữ liệu sản phẩm thực tế từ kho hàng (CONTEXT):
                %s
                
                Câu hỏi của khách hàng: "%s"
                
                Nhiệm vụ: Trả lời câu hỏi dựa TRÊN DUY NHẤT dữ liệu trong CONTEXT ở trên.
                
                QUY TẮC BẮT BUỘC (CRITICAL):
                1. TRUNG THỰC TUYỆT ĐỐI: Chỉ tư vấn các sản phẩm có trong CONTEXT. 
                2. KHÔNG BỊA ĐẶT (NO HALLUCINATION): 
                   - Nếu khách hỏi về thương hiệu/sản phẩm KHÔNG CÓ trong CONTEXT (ví dụ khách hỏi "Gateman" nhưng CONTEXT chỉ có "Samsung"), bạn phải trả lời rõ: "Hiện tại cửa hàng CHƯA CÓ sản phẩm [Tên sản phẩm khách hỏi]".
                   - KHÔNG ĐƯỢC tự ý bịa ra sản phẩm, giá cả hay thông số không có trong dữ liệu.
                3. XỬ LÝ KHI KHÔNG TÌM THẤY:
                   - Bước 1: Xin lỗi vì chưa có đúng mẫu khách tìm.
                   - Bước 2: Dựa vào CONTEXT, gợi ý các sản phẩm THAY THẾ tương đương (cùng tầm giá, cùng tính năng) đang có sẵn.
                4. ĐỊNH DẠNG CÂU TRẢ LỜI:
                   - Tên sản phẩm chính xác như trong CONTEXT.
                   - Giá: Dùng trực tiếp giá trong CONTEXT (đây là giá đã giảm nếu có), KHÔNG tự tính toán lại. Format dạng X.XXX.XXX VND.
                   - Nêu bật 2-3 tính năng chính.
                
                Hãy trả lời ngắn gọn, chuyên nghiệp, và giúp khách hàng chọn được sản phẩm thay thế tốt nhất nếu cửa hàng không có đúng món họ cần.
                """, productContext, userQuery);
    }


    private String createCategoryPrompt(String userQuery, String category, String productContext) {
        return String.format("""
                Bạn là chuyên gia tư vấn khóa điện tử, khóa vân tay chuyên nghiệp.
                
                Câu hỏi của khách hàng về danh mục %s: "%s"
                
                %s
                
                Hãy cung cấp câu trả lời tập trung vào các sản phẩm trong danh mục %s.
                
                Quy tắc trả lời:
                1. Trả lời bằng tiếng Việt chuyên nghiệp, ngắn gọn
                2. Nhấn mạnh 2-3 đặc điểm nổi bật nhất của danh mục này
                3. So sánh ngắn gọn 2-3 sản phẩm tốt nhất
                4. Format: Tên khóa, giá, tính năng chính (1 câu)
                5. Độ dài: 150-250 từ, tránh list dài
                6. Tập trung vào thông tin khách hàng cần
                """, category, userQuery, productContext, category);
    }

    private String createPriceRangePrompt(String userQuery, Long minPrice, Long maxPrice, String productContext) {
        return String.format("""
                Bạn là chuyên gia tư vấn khóa điện tử, khóa vân tay chuyên nghiệp.
                
                Câu hỏi của khách hàng (ngân sách: %,d - %,d VND): "%s"
                
                %s
                
                Hãy đưa ra gợi ý khóa điện tử trong phạm vi ngân sách của khách hàng.
                
                Quy tắc trả lời:
                1. Trả lời bằng tiếng Việt chuyên nghiệp, ngắn gọn
                2. Đề xuất 3 sản phẩm tốt nhất trong tầm giá, mỗi sản phẩm 1-2 câu
                3. Giải thích ngắn gọn tại sao phù hợp (1 câu/sản phẩm)
                4. Format giá: X.XXX.XXX VND
                5. Độ dài: 150-250 từ, tránh list dài
                6. Tập trung vào giá trị/tiền quan trọng nhất
                """, minPrice, maxPrice, userQuery, productContext);
    }

    private String createComparisonPrompt(String comparisonContext) {
        return String.format("""
                Bạn là chuyên gia tư vấn khóa điện tử chuyên nghiệp. Hãy so sánh chi tiết các khóa sau:
                
                %s
                
                Cung cấp so sánh chuyên sâu bao gồm:
                
                1. 💰 Chênh lệch giá và giá trị đồng tiền
                   - Khóa nào đáng đồng tiền nhất?
                   - Chênh lệch giá có hợp lý với sự khác biệt về tính năng và công nghệ không?
                
                2. 🔒 Tính năng bảo mật và công nghệ
                   - So sánh các phương thức mở khóa (vân tay, mật khẩu, thẻ từ, app, chìa cơ)
                   - Công nghệ cảm biến vân tay (quang học, bán dẫn)
                   - Tính năng chống sao chép, cảnh báo xâm nhập
                   - Khả năng lưu trữ vân tay/mã số
                
                3. ⚡ Đặc điểm kỹ thuật
                   - Chất liệu thân khóa (hợp kim kẽm, thép không gỉ, nhôm)
                   - Nguồn điện: loại pin, thời gian sử dụng, cảnh báo hết pin
                   - Khả năng chống nước, chống bụi (IP rating)
                   - Kích thước, trọng lượng
                   - Công nghệ kết nối (WiFi, Bluetooth, Zigbee)
                
                4. 🚪 Tương thích và lắp đặt
                   - Loại cửa phù hợp (gỗ, kính, nhôm, sắt)
                   - Độ dày cửa yêu cầu
                   - Độ khó lắp đặt
                   - Chi phí lắp đặt (nếu có)
                
                5. 🌟 Tính năng thông minh (nếu có)
                   - Điều khiển từ xa qua app
                   - Thông báo đẩy khi có người mở cửa
                   - Tích hợp smart home
                   - Xem lịch sử ra vào
                
                6. 🛡️ Bảo hành và hỗ trợ
                   - Thời gian bảo hành
                   - Chính sách đổi trả
                   - Hỗ trợ kỹ thuật
                
                7. 💡 Đề xuất dựa trên nhu cầu
                   - Ưu tiên giá rẻ: chọn khóa nào?
                   - Ưu tiên bảo mật cao: chọn khóa nào?
                   - Cần tính năng thông minh: chọn khóa nào?
                   - Phù hợp cho gia đình: chọn khóa nào?
                   - Phù hợp cho văn phòng: chọn khóa nào?
                
                Định dạng câu trả lời rõ ràng, chuyên nghiệp với emoji và bullet points.
                Trả lời bằng tiếng Việt.
                """, comparisonContext);
    }

    private String createRecommendationPrompt(String preferences, String productContext) {
        return String.format("""
                Bạn là chuyên gia tư vấn khóa điện tử, khóa vân tay với kiến thức sâu về an ninh và công nghệ.
                
                Nhu cầu/Yêu cầu của khách hàng: "%s"
                
                %s
                
                Dựa trên nhu cầu của khách hàng và các sản phẩm có sẵn, hãy đưa ra đề xuất chuyên nghiệp.
                
                Quy tắc đề xuất:
                1. Trả lời bằng tiếng Việt chuyên nghiệp, ngắn gọn
                2. Phân tích nhanh nhu cầu: loại cửa, ngân sách, tính năng ưu tiên (1-2 câu)
                3. Đề xuất 3 khóa phù hợp nhất, mỗi khóa:
                   - Tên, giá (1 câu)
                   - Tại sao phù hợp (1 câu)
                   - Tính năng nổi bật (1 câu)
                4. Đưa ra 1-2 lời khuyên quan trọng nhất (không liệt kê dài)
                5. Độ dài: 200-300 từ, tập trung vào thông tin cần thiết
                6. Format rõ ràng, dễ đọc
                
                Hãy đưa ra đề xuất như một chuyên gia an ninh đang tư vấn chân thành để bảo vệ tài sản và gia đình khách hàng.
                """, preferences, productContext);
    }

    public String provideWarrantyAdvice(String query) {
        log.info("Providing warranty advice for: {}", query);
        
        String prompt = createWarrantyPrompt(query);
        var response = geminiChatModel.chat(UserMessage.from(prompt));
        
        return response.aiMessage().text();
    }

    public String diagnoseLockIssue(String issueDescription) {
        log.info("Diagnosing lock issue: {}", issueDescription);
        
        String prompt = createDiagnosticPrompt(issueDescription);
        var response = geminiChatModel.chat(UserMessage.from(prompt));
        
        return response.aiMessage().text();
    }

    public String generateDashboardInsights(String statsContext) {
        log.info("Generating dashboard insights based on stats");
        
        String prompt = createDashboardInsightsPrompt(statsContext);
        var response = geminiChatModel.chat(UserMessage.from(prompt));
        
        return response.aiMessage().text();
    }

    private String createDashboardInsightsPrompt(String statsContext) {
        return String.format("""
                Đóng vai chuyên gia kinh tế và chiến lược kinh doanh cao cấp của Locker Korea.
                
                Dựa trên dữ liệu thống kê kinh doanh dưới đây:
                %s
                
                Hãy phân tích sâu và đưa ra đề xuất kế hoạch hành động chi tiết.
                
                Yêu cầu phân tích:
                1. Đánh giá sức khỏe tài chính: Phân tích xu hướng dòng tiền, biến động doanh thu theo ngày.
                2. Nhận diện vấn đề/Cơ hội: Chỉ ra các ngày doanh thu đột biến (cao/thấp) và đưa ra giả thuyết nguyên nhân.
                3. Chiến lược sản phẩm: Dựa trên Top sản phẩm bán chạy, đề xuất chiến lược nhập hàng, pricing hoặc bundling.
                
                Đề xuất kế hoạch hành động (Action Plan):
                - Ngắn hạn (Tuần tới): Cần làm gì ngay? (VD: Marketing, xả hàng, chăm sóc khách hàng cũ...)
                - Trung hạn (Tháng tới): Chiến lược cải thiện doanh thu bền vững.
                
                Văn phong: Chuyên nghiệp, sắc sảo, dùng từ ngữ kinh tế/thương mại.
                Định dạng: Đoạn văn đơn giản để cho người không hiểu nhiều về kinh tế có thể hiểu.
                """, statsContext);
    }

    private String createWarrantyPrompt(String query) {
        return String.format("""
                Bạn là chuyên viên tư vấn chính sách bảo hành của Locker Korea, chuyên về khóa điện tử và khóa vân tay.
                
                Câu hỏi của khách hàng về bảo hành: "%s"
                
                Hãy tư vấn về chính sách bảo hành một cách chuyên nghiệp, rõ ràng.
                
                Quy tắc trả lời:
                1. Trả lời bằng tiếng Việt, giọng điệu chuyên nghiệp và thân thiện
                2. Nếu câu hỏi về thời gian bảo hành: bảo hành đổi mới trong 30 ngày, bảo hành cửa hàng 12 tháng
                3. Nếu về phạm vi bảo hành: giải thích những gì được bảo hành (lỗi phần cứng, phần mềm) và không được bảo hành (lỗi do người dùng, thiên tai, hỏng do nước)
                4. Nếu về quy trình bảo hành: hướng dẫn các bước (liên hệ, kiểm tra, sửa chữa/đổi mới)
                5. Nếu về điều kiện bảo hành: cần hóa đơn, tem bảo hành, không tự ý sửa chữa
                6. Nếu về chi phí: bảo hành miễn phí trong thời hạn, ngoài thời hạn có phí
                7. Độ dài: 100-200 từ, ngắn gọn, rõ ràng
                8. Nếu không chắc chắn, khuyên khách liên hệ hotline hoặc cửa hàng để được tư vấn chi tiết
                
                ⚠️ NGHIÊM CẤM:
                - KHÔNG giới thiệu hoặc đề xuất sản phẩm khác
                - KHÔNG đề cập đến các model khóa cụ thể
                - KHÔNG khuyến khích mua sản phẩm mới hoặc nâng cấp
                - ĐÂY LÀ HỖ TRỢ BẢO HÀNH, KHÔNG PHẢI BÁN HÀNG
                
                Chỉ tập trung vào trả lời câu hỏi về chính sách bảo hành và hướng dẫn khách hàng thực hiện quyền bảo hành.
                """, query);
    }

    private String createDiagnosticPrompt(String issueDescription) {
        return String.format("""
                Bạn là kỹ thuật viên chẩn đoán lỗi khóa điện tử chuyên nghiệp của Locker Korea.
                
                Mô tả lỗi của khách hàng: "%s"
                
                Hãy chẩn đoán vấn đề và đưa ra giải pháp.
                
                Quy tắc chẩn đoán:
                1. Trả lời bằng tiếng Việt, giọng điệu chuyên nghiệp, thân thiện
                2. Phân tích các nguyên nhân có thể gây ra lỗi
                3. Đưa ra các bước kiểm tra đơn giản khách hàng có thể tự làm
                4. Đề xuất giải pháp khắc phục từ đơn giản đến phức tạp
                5. Nếu cần hỗ trợ kỹ thuật, hướng dẫn liên hệ
                
                Các lỗi thường gặp và cách xử lý:
                - Khóa không nhận vân tay: Làm sạch cảm biến, đăng ký lại vân tay, kiểm tra pin
                - Khóa không mở bằng mật khẩu: Reset mật khẩu, kiểm tra pin, reset factory
                - Khóa không kết nối app: Kiểm tra WiFi/Bluetooth, reset kết nối, cập nhật app
                - Khóa kêu bíp liên tục: Pin yếu, lỗi cảm biến, khóa cửa sai cách
                - Khóa không có điện: Thay pin, kiểm tra tiếp xúc pin, dùng chìa cơ khẩn cấp
                - Khóa báo lỗi: Mã lỗi cụ thể, reset, liên hệ kỹ thuật
                
                6. Độ dài: 150-250 từ, tập trung vào giải pháp thực tế
                7. Nếu lỗi phức tạp, khuyên khách liên hệ kỹ thuật viên
                
                ⚠️ NGHIÊM CẤM:
                - KHÔNG giới thiệu hoặc đề xuất mua sản phẩm khác
                - KHÔNG đề xuất "nâng cấp" hoặc "thay thế" bằng model mới
                - KHÔNG đề cập đến các sản phẩm cụ thể đang bán
                - ĐÂY LÀ HỖ TRỢ KỸ THUẬT, KHÔNG PHẢI BÁN HÀNG
                - Chỉ tập trung vào KHẮC PHỤC LỖI của sản phẩm hiện tại
                
                Hãy chẩn đoán chính xác và đưa ra giải pháp rõ ràng để khách hàng có thể sửa được lỗi của sản phẩm hiện có.
                """, issueDescription);
    }
}