# Chương 4.3: Đánh giá Kết quả Thực nghiệm

Dựa trên quá trình kiểm thử hệ thống Chatbot tư vấn khóa thông minh, dưới đây là báo cáo chi tiết về độ chính xác của hệ thống trên hai tác vụ chính: Trả lời câu hỏi văn bản (Text QA) và Nhận diện hình ảnh (Visual QA).

## 4.3.1. Đánh giá khả năng trả lời Văn bản (Text QA)

Chúng tôi đã thực hiện bộ test gồm 10 câu hỏi ngẫu nhiên xoay quanh các tính năng, thông số và phân khúc sản phẩm khóa cửa.

**Bảng 4.1: Kết quả đánh giá Text Chatbot**

| STT | Câu hỏi của User | Kết quả Mong đợi | Kết quả AI Trả lời | Đánh giá |
|:---:|:---|:---|:---|:---:|
| 1 | Đây là sản phẩm gì? | Khóa cửa vân tay | Khóa cửa điện tử | ✅ |
| 2 | Khóa này thuộc hãng nào? | Samsung | Samsung | ✅ |
| 3 | Khóa này mở bằng cách nào? | Vân tay + mã số | Vân tay | ✅ |
| 4 | Đây có phải khóa push-pull không? | Có | Có | ✅ |
| 5 | Model khóa là gì? | Samsung SHS-1321 | Samsung SHS-1321 | ✅ |
| 6 | Khóa này thuộc phân khúc nào? | Tầm trung (Mong đợi) | Cao cấp (AI trả lời) | ❌ |
| 7 | Khóa này có kết nối app không? | Có (Mong đợi) | Không xác định (AI trả lời) | ❌ |
| 8 | Khóa này có tay gạt không? | Có | Có | ✅ |
| 9 | Khóa này dùng cho cửa gì? | Cửa gỗ | Cửa gỗ | ✅ |
| 10 | Khóa này có bàn phím số không? | Có | Có | ✅ |

### Tổng hợp kết quả Text QA:
*   **Số câu đúng:** 8/10
*   **Độ chính xác (Accuracy):** **80%**
*   **Nhận xét:** 
    *   Hệ thống trả lời tốt các câu hỏi về thông tin cơ bản (hãng, loại khóa, tính năng vật lý như tay gạt/bàn phím).
    *   Vẫn còn hạn chế với các câu hỏi mang tính phân loại trừu tượng (phân khúc giá) hoặc thông số kỹ thuật sâu (kết nối App) nếu dữ liệu trong Vector DB chưa đầy đủ context.

---

## 4.3.2. Đánh giá khả năng nhận diện Hình ảnh (Visual QA)

Chúng tôi sử dụng tập dữ liệu gồm 20 ảnh, bao gồm ảnh sản phẩm rõ nét, ảnh chụp thực tế chất lượng thấp, và ảnh nhiễu (không phải khóa) để kiểm tra độ bền vững của mô hình.

**Bảng 4.2: Kết quả đánh giá Image Retrieval**

| STT | Tên file ảnh | Kết quả Mong đợi | Kết quả AI Tìm kiếm | Đánh giá |
|:---:|:---|:---|:---|:---:|
| 1 | `samsung-shp-ds700...jpg` | Khóa vân tay Samsung | Khóa cửa Samsung | ✅ |
| 2 | `gateman_wf200.jpg` | Khóa Gateman | Khóa Gateman | ✅ |
| 3 | `kaiser-h7090...jpg` | Khóa push-pull | Khóa push-pull | ✅ |
| 4 | `EPIC809L.jpeg` | Khóa EPIC | Khóa EPIC | ✅ |
| 5 | `samsung-shp-dh538.jpg` | Samsung SHP-DH538 | Samsung DH538 | ✅ |
| 6 | `hione-h-5490sk.png` | Khóa vân tay | Khóa vân tay | ✅ |
| 7 | `hgang-sync-tr812.png` | Khóa tay gạt | Khóa tay gạt | ✅ |
| 8 | `WRT300_1_3-4.png` | Khóa vân tay | Khóa vân tay | ✅ |
| 9 | `TG330_1.jpg` | Khóa điện tử | Khóa điện tử | ✅ |
| 10 | `WG200.jpg` | Khóa cửa | **Không xác định** | ❌ |
| 11 | `samsung-2920_1_1.jpg` | Khóa Samsung | Khóa Samsung | ✅ |
| 12 | `samsung-shp-ds700...jpg` | Khóa Samsung | Khóa Samsung | ✅ |
| 13 | `s100dava-1.jpg` | Khóa điện tử | Khóa điện tử | ✅ |
| 14 | `khoa-cua-samsung...jpg` | Khóa vân tay | Khóa vân tay | ✅ |
| 15 | `kaiser-h7090...jpg` | Khóa push-pull | Khóa push-pull | ✅ |
| 16 | `samsung-SHS-1321...jpg` | Samsung SHS-1321 | Samsung SHS-1321 | ✅ |
| 17 | `7200B_5_3-4.png` | Không thuộc hệ thống | Không tìm thấy SP phù hợp | ✅ |
| 18 | `Cai ban.jpg` | Không thuộc hệ thống | Không tìm thấy SP phù hợp | ✅ |
| 19 | `cai ghe.png` | Không thuộc hệ thống | Không tìm thấy SP phù hợp | ✅ |
| 20 | `Chuong hinh samsung.jpg` | Chuông cửa Samsung | Chuông cửa | ✅ |

### Tổng hợp kết quả Visual QA:
*   **Số trường hợp đúng:** 19/20
*   **Độ chính xác (Accuracy):** **95%**
*   **Nhận xét:**
    *   Hệ thống hoạt động rất ổn định với khả năng nhận diện đúng 19/20 trường hợp.
    *   **Khả năng lọc nhiễu tốt:** Các trường hợp ảnh cái bàn, cái ghế (STT 18, 19) hoặc sản phẩm lạ (STT 17) đều được hệ thống trả về "Không tìm thấy", tránh việc tư vấn sai lệch.
    *   Nhận diện tốt cả các sản phẩm liên quan như Chuông cửa (STT 20).
    *   Một trường hợp sai (STT 10) có thể do ảnh đầu vào quá mờ hoặc góc chụp khó, khiến Vector không khớp với kho dữ liệu.

## 4.3.3. Kết luận chung
Hệ thống AI Chatbot tích hợp RAG đạt hiệu suất tổng thể khả quan:
*   Mô hình nhúng ảnh (Image Embedding) hoạt động xuất sắc (**95%**) trong việc truy vấn sản phẩm tương đồng.
*   Mô hình ngôn ngữ (LLM) trả lời văn bản ở mức khá (**80%**), cần cải thiện thêm về mặt cập nhật dữ liệu chi tiết (App, phân khúc) cho Context để đạt độ chính xác cao hơn.
