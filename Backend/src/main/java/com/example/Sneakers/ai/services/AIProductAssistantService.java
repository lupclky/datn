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
                1. Trả lời bằng tiếng Việt một cách tự nhiên, thân thiện, chuyên nghiệp
                2. Nếu khách hỏi về sản phẩm cụ thể, hãy tham chiếu đến các sản phẩm thực tế ở trên
                3. Luôn bao gồm: tên sản phẩm, giá, thương hiệu, tính năng chính, % giảm giá (nếu có)
                4. Format giá tiền theo định dạng Việt Nam (VD: 5.500.000 VND)
                5. Nếu có nhiều sản phẩm phù hợp, liệt kê 3-5 sản phẩm tốt nhất
                6. Nếu không tìm thấy sản phẩm phù hợp, gợi ý sản phẩm thay thế hoặc hỏi thêm thông tin
                7. Giải thích tại sao sản phẩm phù hợp với nhu cầu của khách hàng
                8. Đưa ra lời khuyên chuyên môn về:
                   - Tính năng bảo mật (vân tay, mật khẩu, thẻ từ, điều khiển từ xa)
                   - Độ bền, chất liệu (hợp kim kẽm, thép không gỉ)
                   - Loại cửa phù hợp (cửa gỗ, cửa kính, cửa nhôm)
                   - Nguồn điện và pin dự phòng
                   - Tính năng thông minh (WiFi, App, khóa từ xa)
                   - Khả năng chống nước, chống bụi
                   - Bảo hành và hỗ trợ lắp đặt
                
                Hãy trả lời một cách chuyên nghiệp, nhiệt tình và tập trung vào việc giúp khách hàng chọn được khóa điện tử phù hợp nhất cho nhu cầu an ninh của họ.
                """, userQuery, productContext);
    }

    private String createCategoryPrompt(String userQuery, String category, String productContext) {
        return String.format("""
                Bạn là chuyên gia tư vấn khóa điện tử, khóa vân tay chuyên nghiệp.
                
                Câu hỏi của khách hàng về danh mục %s: "%s"
                
                %s
                
                Hãy cung cấp câu trả lời tập trung vào các sản phẩm trong danh mục %s.
                
                Quy tắc trả lời:
                1. Trả lời bằng tiếng Việt chuyên nghiệp
                2. Nhấn mạnh đặc điểm bảo mật và công nghệ của sản phẩm trong danh mục này
                3. Giải thích phân khúc giá và giá trị của từng sản phẩm
                4. Đề xuất sản phẩm phù hợp với các loại cửa và nhu cầu khác nhau
                5. Nêu rõ các ưu đãi đặc biệt, chính sách bảo hành và lắp đặt (nếu có)
                6. Format: Tên khóa, thương hiệu, giá (VND), giảm giá (%), tính năng nổi bật, loại cửa phù hợp
                7. So sánh công nghệ và mức độ bảo mật giữa các sản phẩm
                """, category, userQuery, productContext, category);
    }

    private String createPriceRangePrompt(String userQuery, Long minPrice, Long maxPrice, String productContext) {
        return String.format("""
                Bạn là chuyên gia tư vấn khóa điện tử, khóa vân tay chuyên nghiệp.
                
                Câu hỏi của khách hàng (ngân sách: %,d - %,d VND): "%s"
                
                %s
                
                Hãy đưa ra gợi ý khóa điện tử trong phạm vi ngân sách của khách hàng.
                
                Quy tắc trả lời:
                1. Trả lời bằng tiếng Việt chuyên nghiệp
                2. Ưu tiên các sản phẩm có tính năng bảo mật tốt nhất trong tầm giá
                3. Giải thích tại sao đây là lựa chọn tốt về giá trị/tiền (công nghệ, độ bền, bảo mật)
                4. Xếp hạng sản phẩm theo độ phù hợp với ngân sách và nhu cầu
                5. Nếu có sản phẩm cao hơn ngân sách một chút nhưng có tính năng vượt trội, có thể đề cập
                6. So sánh các mức giá và tính năng/giá trị nhận được
                7. Format giá: X.XXX.XXX VND (VD: 5.500.000 VND)
                8. Lưu ý về chi phí lắp đặt (nếu có)
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
                1. Trả lời bằng tiếng Việt với giọng điệu chuyên nghiệp, tư vấn tận tình
                2. Phân tích nhu cầu an ninh thực sự của khách hàng từ mô tả:
                   - Loại cửa (cửa chính, cửa phụ, cửa văn phòng)
                   - Mức độ bảo mật cần thiết
                   - Số lượng người sử dụng
                   - Ngân sách
                   - Tính năng ưu tiên (vân tay, app, từ xa, thẻ từ)
                3. Đề xuất 3-5 khóa điện tử xếp theo độ phù hợp (cao → thấp)
                4. Với mỗi sản phẩm, giải thích chi tiết:
                   ✓ Tại sao khóa này phù hợp với nhu cầu của khách
                   ✓ Tính năng bảo mật nổi bật (vân tay, mật khẩu, thẻ từ, app)
                   ✓ Công nghệ sử dụng (cảm biến, kết nối, chống nước)
                   ✓ Giá cả và giá trị nhận được
                   ✓ Ưu đãi đặc biệt, bảo hành, lắp đặt miễn phí (nếu có)
                5. Đưa ra lời khuyên thêm về:
                   - Cách lắp đặt và sử dụng
                   - Bảo trì và chăm sóc khóa điện tử
                   - Cách tăng cường bảo mật
                   - Lưu ý về pin và nguồn điện dự phòng
                   - Khả năng mở khẩn cấp khi hết pin
                6. Cảnh báo và lưu ý quan trọng (nếu có)
                7. Format rõ ràng với emoji và cấu trúc dễ đọc
                
                Hãy đưa ra đề xuất như một chuyên gia an ninh đang tư vấn chân thành để bảo vệ tài sản và gia đình khách hàng.
                """, preferences, productContext);
    }
}