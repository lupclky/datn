# So sánh Chatbot Text thường & Chatbot Hình ảnh AI

Dưới đây là 2 kịch bản (Scenario) minh họa sự khác biệt khi người dùng tương tác bằng lời nói và bằng hình ảnh trong hệ thống bán Khóa Điện Tử (Smart Lock) của bạn.

## 1. Kịch bản 1: Chatbot Text (Hỏi bằng lời)
*Cơ chế:* Hệ thống tìm kiếm dựa trên từ khóa hoặc ý nghĩa câu hỏi (Semantic Search).

> **User:** "Tư vấn cho mình khóa cửa vân tay nào có chức năng mở bằng app điện thoại, giá khoảng 5 triệu."
>
> **Hệ thống xử lý:**
> 1.  Nhận diện từ khóa: `khóa vân tay`, `mở bằng app`, `giá ~ 5 triệu`.
> 2.  Tìm trong Database: Lọc ra các sản phẩm thỏa mãn (Ví dụ: Samsung SHP, Xiaomi Smart Door Lock).
> 3.  Gửi thông tin cho AI (Gemini) để viết câu trả lời.
>
> **Chatbot trả lời:** "Dạ với nhu cầu khóa vân tay có App tầm giá 5 triệu, bên em có mẫu **Samsung SHP-DP609** đang rất hot, hỗ trợ mở qua Wifi và báo tin nhắn về điện thoại ạ. Bạn có muốn xem ảnh chi tiết không?"

---

## 2. Kịch bản 2: Chatbot Hình ảnh (Visual QA)
*Cơ chế:* Hệ thống "nhìn" ảnh người dùng gửi để tìm sản phẩm tương tự (Image Retrieval).

> **User:** *(Upload một bức ảnh chụp cái khóa cửa nhà hàng xóm hoặc ảnh trên mạng)*
> "Mình muốn lắp cái khóa kiểu tay gạt như thế này, nhưng màu đen, shop có không?"
>
> **Hệ thống xử lý:**
> 1.  **AI Vision:** Quét ảnh, trích xuất đặc điểm (Vector): Kiểu dáng tay gạt (Handle), màu sắc, vị trí cảm biến vân tay.
> 2.  **Vector Search:** Tìm trong Database các mẫu khóa có thiết kế tương đồng.
>     *   *Kết quả tìm thấy:* Kaadas S500 Black (Độ giống 90%).
> 3.  **Kiểm tra kho:** Còn hàng.
> 4.  AI tổng hợp thông tin trả lời.
>
> **Chatbot trả lời:** "Dạ mẫu này nhìn rất giống dòng **Kaadas S500** bên em ạ. Em có sẵn màu đen nhám (Matte Black) như bạn thích. Mẫu này dùng vân tay FPC Thụy Điển rất nhạy. Bạn tham khảo link bên dưới nhé!"

---

## Bảng so sánh tóm tắt (Dùng cho Slide)

| Đặc điểm | Chatbot Text (Truyền thống) | Chatbot Hình ảnh (AI Vision) |
| :--- | :--- | :--- |
| **Đầu vào** | Văn bản (Text) | Ảnh + Văn bản (Multimodal) |
| **Cách hiểu** | Phân tích ngữ nghĩa từ ngữ | Phân tích đặc điểm thị giác (Kiểu dáng, Màu sắc) |
| **Tình huống dùng** | Khi khách biết chức năng hoặc tầm giá mong muốn | Khi khách **chỉ có ảnh mẫu** mà không biết tên model |
| **Công nghệ lõi** | Text Embedding / Keyword Search | Image Embedding (CLIP/ResNet) |
