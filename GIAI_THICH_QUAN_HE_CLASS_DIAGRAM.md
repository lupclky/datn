# Giải Thích Các Quan Hệ Trong Biểu Đồ Lớp Phân Tích

## 📋 Tổng Quan

Biểu đồ sử dụng **Aggregation** (Tập hợp) - một loại quan hệ trong UML thể hiện mối quan hệ "has-a" (có một), trong đó đối tượng con có thể tồn tại độc lập với đối tượng cha.

**Ký hiệu:** `o--` (hollow diamond - hình thoi rỗng)

---

## 🔗 Các Quan Hệ Chi Tiết

### 1. **User ↔ Role**
```
User "*" o-- "1" Role
```

**Giải thích:**
- **Multiplicity:** Nhiều User (`*`) → 1 Role (`1`)
- **Ý nghĩa:** Một User có một Role, nhưng một Role có thể được gán cho nhiều User
- **Ví dụ:** 
  - User A có Role "ADMIN"
  - User B có Role "USER"
  - User C có Role "USER"
  - → Role "USER" được dùng bởi nhiều User

**Trong code:** `User` có thuộc tính `role` kiểu `Role`

---

### 2. **User ↔ Order**
```
User "1" o-- "*" Order
```

**Giải thích:**
- **Multiplicity:** 1 User (`1`) → Nhiều Order (`*`)
- **Ý nghĩa:** Một User có thể đặt nhiều Order, nhưng mỗi Order chỉ thuộc về một User
- **Ví dụ:**
  - User A đặt Order 1, Order 2, Order 3
  - → User A có 3 Order

**Trong code:** `Order` có thuộc tính `user` kiểu `User`

---

### 3. **User ↔ Cart**
```
User "1" o-- "*" Cart
```

**Giải thích:**
- **Multiplicity:** 1 User (`1`) → Nhiều Cart (`*`)
- **Ý nghĩa:** Một User có thể có nhiều mục trong giỏ hàng (Cart items), mỗi Cart item thuộc về một User
- **Ví dụ:**
  - User A có Cart item 1 (Product X, số lượng 2)
  - User A có Cart item 2 (Product Y, số lượng 1)
  - → User A có 2 Cart items

**Trong code:** `Cart` có thuộc tính `user` kiểu `User`

---

### 4. **User ↔ Review**
```
User "1" o-- "*" Review
```

**Giải thích:**
- **Multiplicity:** 1 User (`1`) → Nhiều Review (`*`)
- **Ý nghĩa:** Một User có thể viết nhiều Review, mỗi Review được viết bởi một User
- **Ví dụ:**
  - User A review Product X (5 sao)
  - User A review Product Y (4 sao)
  - → User A có 2 Review

**Trong code:** `Review` có thuộc tính `user` kiểu `User`

---

### 5. **Product ↔ Category**
```
Product "*" o-- "1" Category
```

**Giải thích:**
- **Multiplicity:** Nhiều Product (`*`) → 1 Category (`1`)
- **Ý nghĩa:** Nhiều Product thuộc về một Category, mỗi Product chỉ thuộc một Category
- **Ví dụ:**
  - Product "Nike Air Max" thuộc Category "Giày thể thao"
  - Product "Adidas Ultraboost" thuộc Category "Giày thể thao"
  - → Category "Giày thể thao" có nhiều Product

**Trong code:** `Product` có thuộc tính `category` kiểu `Category`

---

### 6. **Product ↔ ProductImage**
```
Product "1" o-- "*" ProductImage
```

**Giải thích:**
- **Multiplicity:** 1 Product (`1`) → Nhiều ProductImage (`*`)
- **Ý nghĩa:** Một Product có nhiều hình ảnh, mỗi ProductImage thuộc về một Product
- **Ví dụ:**
  - Product "Nike Air Max" có 5 hình ảnh (góc trước, góc sau, góc bên, ...)
  - → Product có nhiều ProductImage

**Trong code:** `ProductImage` có thuộc tính `product` kiểu `Product`

---

### 7. **Product ↔ ProductFeature**
```
Product "1" o-- "*" ProductFeature
```

**Giải thích:**
- **Multiplicity:** 1 Product (`1`) → Nhiều ProductFeature (`*`)
- **Ý nghĩa:** Một Product có nhiều tính năng (features), mỗi ProductFeature thuộc về một Product
- **Ví dụ:**
  - Product "Nike Air Max" có Feature "Khóa chống nước"
  - Product "Nike Air Max" có Feature "Khóa chống trộm"
  - → Product có nhiều ProductFeature

**Trong code:** `ProductFeature` có thuộc tính `product` kiểu `Product`

---

### 8. **Product ↔ Review**
```
Product "1" o-- "*" Review
```

**Giải thích:**
- **Multiplicity:** 1 Product (`1`) → Nhiều Review (`*`)
- **Ý nghĩa:** Một Product có thể được review bởi nhiều User, mỗi Review chỉ review một Product
- **Ví dụ:**
  - Product "Nike Air Max" có Review từ User A (5 sao)
  - Product "Nike Air Max" có Review từ User B (4 sao)
  - → Product có nhiều Review

**Trong code:** `Review` có thuộc tính `product` kiểu `Product`

---

### 9. **Order ↔ OrderDetail**
```
Order "1" o-- "*" OrderDetail
```

**Giải thích:**
- **Multiplicity:** 1 Order (`1`) → Nhiều OrderDetail (`*`)
- **Ý nghĩa:** Một Order chứa nhiều OrderDetail (chi tiết sản phẩm trong đơn), mỗi OrderDetail chỉ thuộc một Order
- **Ví dụ:**
  - Order 1 có OrderDetail 1 (Product X, số lượng 2, size 42)
  - Order 1 có OrderDetail 2 (Product Y, số lượng 1, size 40)
  - → Order có nhiều OrderDetail

**Trong code:** `OrderDetail` có thuộc tính `order` kiểu `Order`

**Lưu ý:** Quan hệ này có thể là **Composition** (hình thoi đen `*--`) vì OrderDetail không thể tồn tại độc lập nếu không có Order.

---

### 10. **OrderDetail ↔ Product**
```
OrderDetail "*" o-- "1" Product
```

**Giải thích:**
- **Multiplicity:** Nhiều OrderDetail (`*`) → 1 Product (`1`)
- **Ý nghĩa:** Nhiều OrderDetail có thể tham chiếu đến cùng một Product, mỗi OrderDetail chỉ tham chiếu một Product
- **Ví dụ:**
  - OrderDetail 1 (Order 1) tham chiếu Product "Nike Air Max"
  - OrderDetail 2 (Order 2) tham chiếu Product "Nike Air Max"
  - → Nhiều OrderDetail có thể tham chiếu cùng một Product

**Trong code:** `OrderDetail` có thuộc tính `product` kiểu `Product`

---

### 11. **Cart ↔ Product**
```
Cart "*" o-- "1" Product
```

**Giải thích:**
- **Multiplicity:** Nhiều Cart (`*`) → 1 Product (`1`)
- **Ý nghĩa:** Nhiều Cart items có thể tham chiếu đến cùng một Product, mỗi Cart item chỉ tham chiếu một Product
- **Ví dụ:**
  - Cart item 1 (User A) tham chiếu Product "Nike Air Max"
  - Cart item 2 (User B) tham chiếu Product "Nike Air Max"
  - → Nhiều Cart items có thể tham chiếu cùng một Product

**Trong code:** `Cart` có thuộc tính `product` kiểu `Product`

---

### 12. **ProductFeature ↔ LockFeature**
```
ProductFeature "*" o-- "1" LockFeature
```

**Giải thích:**
- **Multiplicity:** Nhiều ProductFeature (`*`) → 1 LockFeature (`1`)
- **Ý nghĩa:** Nhiều ProductFeature có thể sử dụng cùng một LockFeature, mỗi ProductFeature chỉ sử dụng một LockFeature
- **Ví dụ:**
  - ProductFeature 1 (Product X) sử dụng LockFeature "Khóa chống nước"
  - ProductFeature 2 (Product Y) sử dụng LockFeature "Khóa chống nước"
  - → Nhiều ProductFeature có thể sử dụng cùng một LockFeature

**Trong code:** `ProductFeature` có thuộc tính `feature` kiểu `LockFeature`

---

## 📊 Tóm Tắt Các Loại Quan Hệ

### Aggregation (Tập hợp) - `o--`
- **Đặc điểm:** Đối tượng con có thể tồn tại độc lập
- **Ví dụ:** Product và Category - Category vẫn tồn tại khi Product bị xóa

### Composition (Tổng hợp) - `*--` (hình thoi đen)
- **Đặc điểm:** Đối tượng con không thể tồn tại độc lập
- **Ví dụ:** Order và OrderDetail - OrderDetail không có ý nghĩa nếu không có Order

**Lưu ý:** Trong biểu đồ hiện tại, tất cả đều dùng Aggregation. Có thể cân nhắc đổi Order ↔ OrderDetail thành Composition.

---

## 🎯 Ý Nghĩa Thực Tế

### Quan hệ 1-nhiều (1 to Many):
- User → Order, Cart, Review
- Product → ProductImage, ProductFeature, Review
- Order → OrderDetail

### Quan hệ nhiều-1 (Many to 1):
- User → Role
- Product → Category
- OrderDetail → Product
- Cart → Product
- ProductFeature → LockFeature

### Quan hệ nhiều-nhiều (Many to Many):
- Không có trong biểu đồ này (cần lớp trung gian như ProductFeature để kết nối Product và LockFeature)

---

## ✅ Kiểm Tra Tính Đúng Đắn

1. **Multiplicity đúng:** Mỗi relationship có multiplicity rõ ràng (1, *, 0..1)
2. **Không trùng lặp:** Mỗi relationship chỉ định nghĩa một lần
3. **Logic hợp lý:** Các quan hệ phản ánh đúng mối quan hệ thực tế trong hệ thống
4. **Aggregation phù hợp:** Sử dụng aggregation cho các quan hệ "has-a" lỏng lẻo

---

## 🔧 Gợi Ý Cải Thiện

1. **Order ↔ OrderDetail:** Nên đổi thành **Composition** (`*--`) vì OrderDetail không thể tồn tại độc lập
2. **Product ↔ ProductImage:** Có thể đổi thành **Composition** nếu hình ảnh không có ý nghĩa khi không có Product
3. **Thêm relationships cho Banner và News:** Nếu cần, có thể thêm quan hệ với User (người tạo)








