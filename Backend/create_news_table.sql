-- Tạo bảng news
CREATE TABLE IF NOT EXISTS news (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    content TEXT,
    summary VARCHAR(1000),
    author VARCHAR(100),
    category VARCHAR(50),
    status ENUM('DRAFT', 'PUBLISHED', 'ARCHIVED') NOT NULL DEFAULT 'DRAFT',
    featured_image VARCHAR(500),
    views BIGINT NOT NULL DEFAULT 0,
    published_at DATETIME,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Thêm một số dữ liệu mẫu
INSERT INTO news (title, content, summary, author, category, status, featured_image, views, published_at) VALUES
('Giới thiệu sản phẩm mới', 'Nội dung chi tiết về sản phẩm mới...', 'Tóm tắt về sản phẩm mới', 'Admin', 'Tin tức', 'PUBLISHED', 'news1.jpg', 150, NOW()),
('Hướng dẫn sử dụng', 'Hướng dẫn chi tiết cách sử dụng sản phẩm...', 'Tóm tắt hướng dẫn', 'Admin', 'Hướng dẫn', 'PUBLISHED', 'news2.jpg', 89, NOW()),
('Chương trình khuyến mãi', 'Thông tin về chương trình khuyến mãi...', 'Tóm tắt khuyến mãi', 'Admin', 'Khuyến mãi', 'PUBLISHED', 'news3.jpg', 200, NOW()),
('Tin tức bản nháp', 'Nội dung tin tức chưa xuất bản...', 'Tóm tắt tin nháp', 'Admin', 'Tin tức', 'DRAFT', NULL, 0, NULL);
