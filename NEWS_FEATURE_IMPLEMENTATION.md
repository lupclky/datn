# Chức năng Tin tức - Tài liệu Triển khai

## Tổng quan
Đã triển khai đầy đủ chức năng xem tin tức cho người dùng và quản lý tin tức cho admin dựa trên bảng `news` có sẵn trong database_complete.sql.

## Backend (Java Spring Boot)

### 1. Models & Entities
- **News.java** - Entity chính cho tin tức
  - Các trường: id, title, content, summary, author, category, status, featured_image, views, published_at, created_at, updated_at
- **NewsStatus.java** - Enum cho trạng thái tin tức (DRAFT, PUBLISHED, ARCHIVED)

### 2. DTOs & Responses
- **NewsDTO.java** - Data Transfer Object cho tin tức
- **NewsResponse.java** - Response object cho API
- **NewsListResponse.java** - Response object cho danh sách tin tức với phân trang

### 3. Repository
- **NewsRepository.java** - JPA Repository với các query methods:
  - `findByStatusOrderByPublishedAtDesc()` - Tìm tin tức theo trạng thái
  - `findByStatusAndCategoryOrderByPublishedAtDesc()` - Tìm theo danh mục
  - `findByStatusAndTitleContainingIgnoreCaseOrderByPublishedAtDesc()` - Tìm kiếm theo từ khóa
  - `incrementViews()` - Tăng số lượt xem
  - `findDistinctCategoriesByStatus()` - Lấy danh sách danh mục

### 4. Service Layer
- **INewsService.java** - Interface định nghĩa các method
- **NewsService.java** - Implementation với các chức năng:
  - CRUD operations (Create, Read, Update, Delete)
  - Publish và Archive tin tức
  - Tìm kiếm và lọc tin tức
  - Tăng lượt xem

### 5. Controller
- **NewsController.java** - REST API endpoints:

#### Endpoints cho User (Public):
- `GET /api/v1/news/published` - Lấy danh sách tin tức đã xuất bản
- `GET /api/v1/news/published/{id}` - Xem chi tiết tin tức (tự động tăng view)
- `GET /api/v1/news/published/search?keyword={keyword}` - Tìm kiếm tin tức
- `GET /api/v1/news/published/category/{category}` - Lọc theo danh mục
- `GET /api/v1/news/categories` - Lấy danh sách danh mục

#### Endpoints cho Admin (Protected):
- `GET /api/v1/news/admin/all` - Lấy tất cả tin tức (mọi trạng thái)
- `GET /api/v1/news/admin/{id}` - Xem chi tiết tin tức
- `POST /api/v1/news/admin` - Tạo tin tức mới
- `PUT /api/v1/news/admin/{id}` - Cập nhật tin tức
- `DELETE /api/v1/news/admin/{id}` - Xóa tin tức
- `PUT /api/v1/news/admin/{id}/publish` - Xuất bản tin tức
- `PUT /api/v1/news/admin/{id}/archive` - Lưu trữ tin tức

## Frontend (Angular)

### 1. Services
- **news.service.ts** - Service để gọi API:
  - Các method cho user endpoints
  - Các method cho admin endpoints
  - Sử dụng HttpClient và Observable

### 2. DTOs
- **news.dto.ts** - Interfaces:
  - `NewsDto` - Đối tượng tin tức
  - `NewsListResponse` - Response cho danh sách
  - `NewsCreateRequest` - Request tạo/cập nhật tin tức

### 3. Components

#### A. User Components

##### NewsComponent (Danh sách tin tức cho user)
- **Path**: `/news`
- **File**: `features/components/news/`
- **Tính năng**:
  - Hiển thị danh sách tin tức đã xuất bản
  - Tìm kiếm tin tức
  - Hiển thị tin tức mới nhất ở sidebar
  - Phân trang
  - Click để xem chi tiết

##### NewsDetailComponent (Chi tiết tin tức)
- **Path**: `/news/:id`
- **File**: `features/components/news-detail/`
- **Tính năng**:
  - Hiển thị nội dung đầy đủ tin tức
  - Tự động tăng lượt xem
  - Hiển thị tin tức liên quan (cùng danh mục)
  - Nút chia sẻ (Facebook, Twitter, WhatsApp)
  - Nút quay lại danh sách

#### B. Admin Component

##### NewsManageComponent (Quản lý tin tức)
- **Path**: `/newsManage` (Chỉ cho Admin)
- **File**: `features/components/news-manage/`
- **Tính năng**:
  - Bảng danh sách tất cả tin tức với PrimeNG Table
  - Tạo tin tức mới
  - Chỉnh sửa tin tức
  - Xóa tin tức (có xác nhận)
  - Xuất bản tin tức (DRAFT → PUBLISHED)
  - Lưu trữ tin tức (PUBLISHED → ARCHIVED)
  - Form nhập liệu với rich text editor (PrimeNG Editor)
  - Hiển thị trạng thái với badge màu
  - Phân trang

### 4. Routes
Đã cập nhật `app.routes.ts`:
```typescript
{
  path: 'news',
  component: NewsComponent
},
{
  path: 'news/:id',
  component: NewsDetailComponent
},
{
  path: 'newsManage',
  component: NewsManageComponent,
  canActivate: [RoleGuard]
}
```

### 5. Navigation Menu
Đã thêm link vào menu admin trong:
- **app-header.component.html** - Header chính
- **app-navbar.component.html** - Navbar

Icon: `pi-book` (PrimeIcons)
Label: "Tin tức"

## Cơ sở dữ liệu

Bảng `news` đã tồn tại trong database_complete.sql với cấu trúc:
```sql
CREATE TABLE `news` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `title` VARCHAR(500) NOT NULL,
    `content` TEXT,
    `summary` VARCHAR(1000),
    `author` VARCHAR(100),
    `category` VARCHAR(50),
    `status` ENUM('DRAFT', 'PUBLISHED', 'ARCHIVED') NOT NULL DEFAULT 'DRAFT',
    `featured_image` VARCHAR(500),
    `views` BIGINT NOT NULL DEFAULT 0,
    `published_at` DATETIME,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
)
```

Đã có 4 tin tức mẫu trong database.

## Hướng dẫn Sử dụng

### Cho Admin:
1. Đăng nhập với tài khoản admin (role_id = 2)
2. Vào menu "Tin tức" trong thanh điều hướng
3. Tại trang quản lý tin tức:
   - Click "Thêm tin tức" để tạo mới
   - Click icon bút chì để chỉnh sửa
   - Click icon check để xuất bản tin nháp
   - Click icon inbox để lưu trữ tin đã xuất bản
   - Click icon thùng rác để xóa (có xác nhận)

### Cho User:
1. Vào menu "Tin tức" trên header
2. Xem danh sách tin tức đã xuất bản
3. Sử dụng thanh tìm kiếm để tìm tin tức
4. Click vào tin tức để xem chi tiết
5. Xem tin tức liên quan ở cuối trang

## Tính năng Nổi bật

### Bảo mật:
- Admin endpoints được bảo vệ bằng `@PreAuthorize("hasRole('ROLE_ADMIN')")`
- User chỉ có thể xem tin tức đã PUBLISHED
- Admin có thể thấy tất cả trạng thái

### UX/UI:
- Responsive design (Bootstrap + custom CSS)
- Loading states
- Error handling với toast messages
- Confirmation dialogs cho thao tác nguy hiểm
- Rich text editor cho nội dung tin tức
- Badge màu sắc cho trạng thái
- Icons trực quan (PrimeIcons)

### Performance:
- Phân trang cho cả frontend và backend
- Lazy loading cho nội dung
- Tối ưu query với JPA

## Dependencies Đã sử dụng

### Backend:
- Spring Boot Data JPA
- Spring Boot Web
- Spring Boot Security
- Lombok
- MySQL Connector

### Frontend:
- Angular 18+
- PrimeNG (Table, Dialog, Editor, Toast, ConfirmDialog, Dropdown)
- PrimeIcons
- Bootstrap 5
- RxJS

## Testing

### Test Backend:
```bash
cd Backend
mvn test
```

### Test Frontend:
```bash
cd Frontend
npm test
```

### Chạy ứng dụng:

Backend:
```bash
cd Backend
mvn spring-boot:run
```

Frontend:
```bash
cd Frontend
npm start
```

## API Documentation

Tất cả endpoints sử dụng prefix: `/api/v1/news`

### Response Format:
```json
{
  "id": 1,
  "title": "Tiêu đề tin tức",
  "content": "Nội dung đầy đủ...",
  "summary": "Tóm tắt ngắn...",
  "author": "Tác giả",
  "category": "Danh mục",
  "status": "PUBLISHED",
  "featured_image": "url_to_image.jpg",
  "views": 150,
  "published_at": "2025-11-04 10:30:00",
  "created_at": "2025-11-03 15:20:00",
  "updated_at": "2025-11-04 10:30:00"
}
```

## Rich Text Editor - Giao diện như Microsoft Word

### Tính năng WYSIWYG Editor:
✅ **Text Formatting**:
- Bold, Italic, Underline, Strike-through
- Font types (Sans Serif, Serif, Monospace)
- Heading levels (H1, H2, H3)
- Text color & background color

✅ **Lists & Alignment**:
- Ordered lists (numbered)
- Unordered lists (bullets)
- Text alignment (left, center, right, justify)

✅ **Media & Links**:
- Insert images (URL)
- Insert videos (embed)
- Insert hyperlinks
- Code blocks
- Blockquotes

✅ **Clean Interface**:
- Toolbar giống Microsoft Word
- Preview real-time
- Copy/paste từ Word giữ nguyên format
- Responsive design

### Tránh SSR Issues:
- Editor chỉ load khi `isPlatformBrowser()` = true
- SSR mode sẽ hiển thị textarea fallback
- Development mode tắt SSR để tránh component ID collision
- Production build vẫn support SSR đầy đủ

## Ghi chú

1. **Hình ảnh**: Hiện tại sử dụng URL cho featured_image. Có thể mở rộng để upload file như sản phẩm.
2. **Rich Text Editor**: 
   - Sử dụng PrimeNG Editor (Quill.js v1.3.7)
   - Hỗ trợ đầy đủ định dạng văn bản, hình ảnh, video, link
   - Giao diện giống Microsoft Word
   - Auto-save draft trong localStorage (có thể thêm)
3. **SEO**: Content được render server-side với Angular Universal (đã có sẵn trong project).
4. **Mở rộng**: Có thể thêm:
   - Comments/bình luận
   - Tags/thẻ
   - Social sharing counts
   - Related news algorithm
   - Email notifications
   - Draft auto-save với localStorage

## Hoàn thành

✅ Backend: Models, DTOs, Repository, Service, Controller
✅ Frontend: Service, Components (List, Detail, Admin)
✅ Routes & Navigation
✅ UI/UX với PrimeNG
✅ Phân quyền Admin/User
✅ Tìm kiếm & Lọc
✅ Phân trang
✅ Responsive design

Tất cả chức năng đã được triển khai đầy đủ và sẵn sàng sử dụng!

