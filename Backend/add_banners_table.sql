-- Create banners table
CREATE TABLE IF NOT EXISTS banners (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    image_url VARCHAR(500) NOT NULL,
    button_text VARCHAR(100),
    button_link VARCHAR(500),
    button_style VARCHAR(50) DEFAULT 'primary',
    display_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    start_date DATETIME,
    end_date DATETIME,
    created_at DATETIME,
    updated_at DATETIME
);

-- Create indexes for performance
CREATE INDEX idx_is_active ON banners(is_active);
CREATE INDEX idx_display_order ON banners(display_order);
CREATE INDEX idx_date_range ON banners(start_date, end_date);

-- Insert sample data
INSERT INTO banners (title, description, image_url, button_text, button_link, button_style, display_order, is_active, start_date, end_date, created_at, updated_at) VALUES
('Khóa thông minh Samsung', 'Công nghệ tiên tiến từ Hàn Quốc', 'banner1.jpg', 'Xem ngay', '/allProduct', 'primary', 1, TRUE, '2024-01-01 00:00:00', '2025-12-31 23:59:59', NOW(), NOW()),
('Khuyến mãi đặc biệt', 'Giảm giá lên đến 30%', 'banner2.jpg', 'Mua ngay', '/allProduct', 'danger', 2, TRUE, '2024-01-01 00:00:00', '2025-12-31 23:59:59', NOW(), NOW());



