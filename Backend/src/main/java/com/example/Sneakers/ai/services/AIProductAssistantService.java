package com.example.Sneakers.ai.services;

import com.example.Sneakers.models.Product;
import com.example.Sneakers.repositories.ProductRepository;
import dev.langchain4j.data.document.Document;
import dev.langchain4j.data.message.UserMessage;
import dev.langchain4j.model.chat.ChatModel;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
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

        // Search for relevant products using vector search
        List<Document> relevantDocuments = vectorSearchService.searchProducts(userQuery, 5);

        // Extract product information from documents
        String productContext = buildProductContext(relevantDocuments);

        // Create enhanced prompt with product context
        String enhancedPrompt = createEnhancedPrompt(userQuery, productContext);

        // Get response from Gemini
        var response = geminiChatModel.chat(UserMessage.from(enhancedPrompt));

        return response.aiMessage().text();
    }

    public String answerProductQueryByCategory(String userQuery, String category) {
        log.info("Processing product query in category {}: {}", category, userQuery);

        // Search for relevant products in specific category
        List<Document> relevantDocuments = vectorSearchService.searchProductsByCategory(userQuery, category, 5);

        String productContext = buildProductContext(relevantDocuments);
        String enhancedPrompt = createCategoryPrompt(userQuery, category, productContext);

        var response = geminiChatModel.chat(UserMessage.from(enhancedPrompt));

        return response.aiMessage().text();
    }

    public String answerProductQueryByPriceRange(String userQuery, Long minPrice, Long maxPrice) {
        log.info("Processing product query with price range {}-{}: {}", minPrice, maxPrice, userQuery);

        // Search for relevant products in price range
        List<Document> relevantDocuments = vectorSearchService.searchProductsByPriceRange(userQuery, minPrice, maxPrice,
                5);

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
                Bạn là chuyên gia tư vấn khóa điện tử, khóa vân tay chuyên nghiệp của Locker Korea với quyền truy cập vào cơ sở dữ liệu sản phẩm của cửa hàng.
                
                Câu hỏi của khách hàng: "%s"
                
                %s
                
                Hãy cung cấp câu trả lời hữu ích và chính xác dựa trên các sản phẩm trong cơ sở dữ liệu.
                
                Quy tắc trả lời:
                1. Trả lời bằng tiếng Việt tự nhiên, thân thiện, chuyên nghiệp
                2. Nếu khách hỏi về sản phẩm cụ thể, hãy tham chiếu đến các sản phẩm thực tế ở trên
                3. Luôn bao gồm: tên sản phẩm, giá, thương hiệu, tính năng chính, %% giảm giá (nếu có)
                4. Format giá tiền theo định dạng Việt Nam (VD: 5.500.000 VND)
                5. Nếu có nhiều sản phẩm phù hợp, liệt kê 3-5 sản phẩm tốt nhất với điểm nổi bật ngắn gọn
                6. Nếu không tìm thấy sản phẩm phù hợp, gợi ý sản phẩm thay thế hoặc hỏi thêm thông tin
                7. Giải thích ngắn gọn tại sao sản phẩm phù hợp (1-2 câu)
                8. TRÁNH list dài các yếu tố. Chỉ đề cập 2-3 điểm quan trọng nhất liên quan trực tiếp đến câu hỏi
                9. Độ dài trả lời: 150-300 từ, tập trung vào thông tin cần thiết
                
                Hãy trả lời ngắn gọn, súc tích, tập trung vào thông tin khách hàng cần. Không cần liệt kê tất cả tính năng nếu không liên quan.
                """, userQuery, productContext);
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

    private String createWarrantyPrompt(String query) {
        return String.format("""
                Bạn là chuyên viên tư vấn chính sách bảo hành của Locker Korea, chuyên về khóa điện tử và khóa vân tay.
                
                Câu hỏi của khách hàng về bảo hành: "%s"
                
                Hãy tư vấn về chính sách bảo hành một cách chuyên nghiệp, rõ ràng.
                
                Quy tắc trả lời:
                1. Trả lời bằng tiếng Việt, giọng điệu chuyên nghiệp và thân thiện
                2. Nếu câu hỏi về thời gian bảo hành: thông thường 12-24 tháng tùy hãng
                3. Nếu về phạm vi bảo hành: giải thích những gì được bảo hành (lỗi phần cứng, phần mềm) và không được bảo hành (lỗi do người dùng, thiên tai, hỏng do nước)
                4. Nếu về quy trình bảo hành: hướng dẫn các bước (liên hệ, kiểm tra, sửa chữa/đổi mới)
                5. Nếu về điều kiện bảo hành: cần hóa đơn, tem bảo hành, không tự ý sửa chữa
                6. Nếu về chi phí: bảo hành miễn phí trong thời hạn, ngoài thời hạn có phí
                7. Độ dài: 100-200 từ, ngắn gọn, rõ ràng
                8. Nếu không chắc chắn, khuyên khách liên hệ hotline hoặc cửa hàng để được tư vấn chi tiết
                
                Hãy trả lời cụ thể, hữu ích và khuyến khích khách hàng liên hệ nếu cần hỗ trợ thêm.
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
                
                Hãy chẩn đoán chính xác và đưa ra giải pháp rõ ràng, dễ thực hiện.
                """, issueDescription);
    }
}