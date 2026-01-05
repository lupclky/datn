# Luồng Code: Phân công lắp đặt hỏa tốc (Express Installation Assignment)

Tài liệu này mô tả chi tiết luồng xử lý chức năng phân công nhân viên lắp đặt cho các đơn hàng "Hỏa tốc".

## 1. Tổng quan
Đối với các đơn hàng có phương thức vận chuyển là **"Hỏa tốc"**, hệ thống không tạo vận đơn tự động qua các đơn vị vận chuyển thứ ba (như GHN/GHTK). Thay vào đó, Admin sẽ phân công thủ công một nhân viên (Staff/Technician) để thực hiện giao hàng và lắp đặt.

## 2. Các thành phần tham gia
*   **Frontend (Angular):** `AdminOrderDetailComponent` - Giao diện quản lý đơn hàng của Admin.
*   **Backend (Spring Boot):**
    *   `OrderController`: Tiếp nhận yêu cầu API.
    *   `OrderService`: Xử lý nghiệp vụ phân công và gửi email.
    *   `EmailService`: Gửi email thông báo cho khách hàng.
*   **Database (MySQL):** Lưu trữ thông tin đơn hàng và nhân viên được phân công.

## 3. Chi tiết luồng xử lý

### Bước 1: Admin thực hiện phân công trên Frontend
*   **File:** `Frontend/src/app/features/admin/components/admin-order-detail/admin-order-detail.component.ts`
*   Admin mở chi tiết đơn hàng.
*   Hệ thống tải danh sách nhân viên (`getStaffList()`) có role là `STAFF`.
*   Admin chọn nhân viên và nhấn nút phân công.
*   Hàm `assignStaff()` được gọi, gửi request `PUT` tới API.

```typescript
// Frontend/src/app/features/admin/components/admin-order-detail/admin-order-detail.component.ts
assignStaff() {
  if (!this.selectedStaff) return;
  this.orderService.assignStaff(parseInt(this.id), this.selectedStaff.id).subscribe({
    next: () => {
      this.toastService.showSuccess('Thành công', 'Đã phân công nhân viên');
      // ...
    },
    // ...
  });
}
```

### Bước 2: Backend tiếp nhận yêu cầu
*   **File:** `Backend/src/main/java/com/example/Sneakers/controllers/OrderController.java`
*   Endpoint: `PUT /api/v1/orders/{id}/assign-staff`
*   Yêu cầu quyền hạn: `ROLE_ADMIN`.

```java
// Backend/src/main/java/com/example/Sneakers/controllers/OrderController.java
@PutMapping("/{id}/assign-staff")
@PreAuthorize("hasRole('ROLE_ADMIN')")
public ResponseEntity<?> assignStaff(@PathVariable("id") Long orderId, @RequestParam("staffId") Long staffId) {
    orderService.assignStaff(orderId, staffId);
    return ResponseEntity.ok(...);
}
```

### Bước 3: Xử lý nghiệp vụ (OrderService)
*   **File:** `Backend/src/main/java/com/example/Sneakers/services/OrderService.java`
*   Phương thức `assignStaff(Long orderId, Long staffId)` thực hiện:
    1.  Tìm đơn hàng theo ID.
    2.  Tìm nhân viên theo ID và kiểm tra xem có phải là `ROLE_STAFF` không.
    3.  Cập nhật trường `assignedStaff` của đơn hàng.
    4.  Lưu đơn hàng xuống Database.
    5.  Gửi email thông báo cho khách hàng.

```java
// Backend/src/main/java/com/example/Sneakers/services/OrderService.java
public void assignStaff(Long orderId, Long staffId) throws Exception {
    // ... Validate Order and Staff ...
    order.setAssignedStaff(staff);
    Order savedOrder = orderRepository.save(order);
    
    // Gửi email thông báo
    String subject = "Nhân viên lắp đặt đã được phân công - Đơn hàng #" + order.getId() + " - Locker Korea";
    String content = BuilderEmailContent.buildStaffAssignmentEmailContent(savedOrder);
    emailService.sendEmail(to, subject, content);
}
```

### Bước 4: Gửi Email thông báo
*   **File:** `Backend/src/main/java/com/example/Sneakers/utils/BuilderEmailContent.java`
*   Hàm `buildStaffAssignmentEmailContent` tạo nội dung email HTML chứa thông tin nhân viên (Tên, SĐT) để khách hàng tiện liên hệ.

## 4. Logic "Hỏa tốc"
Trong `AsyncOrderService.java`, logic tạo vận đơn tự động thường bỏ qua các đơn hàng "Hỏa tốc":
```java
if (!"Hỏa tốc".equalsIgnoreCase(order.getShippingMethod())) {
    // Logic tạo vận đơn tự động (nếu được bật)
}
```
Điều này đảm bảo quy trình xử lý riêng biệt: Đơn Hỏa tốc -> Phân công nhân viên nội bộ.
