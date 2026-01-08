# Các mục trình bày Luồng AI Chatbot (Slide)

Dựa trên sơ đồ hoạt động (Activity Diagram), dưới đây là các bước chính để bạn trình bày trên slide:

## 1. Đầu vào (Input Phase)
*   **Người dùng:** Gửi ảnh sản phẩm kèm câu hỏi (ví dụ: "Đôi này còn size 42 không?").
*   **Java Backend:** Tiếp nhận yêu cầu, đẩy ảnh lên Cloud để lấy URL truy cập.

## 2. Xử lý thông minh (AI Processing Phase)
*   **Vector hóa:** Python Service tải ảnh về và chuyển đổi thành Vector (dãy số đặc trưng).
*   **Tìm kiếm (Vector Search):** So khớp Vector ảnh vừa tạo với kho dữ liệu sản phẩm trong **ChromaDB**.

## 3. Ra quyết định (Decision & Context)
*   *Hệ thống tự động kiểm tra xem ảnh có khớp với sản phẩm nào trong kho không?*
    *   **Trường hợp CÓ:** Lấy thông tin chi tiết (Tên, Giá, Tồn kho thật) làm dữ liệu nền (Context).
    *   **Trường hợp KHÔNG:** Chỉ sử dụng thông tin thị giác từ ảnh (màu sắc, kiểu dáng) để trả lời chung.

## 4. Sinh câu trả lời (Gen AI Phase)
*   **Tổng hợp Prompt:** Kết hợp câu hỏi của khách + Dữ liệu tìm được (nếu có).
*   **Gemini AI:** Sinh câu trả lời tự nhiên, chính xác ngữ cảnh.

## 5. Đầu ra (Output)
*   Hiển thị câu trả lời cuối cùng cho người dùng trên giao diện Chat.
