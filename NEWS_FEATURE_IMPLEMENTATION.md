# Chức năng Tin tức - Tài liệu Triển khai

## Tổng quan
Đã triển khai đầy đủ chức năng xem tin tức cho người dùng và quản lý tin tức cho admin dựa trên bảng `news` có sẵn trong database_complete.sql.
Đã thêm tính năng chia sẻ tin tức lên Facebook Page.

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
  - Chia sẻ tin tức lên Facebook Page (`shareNewsToFacebook`)
- **IFacebookService.java** - Interface cho dịch vụ Facebook
- **FacebookService.java** - Implementation gọi Graph API để post bài

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
- `POST /api/v1/news/admin/{id}/share-facebook` - Chia sẻ tin tức lên Facebook

## Frontend (Angular)

### 1. Services
- **news.service.ts** - Service để gọi API:
  - Các method cho user endpoints
  - Các method cho admin endpoints
  - Method `shareToFacebook(id)` để gọi API chia sẻ

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
  - **Chia sẻ lên Facebook Page**
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

## Cấu hình Facebook

Cần thêm vào `application.yaml` hoặc biến môi trường:
```yaml
facebook:
  page-id: ${FACEBOOK_PAGE_ID}
  access-token: ${FACEBOOK_ACCESS_TOKEN}
```
