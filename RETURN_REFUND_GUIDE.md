# Quy trình Trả hàng và Hoàn tiền (Return & Refund Flow)

Tài liệu này mô tả quy trình xử lý yêu cầu trả hàng và hoàn tiền trong hệ thống Locker Korea, bao gồm 3 hình thức thanh toán chính: Stripe, VNPAY, và COD (Thanh toán khi nhận hàng).

## Biểu đồ tuần tự (Sequence Diagram)

Biểu đồ PlantUML: [RETURN_REFUND_SEQUENCE.puml](./RETURN_REFUND_SEQUENCE.puml)

## Chi tiết quy trình

### 1. Người dùng tạo yêu cầu trả hàng
- **Actor**: User
- **API**: `POST /api/v1/returns`
- **Điều kiện**:
  - Đơn hàng phải có trạng thái `delivered`, `success`, hoặc `shipped`.
  - Thời gian từ lúc đặt hàng không quá 30 ngày.
  - Đơn hàng chưa có yêu cầu trả hàng nào trước đó.
- **Kết quả**: Hệ thống tạo `ReturnRequest` với trạng thái `PENDING`.

### 2. Admin duyệt yêu cầu (Approve)
- **Actor**: Admin/Staff
- **API**: `PUT /api/v1/returns/admin/{id}/approve`
- **Hành động**: Admin xem xét lý do và chấp nhận yêu cầu trả hàng.
- **Xử lý theo phương thức thanh toán**:

#### a. Thanh toán qua Stripe (Thẻ Visa/Mastercard)
- **Cơ chế**: Hoàn tiền tự động (Auto Refund).
- **Luồng xử lý**:
  1. Hệ thống gọi API của Stripe để hoàn tiền dựa trên `paymentIntentId`.
  2. Nếu thành công, cập nhật trạng thái `ReturnRequest` thành `REFUNDED`.
  3. Cập nhật trạng thái `Order` thành `canceled`.
  4. Phản hồi thành công cho Admin.

#### b. Thanh toán qua VNPAY
- **Cơ chế**: Hoàn tiền bán tự động (Semi-auto).
- **Luồng xử lý**:
  1. Khi Admin duyệt (`approve`), hệ thống cập nhật trạng thái `ReturnRequest` thành `AWAITING_REFUND` và `Order` thành `awaiting_refund`.
  2. Admin sau đó gọi API riêng để thực hiện hoàn tiền VNPAY: `POST /api/v1/vnpay/refund`.
  3. Hệ thống gọi API của VNPAY để xử lý hoàn tiền.
  4. Nếu VNPAY trả về mã thành công (`00`), hệ thống cập nhật trạng thái `ReturnRequest` thành `REFUNDED` và `Order` thành `canceled`.

#### c. Thanh toán COD (Tiền mặt)
- **Cơ chế**: Hoàn tiền thủ công (Manual).
- **Luồng xử lý**:
  1. Khi Admin duyệt (`approve`), hệ thống cập nhật trạng thái `ReturnRequest` thành `AWAITING_REFUND` và `Order` thành `awaiting_refund`.
  2. Admin thực hiện chuyển khoản ngân hàng thủ công cho khách hàng bên ngoài hệ thống.
  3. Sau khi chuyển khoản xong, Admin gọi API xác nhận hoàn tất: `PUT /api/v1/returns/admin/{id}/complete-refund`.
  4. Hệ thống cập nhật trạng thái `ReturnRequest` thành `REFUNDED` và `Order` thành `canceled`.

### 3. Admin từ chối yêu cầu (Reject)
- **Actor**: Admin/Staff
- **API**: `PUT /api/v1/returns/admin/{id}/reject`
- **Kết quả**:
  - Cập nhật trạng thái `ReturnRequest` thành `REJECTED`.
  - Đơn hàng giữ nguyên trạng thái hoặc quay về `delivered`.
