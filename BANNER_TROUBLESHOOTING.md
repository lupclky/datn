# 🔧 Hướng dẫn khắc phục lỗi Banner Management

## ⚠️ Vấn đề thường gặp

### 1. **Hình ảnh banner không hiển thị**

**Nguyên nhân:**
- File ảnh chưa tồn tại trên server
- Đường dẫn API không đúng
- Sample data trong database chứa file ảnh không tồn tại

**Giải pháp:**

#### Option 1: Xóa sample data và tạo mới
```sql
-- Xóa sample banners
DELETE FROM banners WHERE id IN (1, 2);

-- Reset AUTO_INCREMENT
ALTER TABLE banners AUTO_INCREMENT = 1;
```

Sau đó vào trang `/bannerManage` và tạo banner mới bằng cách upload ảnh.

#### Option 2: Thêm ảnh mẫu vào server
1. Tạo thư mục `uploads/` trong Backend nếu chưa có
2. Copy các file ảnh mẫu vào thư mục này:
   - `banner1.jpg` (1920x600px)
   - `banner2.jpg` (1920x600px)

### 2. **Icons không hiển thị (3 dấu gạch ngang)**

**Nguyên nhân:**
- PrimeNG icons chưa load đúng
- CSS conflict

**Giải pháp:**
Đã được fix trong code với styling improvements:
```scss
::ng-deep {
  .p-button.p-button-rounded.p-button-text {
    width: 2.5rem;
    height: 2.5rem;
    
    .pi {
      font-size: 1rem;
    }
  }
}
```

### 3. **API không trả về dữ liệu**

**Kiểm tra:**
1. Backend đang chạy: `http://localhost:8080`
2. Database đã có table `banners`
3. API endpoint hoạt động:
   ```
   GET http://localhost:8080/api/v1/banners
   GET http://localhost:8080/api/v1/banners/active
   ```

**Test API:**
```bash
# Test get all banners
curl http://localhost:8080/api/v1/banners

# Test get active banners
curl http://localhost:8080/api/v1/banners/active
```

## 📝 Checklist Setup Banner

- [ ] Database table `banners` đã được tạo
- [ ] Thư mục `uploads/` tồn tại và có quyền write
- [ ] Backend đang chạy trên port 8080
- [ ] Frontend environment.apiUrl đúng: `http://localhost:8080/api/v1`
- [ ] Đã xóa sample data nếu không có file ảnh tương ứng
- [ ] Tạo banner mới với ảnh upload từ UI

## 🎯 Hướng dẫn tạo Banner đầu tiên

1. **Chuẩn bị ảnh:**
   - Kích thước: 1920 x 600 pixels (khuyến nghị)
   - Định dạng: JPG, PNG, hoặc WebP
   - Dung lượng: < 500KB (tối đa 5MB)

2. **Vào trang quản lý:**
   - Truy cập: `/bannerManage`
   - Yêu cầu: Đăng nhập với quyền Admin

3. **Tạo banner:**
   - Click "Thêm Banner"
   - Điền thông tin:
     - Tiêu đề (bắt buộc)
     - Mô tả
     - Upload hình ảnh (bắt buộc)
     - Text nút bấm (VD: "Xem ngay")
     - Link nút bấm (VD: "/allProduct")
     - Kiểu nút: Primary, Danger, Success, Warning, Info
     - Thứ tự hiển thị: 0, 1, 2...
     - Trạng thái: Kích hoạt
     - Thời gian bắt đầu/kết thúc
   - Click "Tạo mới"

4. **Kiểm tra:**
   - Vào trang Home (`/`)
   - Banner sẽ hiển thị trong carousel

## 🐛 Debug

### Mở Developer Console (F12)

**Check Network:**
```
GET http://localhost:8080/api/v1/banners - Status 200 OK
GET http://localhost:8080/api/v1/banners/images/[filename] - Status 200 OK
```

**Check Console Errors:**
Nếu thấy lỗi như:
- `404 Not Found` → File ảnh không tồn tại
- `403 Forbidden` → Lỗi authentication
- `500 Internal Server Error` → Lỗi backend

**Xem Response Data:**
```json
{
  "message": "Banners retrieved successfully",
  "banners": [
    {
      "id": 1,
      "title": "Khóa thông minh Samsung",
      "image_url": "abc123_banner.jpg",
      "is_active": true
    }
  ],
  "total": 1
}
```

## 🔄 Reset hoàn toàn

Nếu muốn bắt đầu lại từ đầu:

```sql
-- 1. Drop và tạo lại table
DROP TABLE IF EXISTS banners;

-- 2. Chạy lại migration script
SOURCE Backend/add_banners_table.sql;

-- 3. XÓA sample data
DELETE FROM banners;
```

Sau đó tạo banner mới từ UI với ảnh upload.

## ✅ Expected Result

Sau khi setup đúng:
- Table banner hiển thị đầy đủ dữ liệu
- Hình ảnh hiển thị rõ ràng
- 3 buttons (Edit ✏️, Toggle 👁️, Delete 🗑️) hoạt động
- Home page hiển thị carousel với banners












