# Hướng dẫn Import Sơ đồ Lớp vào Visual Paradigm

Tôi đã tạo sơ đồ lớp phân tích toàn hệ thống dựa trên mã nguồn Backend (Spring Boot Entities). Sơ đồ này bao gồm các lớp, thuộc tính và các mối quan hệ (Aggregation, Composition, Association).

## File Sơ đồ
File PlantUML đã được tạo tại:
`D:\do_an_tot_nghiep\locker_korea\LockerKorea_Analysis_Class_Diagram.puml`

## Cách Import vào Visual Paradigm

1.  Mở **Visual Paradigm**.
2.  Trên thanh menu, chọn **Tools** > **Import** > **PlantUML...**.
3.  Trong hộp thoại Import:
    *   Chọn file `LockerKorea_Analysis_Class_Diagram.puml` từ đường dẫn trên.
4.  Nhấn **Import**.
5.  Visual Paradigm sẽ tạo ra sơ đồ lớp từ file này.

## Giải thích ký hiệu trong sơ đồ
*   **Composition (Hình thoi đen `*--`)**: Thể hiện mối quan hệ chặt chẽ (ví dụ: `Order` và `OrderDetail`). Nếu đối tượng cha bị xóa, đối tượng con cũng bị xóa (dựa trên `CascadeType.ALL` trong code).
*   **Aggregation (Hình thoi trắng `o--`)**: Thể hiện mối quan hệ lỏng lẻo hơn (ví dụ: `Voucher` và `Order`).
*   **Association (Mũi tên `-->`)**: Mối quan hệ tham chiếu thông thường.
