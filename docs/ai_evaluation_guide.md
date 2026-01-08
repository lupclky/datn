# Hướng dẫn Kiểm thử & Đánh giá AI Chatbot (Dành cho Đồ án)

Đây là quy trình "cầm tay chỉ việc" để bạn thực hiện đánh giá độ chính xác (Accuracy) cho AI Chatbot của mình và đưa số liệu vào báo cáo.

## Bước 1: Chuẩn bị dữ liệu Test (Dataset)

Bạn cần chuẩn bị khoảng **20 - 30 trường hợp kiểm thử**. Cố gắng đa dạng hóa các tình huống:
*   5 ảnh khóa cửa rõ nét, chụp thẳng (từ catalogue hoặc ảnh thực tế).
*   5 ảnh khóa cửa chụp góc nghiêng, bị chói sáng hoặc hơi mờ.
*   5 ảnh **không phải khóa** (ví dụ: cái nồi, con mèo) -> Để test xem AI có nhận biết sai không.
*   5 câu hỏi về tính năng (Vân tay, Remote, App) để test `Generation`.
*   5 câu hỏi giao tiếp xã giao (ví dụ: "Shop ở đâu?") -> Test ngoại lệ.

## Bước 2: Kẻ bảng Excel để ghi nhận kết quả

Hãy tạo một file Excel với các cột như sau để chấm điểm. Bạn có thể copy mẫu bảng dưới đây vào báo cáo:

| STT | Ảnh Input | Câu hỏi của User | Kết quả Mong đợi | Kết quả Thực tế của AI | Tìm kiếm đúng? (1/0) | Trả lời đúng? (1/0) | Ghi chú |
|:---:|:---:|:---|:---|:---|:---:|:---:|:---|
| 1 | `samsung_dp609.jpg` | Khóa này có mở bằng App được ko? | Tìm ra Samsung SHP-DP609 | Tìm ra Samsung DP609. Có hỗ trợ App. | 1 | 1 | OK |
| 2 | `khoa_kaadas_s500.png` | Mẫu này giá bao nhiêu? | Tìm ra Kaadas S500 | Tìm ra Kaadas S500. Giá 4.5tr. | 1 | 1 | OK |
| 3 | `cai_ghe.jpg` | Cái này lắp cửa gỗ được không? | Không tìm thấy khóa nào | Không tìm thấy sản phẩm khóa nào trong ảnh. | 1 | 1 | Xử lý tốt ảnh rác |
| 4 | `anh_khoa_mo.jpg` | Khóa này của hãng nào? | Xiaomi | Nhầm sang khóa Yale | 0 | 0 | Ảnh mờ, nhận diện sai logo |
| ... | ... | ... | ... | ... | ... | ... | ... |

*   **Cột "Tìm kiếm đúng":** Điền `1` nếu AI tìm ra đúng mẫu khóa (Model) hoặc thông báo đúng là không tìm thấy. Điền `0` nếu tìm sai model.
*   **Cột "Trả lời đúng":** Điền `1` nếu câu trả lời văn bản hợp lý, đúng thông số kỹ thuật (Vân tay, thẻ từ...). Điền `0` nếu tư vấn sai tính năng.

## Bước 3: Tính toán chỉ số (Metrics)

Sau khi chạy xong ví dụ 20 test case, bạn dùng công thức sau để ra số liệu đưa vào slide:

### 1. Độ chính xác Tìm kiếm (Retrieval Accuracy)
Công thức: `(Tổng điểm cột Tìm kiếm đúng) / (Tổng số ca test) * 100%`
*Ví dụ: Đúng 18/20 ca = 90%*

### 2. Độ chính xác Trả lời (Generation Accuracy)
Công thức: `(Tổng điểm cột Trả lời đúng) / (Tổng số ca test) * 100%`
*Ví dụ: Đúng 17/20 ca = 85%*

## Bước 4: Viết vào Báo cáo/Slide

> **KẾT QUẢ THỰC NGHIỆM:**
>
> Chúng tôi đã tiến hành kiểm thử trên tập dữ liệu gồm **20 mẫu** (bao gồm ảnh chụp thực tế khóa đã lắp đặt và ảnh catalogue). Kết quả:
> *   **Khả năng nhận diện Model khóa:** 90%
> *   **Khả năng tư vấn tính năng:** 85%
>
> *Nhận xét:* Hệ thống nhận diện tốt các dòng khóa phổ biến (Samsung, Xiaomi) khi chụp chính diện. Với các loại khóa cơ tay gạt cũ hoặc ảnh chụp ngược sáng, độ chính xác giảm nhẹ.
