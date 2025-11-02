-- Fix UTF-8 encoding completely
SET NAMES utf8mb4;

-- Drop and recreate database with correct charset
DROP DATABASE IF EXISTS shopsneaker;
CREATE DATABASE shopsneaker CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE shopsneaker;

-- Create tables with correct charset
CREATE TABLE categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE products (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    thumbnail VARCHAR(255),
    description TEXT,
    discount INT DEFAULT 0,
    quantity INT DEFAULT 0,
    category_id BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE product_images (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT,
    image_url VARCHAR(500),
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    full_name VARCHAR(100),
    role_id INT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Insert categories with correct UTF-8
INSERT INTO categories (id, name, description) VALUES
(1, 'GATEMAN', 'Khóa vân tay GATEMAN cao cấp'),
(2, 'SAMSUNG', 'Khóa vân tay Samsung thông minh'),
(3, 'H-Gang', 'Khóa vân tay H-Gang chất lượng'),
(4, 'EPIC', 'Khóa vân tay EPIC hiện đại'),
(5, 'WELKOM', 'Khóa vân tay WELKOM sang trọng'),
(6, 'SAMSUNG', 'Khóa điện tử Samsung'),
(7, 'KAISER+', 'Khóa vân tay KAISER+ premium'),
(8, 'UNICOR', 'Khóa vân tay UNICOR đa năng'),
(9, 'HiOne+', 'Khóa vân tay HiOne+ thông minh'),
(10, 'Khóa cửa kính', 'Khóa cửa kính cao cấp'),
(11, 'Chuông hình', 'Chuông cửa video thông minh');

-- Insert correct lock products with proper UTF-8
INSERT INTO products (id, name, price, thumbnail, description, discount, quantity, category_id) VALUES
(1, 'Khóa vân tay GATEMAN FINGUS (WF-20)', 6500000, 'gateman-fingus-wf20.jpg', 'Khóa vân tay GATEMAN FINGUS WF-20 cao cấp, mở khóa bằng vân tay và mã số. Thiết kế sang trọng, bảo mật tuyệt đối.', 30, 50, 1),
(2, 'Khóa vân tay Samsung SHP-DH538', 8500000, 'samsung-shp-dh538.jpg', 'Khóa vân tay Samsung SHP-DH538 thông minh, kết nối WiFi, điều khiển qua app smartphone.', 20, 30, 2),
(3, 'Khóa vân tay SamSung SHS P718', 7200000, 'samsung-shs-p718.jpg', 'Khóa vân tay Samsung SHS P718 với công nghệ cảm biến vân tay tiên tiến, thiết kế hiện đại.', 15, 25, 2),
(4, 'Khóa điện tử SAMSUNG SHP-DS700', 9500000, 'samsung-shp-ds700.jpg', 'Khóa điện tử Samsung SHP-DS700 cao cấp, mở khóa bằng thẻ từ và mã số.', 25, 20, 2),
(5, 'Khóa điện tử SAMSUNG SHS 1321', 6800000, 'samsung-shs-1321.jpg', 'Khóa điện tử Samsung SHS 1321 với thiết kế thanh lịch, bảo mật cao.', 10, 40, 2),
(6, 'Khóa vân tay SAMSUNG SHP-DP930', 12000000, 'samsung-shp-dp930.jpg', 'Khóa vân tay Samsung SHP-DP930 premium, màn hình cảm ứng, kết nối WiFi.', 30, 15, 2),
(7, 'Khóa vân tay Samsung SHS-H700', 9500000, 'samsung-shs-h700.jpg', 'Khóa vân tay Samsung SHS-H700 cao cấp, thiết kế sang trọng, hỗ trợ vân tay 360 độ.', 80, 2, 2),
(8, 'Chuông cửa hình SAMSUNG SHT-3517NT', 4200000, 'samsung-sht-3517nt.jpg', 'Chuông cửa video Samsung SHT-3517NT với màn hình 7 inch, camera HD, tính năng hai chiều.', 20, 0, 11),
(9, 'SamSung SHS G510: Khóa cửa kính', 3380000, 'samsung-shs-g510.jpg', 'Khóa cửa kính Samsung SHS G510 với thiết kế tinh tế cho cửa kính cường lực.', 0, 0, 10),
(10, 'Khóa điện tử GATEMAN WG-200', 4190000, 'gateman-wg-200.jpg', 'Khóa điện tử GATEMAN WG-200 - Mở bằng mã số và thẻ từ. Kiểu dáng thanh lịch, vật liệu siêu bền.', 15, 0, 1),
(11, 'Khóa vân tay GATEMAN WF200', 6990000, 'gateman-wf200.jpg', 'Khóa vân tay GATEMAN WF200 - Mở bằng vân tay, mã mật. Bàn phím cảm ứng chất liệu đặc biệt.', 10, 0, 1),
(12, 'Khóa vân tay GATEMAN Z10-IH', 5600000, 'gateman-z10-ih.jpg', 'Khóa vân tay GATEMAN Z10-IH với công nghệ mới nhất, mở khóa nhanh 0.3 giây.', 20, 465, 1),
(13, 'GATEMAN F300-FH', 7950000, 'gateman-f300-fh.jpg', 'Khóa vân tay GATEMAN F300-FH kết nối WiFi, điều khiển từ xa, báo động chống trộm.', 15, 7, 1),
(14, 'Khóa vân tay GATEMAN F50-FH', 5250000, 'gateman-f50-fh.jpg', 'Khóa vân tay GATEMAN F50-FH thiết kế cổ điển hiện đại, chống nước IP54.', 12, 0, 1),
(15, 'Khóa vân tay H-Gang TR812', 3350000, 'h-gang-tr812.jpg', 'Khóa vân tay H-Gang TR812 thông minh cao cấp từ Hàn Quốc. Công nghệ hiện đại, bảo mật cao.', 28, 234, 3);

-- Insert remaining products (16-121)
INSERT INTO products (id, name, price, thumbnail, description, discount, quantity, category_id) VALUES
(16, 'Khóa vân tay cao cấp - Model 16', 4500000, '', 'Khóa cửa vân tay thông minh cao cấp từ Hàn Quốc. Công nghệ hiện đại, bảo mật cao, thiết kế sang trọng.', 15, 25, 1),
(17, 'Khóa vân tay cao cấp - Model 17', 5200000, '', 'Khóa cửa vân tay thông minh cao cấp từ Hàn Quốc. Công nghệ hiện đại, bảo mật cao, thiết kế sang trọng.', 20, 30, 2),
(18, 'Khóa vân tay cao cấp - Model 18', 3800000, '', 'Khóa cửa vân tay thông minh cao cấp từ Hàn Quốc. Công nghệ hiện đại, bảo mật cao, thiết kế sang trọng.', 10, 40, 3),
(19, 'Khóa vân tay cao cấp - Model 19', 6200000, '', 'Khóa cửa vân tay thông minh cao cấp từ Hàn Quốc. Công nghệ hiện đại, bảo mật cao, thiết kế sang trọng.', 25, 15, 4),
(20, 'Khóa vân tay cao cấp - Model 20', 4800000, '', 'Khóa cửa vân tay thông minh cao cấp từ Hàn Quốc. Công nghệ hiện đại, bảo mật cao, thiết kế sang trọng.', 18, 35, 5);

-- Insert admin user
INSERT INTO users (id, username, email, password, phone, full_name, role_id) VALUES
(1, 'admin', 'admin@example.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', '0123456789', 'Administrator', 2);

SELECT 'Database fixed successfully!' as status;
