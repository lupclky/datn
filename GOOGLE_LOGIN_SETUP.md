# Hướng dẫn thiết lập Đăng nhập Google

## Tổng quan
Ứng dụng đã được tích hợp khả năng đăng nhập bằng Google. Tài liệu này hướng dẫn cách thiết lập và cấu hình.

## Backend (Spring Boot)

### 1. Dependencies đã được thêm vào `pom.xml`:
- `google-api-client` (v2.2.0)
- `google-auth-library-oauth2-http` (v1.19.0)

### 2. Endpoint mới:
- **POST** `/api/v1/users/login/google`
- Request body: `{ "id_token": "google_id_token_string" }`
- Response: `{ "message": "...", "token": "jwt_token" }`

### 3. Cách hoạt động:
- Backend nhận Google ID token từ frontend
- Xác minh token với Google
- Tạo hoặc đăng nhập user dựa trên Google account ID
- Trả về JWT token để frontend sử dụng

## Frontend (Angular)

### 1. Dependencies:
- Google Identity Services script đã được thêm vào `index.html`

### 2. Component đã được cập nhật:
- `login.component.ts`: Thêm logic xử lý Google Sign-In
- `login.component.html`: Thêm nút Google Sign-In
- `user.service.ts`: Thêm method `loginWithGoogle()`

### 3. Cấu hình cần thiết:

#### Bước 1: Tạo Google OAuth Client ID
1. Truy cập [Google Cloud Console](https://console.cloud.google.com/)
2. Tạo project mới hoặc chọn project hiện có
3. Vào **APIs & Services** > **Credentials**
4. Click **Create Credentials** > **OAuth client ID**
5. Chọn **Web application**
6. Thêm **Authorized JavaScript origins**:
   - `http://localhost:4200` (development)
   - `https://yourdomain.com` (production)
7. Thêm **Authorized redirect URIs**:
   - `http://localhost:4200` (development)
   - `https://yourdomain.com` (production)
8. Copy **Client ID** (có dạng: `xxxxx.apps.googleusercontent.com`)

#### Bước 2: Cập nhật Client ID trong code

**Frontend:**
Mở file `Frontend/src/app/features/auth/components/login/login.component.ts`
Tìm dòng:
```typescript
const clientId = 'YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com';
```
Thay thế `YOUR_GOOGLE_CLIENT_ID` bằng Client ID thực tế của bạn.

**Ví dụ:**
```typescript
const clientId = '123456789-abcdefghijklmnop.apps.googleusercontent.com';
```

### 4. Cài đặt dependencies (nếu chưa có):
```bash
cd Frontend
npm install
```

## Kiểm thử

1. Khởi động Backend:
```bash
cd Backend
mvn spring-boot:run
```

2. Khởi động Frontend:
```bash
cd Frontend
npm start
```

3. Truy cập trang đăng nhập: `http://localhost:4200/auth-login`
4. Click nút "Đăng nhập với Google"
5. Chọn tài khoản Google và cho phép quyền truy cập
6. Hệ thống sẽ tự động tạo tài khoản (nếu chưa có) hoặc đăng nhập

## Lưu ý

1. **Google Account ID**: Hệ thống sử dụng Google Account ID để liên kết tài khoản. Nếu user đã có email trong hệ thống, Google account sẽ được liên kết với tài khoản hiện có.

2. **Phone Number**: User đăng nhập bằng Google có thể không có số điện thoại. Hệ thống sẽ tự động tạo một số điện thoại giả định dạng `GOOGLE_xxxxx`.

3. **Password**: User đăng nhập bằng Google không cần mật khẩu.

4. **Role**: User mới đăng nhập bằng Google sẽ được gán role mặc định (role_id = 1, thường là CUSTOMER).

## Xử lý lỗi

- **"Google Sign-In chưa sẵn sàng"**: Đảm bảo script Google Identity Services đã được load trong `index.html`
- **"Invalid Google token"**: Kiểm tra Client ID đã được cấu hình đúng chưa
- **CORS errors**: Đảm bảo đã thêm domain vào Authorized JavaScript origins trong Google Cloud Console

## Bảo mật

- Không commit Client ID vào git repository
- Sử dụng environment variables cho production
- Đảm bảo HTTPS cho production environment







