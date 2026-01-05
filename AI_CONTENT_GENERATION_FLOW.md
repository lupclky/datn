# Luồng Generate Content (Mô tả sản phẩm & Tin tức)

Tài liệu này mô tả chi tiết luồng xử lý cho hai tính năng AI:
1.  **Generate Product Description**: Tự động tạo mô tả sản phẩm dựa trên tên, danh mục và tính năng.
2.  **Generate News Content**: Tự động viết bài tin tức dựa trên tiêu đề, chủ đề và tóm tắt.

## 1. Generate Product Description (Tạo mô tả sản phẩm)

### Tổng quan
Tính năng này giúp Admin/Staff tạo nhanh mô tả chi tiết cho sản phẩm mới hoặc cập nhật sản phẩm cũ. AI sẽ dựa vào tên sản phẩm và các thông số kỹ thuật để viết một đoạn mô tả hấp dẫn, chuẩn SEO.

### Các thành phần tham gia
*   **Frontend**: `ProductManageComponent` (Quản lý sản phẩm), `DetailProductComponent` (Chi tiết sản phẩm).
*   **Service (FE)**: `AiService`.
*   **Backend**: `AIChatController`.
*   **AI Model**: Gemini (qua `ChatModel`).

### Chi tiết luồng xử lý

1.  **User Input (Frontend)**:
    *   Người dùng nhập **Tên sản phẩm** (Bắt buộc).
    *   Người dùng chọn **Danh mục** (Category).
    *   Người dùng chọn các **Tính năng** (Features) từ danh sách.
    *   Người dùng nhấn nút **"Generate Description"** (hoặc biểu tượng AI).

2.  **Frontend Processing**:
    *   File: `Frontend/src/app/features/components/product-manage/product-manage.component.ts`
    *   Hàm `generateProductDescription()` thu thập dữ liệu từ Form.
    *   Gọi `aiService.generateProductDescription(productName, categoryName, featureNames)`.

3.  **API Request**:
    *   Method: `POST`
    *   URL: `/api/v1/ai/chat/generate-product-description`
    *   Body:
        ```json
        {
          "productName": "Khóa điện tử Samsung SHP-DP609",
          "category": "Khóa Push-Pull",
          "features": "Vân tay, Mã số, Thẻ từ, WiFi"
        }
        ```

4.  **Backend Processing**:
    *   File: `Backend/src/main/java/com/example/Sneakers/ai/controllers/AIChatController.java`
    *   Controller nhận request, kiểm tra `productName`.
    *   Tạo Prompt cho AI: `createProductDescriptionPrompt(...)`.
    *   Gửi Prompt đến Gemini: `geminiChatModel.chat(...)`.
    *   Nhận phản hồi text từ AI.

5.  **Response & UI Update**:
    *   Backend trả về JSON chứa nội dung mô tả.
    *   Frontend nhận response, tự động điền nội dung vào ô **Mô tả** (Description) trong Form.
    *   Hiển thị thông báo thành công.

---

## 2. Generate News Content (Viết bài tin tức)

### Tổng quan
Tính năng này hỗ trợ Admin tạo nội dung bài viết tin tức/blog chuyên nghiệp. Chỉ cần nhập tiêu đề và các từ khóa, AI sẽ viết một bài báo hoàn chỉnh với định dạng HTML.

### Các thành phần tham gia
*   **Frontend**: `NewsManageComponent`.
*   **Service (FE)**: `AiService`.
*   **Backend**: `AIChatController`.
*   **AI Model**: Gemini.

### Chi tiết luồng xử lý

1.  **User Input (Frontend)**:
    *   Người dùng nhập **Tiêu đề** (Title) - Bắt buộc.
    *   Người dùng nhập **Chủ đề/Danh mục** (Category) - Tùy chọn.
    *   Người dùng nhập **Tóm tắt/Từ khóa** (Summary/Keywords) - Tùy chọn.
    *   Người dùng nhấn nút **"Generate Content"**.

2.  **Frontend Processing**:
    *   File: `Frontend/src/app/features/components/news-manage/news-manage.component.ts`
    *   Hàm `generateContent()` kiểm tra tiêu đề.
    *   Gọi `aiService.generateNewsContent(title, category, summary)`.
    *   Hiển thị trạng thái loading.

3.  **API Request**:
    *   Method: `POST`
    *   URL: `/api/v1/ai/chat/generate-news`
    *   Body:
        ```json
        {
          "title": "Xu hướng khóa cửa thông minh 2025",
          "topic": "Công nghệ",
          "keywords": "IoT, AI, Face ID"
        }
        ```

4.  **Backend Processing**:
    *   File: `Backend/src/main/java/com/example/Sneakers/ai/controllers/AIChatController.java`
    *   Controller nhận request.
    *   Tạo Prompt chi tiết (`createNewsGenerationPrompt`): Yêu cầu AI đóng vai biên tập viên, viết bài chuẩn SEO, độ dài tối thiểu, định dạng HTML (`<p>`, `<h2>`, `<ul>`...).
    *   Gửi Prompt đến Gemini.

5.  **Response & UI Update**:
    *   Backend trả về nội dung bài viết (HTML string).
    *   Frontend nhận response.
    *   Cập nhật nội dung vào **Rich Text Editor** (Quill Editor).
    *   Người dùng có thể chỉnh sửa lại trước khi lưu.
