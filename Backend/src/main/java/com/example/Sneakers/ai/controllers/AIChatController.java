package com.example.Sneakers.ai.controllers;

import com.example.Sneakers.ai.services.AIProductAssistantService;
import dev.langchain4j.data.message.ImageContent;
import dev.langchain4j.data.message.TextContent;
import dev.langchain4j.data.message.UserMessage;
import dev.langchain4j.model.chat.ChatModel;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Base64;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("${api.prefix}/ai/chat")
@CrossOrigin(origins = "*")
@RequiredArgsConstructor
@Slf4j
public class AIChatController {

    private final ChatModel geminiChatModel;
    private final AIProductAssistantService aiProductAssistantService;

    @PostMapping("/text")
    public ResponseEntity<Map<String, Object>> chatWithText(@RequestBody Map<String, String> request) {
        try {
            String message = request.get("message");
            if (message == null || message.trim().isEmpty()) {
                return ResponseEntity.badRequest()
                        .body(Map.of("error", "Message cannot be empty"));
            }

            log.info("Processing text chat request");
            var response = geminiChatModel.chat(UserMessage.from(message));

            Map<String, Object> result = new HashMap<>();
            result.put("response", response.aiMessage().text());
            result.put("success", true);
            result.put("timestamp", System.currentTimeMillis());

            return ResponseEntity.ok(result);

        } catch (Exception e) {
            log.error("Error processing text chat", e);
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("error", e.getMessage());
            errorResponse.put("success", false);
            return ResponseEntity.internalServerError().body(errorResponse);
        }
    }

    @PostMapping(value = "/image", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<Map<String, Object>> chatWithImage(
            @RequestParam("image") MultipartFile image,
            @RequestParam("prompt") String prompt) {

        try {
            if (image.isEmpty()) {
                return ResponseEntity.badRequest()
                        .body(Map.of("error", "Image cannot be empty"));
            }

            if (prompt == null || prompt.trim().isEmpty()) {
                return ResponseEntity.badRequest()
                        .body(Map.of("error", "Prompt cannot be empty"));
            }

            log.info("Processing image chat request");
            byte[] imageBytes = image.getBytes();
            String base64Image = Base64.getEncoder().encodeToString(imageBytes);

            // Get the content type from the uploaded file
            String mimeType = image.getContentType();
            if (mimeType == null || mimeType.isEmpty()) {
                // Default to JPEG if content type is not available
                mimeType = "image/jpeg";
            }

            log.info("Image MIME type: {}", mimeType);

            var response = geminiChatModel.chat(
                    UserMessage.from(
                            ImageContent.from(base64Image, mimeType),
                            TextContent.from(prompt)));

            Map<String, Object> result = new HashMap<>();
            result.put("response", response.aiMessage().text());
            result.put("success", true);
            result.put("timestamp", System.currentTimeMillis());

            return ResponseEntity.ok(result);

        } catch (IOException e) {
            log.error("Failed to process image", e);
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("error", "Failed to process image: " + e.getMessage());
            errorResponse.put("success", false);
            return ResponseEntity.internalServerError().body(errorResponse);
        } catch (Exception e) {
            log.error("Error processing image chat", e);
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("error", e.getMessage());
            errorResponse.put("success", false);
            return ResponseEntity.internalServerError().body(errorResponse);
        }
    }

    @PostMapping("/product-assistant")
    public ResponseEntity<Map<String, Object>> productAssistant(@RequestBody Map<String, String> request) {
        try {
            String userQuery = request.get("query");
            if (userQuery == null || userQuery.trim().isEmpty()) {
                return ResponseEntity.badRequest()
                        .body(Map.of("error", "Query cannot be empty"));
            }

            log.info("Processing product assistant request with database context");

            // Use the enhanced AI service that searches the database
            String response = aiProductAssistantService.answerProductQuery(userQuery);

            Map<String, Object> result = new HashMap<>();
            result.put("response", response);
            result.put("success", true);
            result.put("type", "product-assistant");
            result.put("timestamp", System.currentTimeMillis());

            return ResponseEntity.ok(result);

        } catch (Exception e) {
            log.error("Error in product assistant", e);
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("error", e.getMessage());
            errorResponse.put("success", false);
            return ResponseEntity.internalServerError().body(errorResponse);
        }
    }

    @PostMapping("/generate-news")
    public ResponseEntity<Map<String, Object>> generateNewsContent(@RequestBody Map<String, String> request) {
        try {
            String title = request.get("title");
            String topic = request.get("topic");
            String keywords = request.get("keywords");
            
            if (title == null || title.trim().isEmpty()) {
                return ResponseEntity.badRequest()
                        .body(Map.of("error", "Title is required"));
            }

            log.info("Generating news content for title: {}", title);

            // Create prompt for news generation
            String prompt = createNewsGenerationPrompt(title, topic, keywords);
            
            var response = geminiChatModel.chat(UserMessage.from(prompt));
            
            Map<String, Object> result = new HashMap<>();
            result.put("content", response.aiMessage().text());
            result.put("success", true);
            result.put("timestamp", System.currentTimeMillis());

            return ResponseEntity.ok(result);

        } catch (Exception e) {
            log.error("Error generating news content", e);
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("error", e.getMessage());
            errorResponse.put("success", false);
            return ResponseEntity.internalServerError().body(errorResponse);
        }
    }
    
    private String createNewsGenerationPrompt(String title, String topic, String keywords) {
        StringBuilder prompt = new StringBuilder();
        prompt.append("Bạn là một biên tập viên chuyên nghiệp về khóa điện tử và công nghệ an ninh.\n\n");
        prompt.append("Hãy viết một bài báo chi tiết và chuyên nghiệp với:\n");
        prompt.append("Tiêu đề: ").append(title).append("\n");
        
        if (topic != null && !topic.trim().isEmpty()) {
            prompt.append("Chủ đề: ").append(topic).append("\n");
        }
        
        if (keywords != null && !keywords.trim().isEmpty()) {
            prompt.append("Từ khóa cần đề cập: ").append(keywords).append("\n");
        }
        
        prompt.append("\nYêu cầu:\n");
        prompt.append("1. Viết bài bằng tiếng Việt chuyên nghiệp, dễ hiểu\n");
        prompt.append("2. Cấu trúc rõ ràng với các phần: Mở bài, Nội dung chính (3-4 đoạn), Kết luận\n");
        prompt.append("3. Độ dài: 800-1200 từ\n");
        prompt.append("4. Sử dụng HTML formatting:\n");
        prompt.append("   - <h2> cho tiêu đề phụ\n");
        prompt.append("   - <p> cho đoạn văn\n");
        prompt.append("   - <strong> cho từ khóa quan trọng\n");
        prompt.append("   - <ul><li> cho danh sách\n");
        prompt.append("   - <blockquote> cho trích dẫn (nếu có)\n");
        prompt.append("5. Nội dung liên quan đến:\n");
        prompt.append("   - Khóa điện tử, khóa vân tay, công nghệ smart lock\n");
        prompt.append("   - An ninh gia đình, công nghệ bảo mật\n");
        prompt.append("   - Xu hướng công nghệ IoT, smart home\n");
        prompt.append("   - Tư vấn chọn mua và sử dụng\n");
        prompt.append("6. Giọng văn chuyên nghiệp nhưng thân thiện, dễ tiếp cận\n");
        prompt.append("7. Đưa ra thông tin hữu ích, tips thực tế cho người đọc\n");
        prompt.append("8. KHÔNG đề cập đến thương hiệu cụ thể trừ khi có trong tiêu đề\n\n");
        prompt.append("Hãy viết bài báo hoàn chỉnh với HTML formatting:");
        
        return prompt.toString();
    }

    @PostMapping("/generate-product-description")
    public ResponseEntity<Map<String, Object>> generateProductDescription(@RequestBody Map<String, String> request) {
        try {
            String productName = request.get("productName");
            String category = request.get("category");
            String features = request.get("features");
            
            if (productName == null || productName.trim().isEmpty()) {
                return ResponseEntity.badRequest()
                        .body(Map.of("error", "Product name is required"));
            }

            log.info("Generating product description for: {}", productName);

            // Create prompt for product description
            String prompt = createProductDescriptionPrompt(productName, category, features);
            
            var response = geminiChatModel.chat(UserMessage.from(prompt));
            
            Map<String, Object> result = new HashMap<>();
            result.put("content", response.aiMessage().text());
            result.put("success", true);
            result.put("timestamp", System.currentTimeMillis());

            return ResponseEntity.ok(result);

        } catch (Exception e) {
            log.error("Error generating product description", e);
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("error", e.getMessage());
            errorResponse.put("success", false);
            return ResponseEntity.internalServerError().body(errorResponse);
        }
    }
    
    private String createProductDescriptionPrompt(String productName, String category, String features) {
        StringBuilder prompt = new StringBuilder();
        prompt.append("Bạn là chuyên gia viết mô tả sản phẩm chuyên nghiệp cho Locker Korea - cửa hàng khóa điện tử hàng đầu.\n\n");
        prompt.append("Hãy viết mô tả chi tiết và hấp dẫn cho sản phẩm:\n");
        prompt.append("Tên sản phẩm: ").append(productName).append("\n");
        
        if (category != null && !category.trim().isEmpty() && !"N/A".equals(category)) {
            prompt.append("Danh mục: ").append(category).append("\n");
        }
        
        if (features != null && !features.trim().isEmpty()) {
            prompt.append("Tính năng: ").append(features).append("\n");
        }
        
        prompt.append("\nYêu cầu:\n");
        prompt.append("1. Viết bằng tiếng Việt chuyên nghiệp, hấp dẫn, thuyết phục\n");
        prompt.append("2. Cấu trúc bài viết gồm:\n");
        prompt.append("   - Mở đầu: Giới thiệu tổng quan sản phẩm (50-80 từ)\n");
        prompt.append("   - Đặc điểm nổi bật: 4-6 điểm mạnh chính\n");
        prompt.append("   - Công nghệ & Chất liệu: Chi tiết kỹ thuật\n");
        prompt.append("   - Ứng dụng: Phù hợp với ai, dùng cho đâu\n");
        prompt.append("   - Kết luận: Tại sao nên chọn sản phẩm này\n");
        prompt.append("3. Độ dài: 600-900 từ\n");
        prompt.append("4. Sử dụng HTML formatting:\n");
        prompt.append("   - <h2> cho tiêu đề chính\n");
        prompt.append("   - <h3> cho tiêu đề phụ\n");
        prompt.append("   - <p> cho đoạn văn\n");
        prompt.append("   - <strong> cho từ khóa quan trọng\n");
        prompt.append("   - <ul><li> cho danh sách tính năng\n");
        prompt.append("   - <blockquote> cho highlights đặc biệt\n");
        prompt.append("5. Nội dung tập trung vào:\n");
        prompt.append("   - Tính năng bảo mật vượt trội\n");
        prompt.append("   - Chất liệu cao cấp, bền bỉ\n");
        prompt.append("   - Công nghệ thông minh hiện đại\n");
        prompt.append("   - Dễ sử dụng, phù hợp mọi lứa tuổi\n");
        prompt.append("   - Thiết kế sang trọng, đẳng cấp\n");
        prompt.append("6. Giọng văn thuyết phục nhưng không quảng cáo quá lố\n");
        prompt.append("7. Nhấn mạnh lợi ích người dùng thực tế\n");
        prompt.append("8. Tạo cảm giác tin cậy và chuyên nghiệp\n\n");
        prompt.append("Hãy viết mô tả sản phẩm hoàn chỉnh với HTML formatting:");
        
        return prompt.toString();
    }

    @PostMapping("/product-assistant/by-category")
    public ResponseEntity<Map<String, Object>> productAssistantByCategory(@RequestBody Map<String, String> request) {
        try {
            String userQuery = request.get("query");
            String category = request.get("category");

            if (userQuery == null || userQuery.trim().isEmpty()) {
                return ResponseEntity.badRequest()
                        .body(Map.of("error", "Query cannot be empty"));
            }

            log.info("Processing product assistant request for category: {}", category);

            String response = aiProductAssistantService.answerProductQueryByCategory(userQuery, category);

            Map<String, Object> result = new HashMap<>();
            result.put("response", response);
            result.put("success", true);
            result.put("type", "product-assistant-category");
            result.put("timestamp", System.currentTimeMillis());

            return ResponseEntity.ok(result);

        } catch (Exception e) {
            log.error("Error in product assistant by category", e);
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("error", e.getMessage());
            errorResponse.put("success", false);
            return ResponseEntity.internalServerError().body(errorResponse);
        }
    }

    @PostMapping("/product-assistant/compare")
    public ResponseEntity<Map<String, Object>> compareProducts(@RequestBody Map<String, Object> request) {
        try {
            @SuppressWarnings("unchecked")
            List<Long> productIds = (List<Long>) request.get("productIds");

            if (productIds == null || productIds.isEmpty()) {
                return ResponseEntity.badRequest()
                        .body(Map.of("error", "Product IDs cannot be empty"));
            }

            log.info("Comparing products: {}", productIds);

            String response = aiProductAssistantService.compareProducts(productIds);

            Map<String, Object> result = new HashMap<>();
            result.put("response", response);
            result.put("success", true);
            result.put("type", "product-comparison");
            result.put("timestamp", System.currentTimeMillis());

            return ResponseEntity.ok(result);

        } catch (Exception e) {
            log.error("Error in product comparison", e);
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("error", e.getMessage());
            errorResponse.put("success", false);
            return ResponseEntity.internalServerError().body(errorResponse);
        }
    }

    @PostMapping("/product-assistant/recommend")
    public ResponseEntity<Map<String, Object>> recommendProducts(@RequestBody Map<String, String> request) {
        try {
            String preferences = request.get("preferences");

            if (preferences == null || preferences.trim().isEmpty()) {
                return ResponseEntity.badRequest()
                        .body(Map.of("error", "Preferences cannot be empty"));
            }

            log.info("Generating product recommendations");

            String response = aiProductAssistantService.provideProductRecommendations(preferences);

            Map<String, Object> result = new HashMap<>();
            result.put("response", response);
            result.put("success", true);
            result.put("type", "product-recommendations");
            result.put("timestamp", System.currentTimeMillis());

            return ResponseEntity.ok(result);

        } catch (Exception e) {
            log.error("Error in product recommendations", e);
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("error", e.getMessage());
            errorResponse.put("success", false);
            return ResponseEntity.internalServerError().body(errorResponse);
        }
    }

    @PostMapping("/warranty-advice")
    public ResponseEntity<Map<String, Object>> warrantyAdvice(@RequestBody Map<String, String> request) {
        try {
            String query = request.get("query");
            if (query == null || query.trim().isEmpty()) {
                return ResponseEntity.badRequest()
                        .body(Map.of("error", "Query cannot be empty"));
            }

            log.info("Processing warranty advice request");

            String response = aiProductAssistantService.provideWarrantyAdvice(query);

            Map<String, Object> result = new HashMap<>();
            result.put("response", response);
            result.put("success", true);
            result.put("type", "warranty-advice");
            result.put("timestamp", System.currentTimeMillis());

            return ResponseEntity.ok(result);

        } catch (Exception e) {
            log.error("Error in warranty advice", e);
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("error", e.getMessage());
            errorResponse.put("success", false);
            return ResponseEntity.internalServerError().body(errorResponse);
        }
    }

    @PostMapping("/diagnose-issue")
    public ResponseEntity<Map<String, Object>> diagnoseIssue(@RequestBody Map<String, String> request) {
        try {
            String issueDescription = request.get("issue");
            if (issueDescription == null || issueDescription.trim().isEmpty()) {
                return ResponseEntity.badRequest()
                        .body(Map.of("error", "Issue description cannot be empty"));
            }

            log.info("Processing lock issue diagnosis");

            String response = aiProductAssistantService.diagnoseLockIssue(issueDescription);

            Map<String, Object> result = new HashMap<>();
            result.put("response", response);
            result.put("success", true);
            result.put("type", "diagnosis");
            result.put("timestamp", System.currentTimeMillis());

            return ResponseEntity.ok(result);

        } catch (Exception e) {
            log.error("Error in issue diagnosis", e);
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("error", e.getMessage());
            errorResponse.put("success", false);
            return ResponseEntity.internalServerError().body(errorResponse);
        }
    }
}