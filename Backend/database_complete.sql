-- ============================================
-- Complete Database Setup for Shop Locks System
-- Merged from: shopsneaker3.sql, create_news_table.sql, 
--              update_real_lock_names.sql, update_to_lock_theme.sql,
--              update_product_images.sql
-- Created: November 3, 2025
-- ============================================

-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Máy chủ: mysql8-container
-- Thời gian đã tạo: Th6 13, 2025 lúc 11:59 AM
-- Phiên bản máy phục vụ: 8.2.0
-- Phiên bản PHP: 8.2.27

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";
SET FOREIGN_KEY_CHECKS=0;

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Cơ sở dữ liệu: `shopsneaker3`
--

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `carts`
--

DROP TABLE IF EXISTS `carts`;
CREATE TABLE `carts` (
  `id` bigint NOT NULL,
  `user_id` int DEFAULT NULL,
  `product_id` int DEFAULT NULL,
  `quantity` bigint DEFAULT NULL,
  `size` bigint DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Đang đổ dữ liệu cho bảng `carts`
--

INSERT INTO `carts` (`id`, `user_id`, `product_id`, `quantity`, `size`) VALUES
(12, 14, 11, 1, 43);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `categories`
--

DROP TABLE IF EXISTS `categories`;
CREATE TABLE `categories` (
  `id` int NOT NULL,
  `name` varchar(100) NOT NULL DEFAULT '' COMMENT 'Tên danh mục, vd: đồ điện tử'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Đang đổ dữ liệu cho bảng `categories`
--

INSERT INTO `categories` (`id`, `name`) VALUES
(1, 'GATEMAN'),
(2, 'SAMSUNG'),
(3, 'H-Gang'),
(4, 'EPIC'),
(5, 'WELKOM'),
(7, 'KAISER+'),
(8, 'UNICOR'),
(9, 'HiOne+'),
(10, 'Khóa cửa kính'),
(11, 'Chuông hình');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `orders`
--

DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders` (
  `id` int NOT NULL,
  `user_id` int DEFAULT NULL,
  `fullname` varchar(100) DEFAULT '',
  `email` varchar(100) DEFAULT '',
  `phone_number` varchar(20) NOT NULL,
  `address` varchar(200) NOT NULL,
  `note` varchar(100) DEFAULT '',
  `order_date` datetime DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `total_money` bigint DEFAULT NULL,
  `shipping_method` varchar(100) DEFAULT NULL,
  `shipping_date` date DEFAULT NULL,
  `payment_method` varchar(100) DEFAULT NULL,
  `active` tinyint(1) DEFAULT NULL,
  `voucher_id` int DEFAULT NULL,
  `discount_amount` bigint DEFAULT '0',
  `payment_intent_id` varchar(255) DEFAULT NULL,
  `vnp_txn_ref` varchar(255) DEFAULT NULL,
  `vnp_transaction_no` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Đang đổ dữ liệu cho bảng `orders`
--

INSERT INTO `orders` (`id`, `user_id`, `fullname`, `email`, `phone_number`, `address`, `note`, `order_date`, `status`, `total_money`, `shipping_method`, `shipping_date`, `payment_method`, `active`, `voucher_id`, `discount_amount`, `payment_intent_id`, `vnp_txn_ref`, `vnp_transaction_no`) VALUES
(1, 1, 'Trần Đức Em', 'ducanh21112003@gmail.com', '0865247233', 'Hanoi', '', NULL, NULL, 1000000, 'express', NULL, 'cod', 1, NULL, 0, NULL, NULL, NULL),
(2, 1, 'Lưu Thuỳ Linh', 'chill@gmail.com', '0123456789', 'Hanoi', 'Hàng dễ vỡ xin nhẹ tay', '2024-02-19 10:30:00', 'shipped', 1000001, 'express', '2024-02-19', 'cod', 1, NULL, 0, NULL, NULL, NULL),
(92, 18, 'Truong Quang Lap', 'secroramot123@gmail.com', '0854768836', 'Mình Loc', 'àdasfadsfdsafsadfasdf', '2025-06-13', 'canceled', 29030000, 'Tiêu chuẩn', '2025-06-16', 'Thanh toán thẻ thành công', 1, NULL, 0, 'pi_3RZW4FRoKh7pvaZe1sbaN2MH', NULL, NULL);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `order_details`
--

DROP TABLE IF EXISTS `order_details`;
CREATE TABLE `order_details` (
  `id` bigint NOT NULL,
  `order_id` int DEFAULT NULL,
  `product_id` int DEFAULT NULL,
  `price` bigint NOT NULL,
  `number_of_products` bigint NOT NULL,
  `total_money` bigint DEFAULT NULL,
  `size` bigint DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Đang đổ dữ liệu cho bảng `order_details`
--

INSERT INTO `order_details` (`id`, `order_id`, `product_id`, `price`, `number_of_products`, `total_money`, `size`) VALUES
(1, 2, 1, 798000, 2, 1596000, 43),
(2, 1, 3, 990000, 1, 3000000, 44),
(125, 92, 5784, 29000000, 1, 29000000, 36);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `lock_features`
--

DROP TABLE IF EXISTS `lock_features`;
CREATE TABLE `lock_features` (
  `id` bigint NOT NULL,
  `name` varchar(100) NOT NULL COMMENT 'Tên chức năng',
  `description` text COMMENT 'Mô tả chức năng',
  `is_active` tinyint(1) DEFAULT '1' COMMENT 'Trạng thái hoạt động',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Đang đổ dữ liệu cho bảng `lock_features`
--

INSERT INTO `lock_features` (`id`, `name`, `description`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'Mở khóa vân tay', 'Nhận diện và mở khóa bằng vân tay', 1, '2025-06-13 12:00:00', '2025-06-13 12:00:00'),
(2, 'Mở khóa mã PIN', 'Nhập mã PIN để mở khóa', 1, '2025-06-13 12:00:00', '2025-06-13 12:00:00'),
(3, 'Mở khóa thẻ từ', 'Quẹt thẻ từ để mở khóa', 1, '2025-06-13 12:00:00', '2025-06-13 12:00:00'),
(4, 'Kết nối Bluetooth', 'Kết nối và điều khiển qua Bluetooth', 1, '2025-06-13 12:00:00', '2025-06-13 12:00:00'),
(5, 'Kết nối WiFi', 'Kết nối và điều khiển qua WiFi', 1, '2025-06-13 12:00:00', '2025-06-13 12:00:00'),
(6, 'Chống nước', 'Có khả năng chống nước', 1, '2025-06-13 12:00:00', '2025-06-13 12:00:00'),
(7, 'Cảnh báo an ninh', 'Cảnh báo khi có xâm nhập', 1, '2025-06-13 12:00:00', '2025-06-13 12:00:00');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `products`
--

DROP TABLE IF EXISTS `products`;
CREATE TABLE `products` (
  `id` int NOT NULL,
  `name` varchar(350) DEFAULT NULL COMMENT 'Tên sản phẩm',
  `price` bigint NOT NULL DEFAULT '0',
  `thumbnail` varchar(300) DEFAULT '',
  `description` longtext,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `category_id` int DEFAULT NULL,
  `discount` bigint DEFAULT NULL,
  `quantity` bigint DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Đang đổ dữ liệu cho bảng `products`
--

INSERT INTO `products` (`id`, `name`, `price`, `thumbnail`, `description`, `created_at`, `updated_at`, `category_id`, `discount`, `quantity`) VALUES
(1, 'Khóa vân tay GATEMAN FINGUS (WF-20)', 6500000, 'WF20_1 3-4.jpg', 'Khóa vân tay GATEMAN WF-20 - Mở khóa bằng vân tay hoặc mật mã. Cài đặt 20 vân tay, 03 mã số.', '2024-02-16 16:46:58', '2025-06-13 06:34:32', 1, 30, 51),
(2, 'Khóa vân tay Samsung SHP-DH538', 5490000, 'DH538_co 3-4.jpg', 'Khóa vân tay Samsung SHP-DH538 - Mở bằng vân tay, mã số, chìa cơ dự phòng. Chống nước, thiết kế hiện đại.', '2024-02-17 07:35:46', '2025-06-13 06:07:57', 2, 20, 4),
(3, 'Khóa vân tay SamSung SHS P718', 8500000, 'SHS-P718_3-4.png', 'Khóa vân tay Samsung SHS P718 với công nghệ cảm biến vân tay tiên tiến, thiết kế hiện đại.', '2024-02-17 07:35:46', '2025-06-13 11:41:35', 2, 60, 8),
(4, 'Khóa SAMSUNG SHS-2920', 4200000, 'SHS-2920_1.jpg', 'Khóa SAMSUNG SHS-2920 - Khóa điện tử mã số, thiết kế đơn giản, phù hợp mọi loại cửa.', '2024-02-17 07:35:46', '2024-02-17 07:35:46', 2, NULL, 0),
(5, 'Khóa điện tử SAMSUNG SHP-DS700', 3290000, 'SHP-DS700_1.jpg', 'Khóa điện tử Samsung SHP-DS700 cao cấp, mở khóa bằng thẻ từ và mã số.', '2024-02-17 07:35:46', '2025-06-13 10:03:43', 2, 60, 48),
(6, 'Khóa điện tử SAMSUNG SHS 1321', 3480000, '1321-1-3-4.jpg', 'Khóa điện tử Samsung SHS 1321 với thiết kế thanh lịch, bảo mật cao.', '2024-02-17 07:35:46', '2025-06-13 07:07:29', 2, 5, 333),
(7, 'Khóa vân tay SAMSUNG SHP-DP930', 12000000, 'SAMSUNG DP920.jpg', 'Khóa vân tay Samsung SHP-DP930 premium, màn hình cảm ứng, kết nối WiFi.', '2024-02-17 07:35:46', '2024-02-17 07:35:46', 2, NULL, 50),
(8, 'Khóa vân tay Samsung SHS-H700', 9500000, '700_mat ngoaiw.png', 'Khóa vân tay Samsung SHS-H700 cao cấp, thiết kế sang trọng, hỗ trợ vân tay 360 độ.', '2024-02-17 07:35:46', '2025-06-13 06:20:04', 2, 80, 2),
(9, 'Chuông cửa hình SAMSUNG SHT-3517NT', 4200000, 'sht-3517nt-1.jpg', 'Chuông cửa video Samsung SHT-3517NT với màn hình 7 inch, camera HD, tính năng hai chiều.', '2024-02-17 07:35:46', '2025-06-13 08:11:55', 11, 20, 0),
(10, 'SamSung SHS G510: Khóa cửa kính', 3380000, 'SAMSUNG SHS G510_5.jpg', 'Khóa cửa kính Samsung SHS G510 với thiết kế tinh tế cho cửa kính cường lực.', '2024-02-17 07:35:46', '2024-02-17 07:35:46', 10, NULL, 0),
(11, 'Khóa điện tử GATEMAN WG-200', 4190000, 'wg-200 3-4.jpg', 'Khóa điện tử GATEMAN WG-200 - Mở bằng mã số và thẻ từ. Kiểu dáng thanh lịch, vật liệu siêu bền.', '2024-02-17 07:35:46', '2024-02-17 07:35:46', 1, NULL, 0),
(12, 'Khóa vân tay GATEMAN WF200', 6990000, 'wf-200_34.jpg', 'Khóa vân tay GATEMAN WF200 - Mở bằng vân tay, mật mã. Bàn phím cảm ứng chất liệu đặc biệt, bền, sang trọng.', '2024-02-17 07:35:46', '2024-02-17 07:35:46', 1, NULL, 0),
(13, 'Khóa vân tay GATEMAN Z10-IH', 5600000, 'Z10_3 3-4.jpg', 'Khóa vân tay GATEMAN Z10-IH với công nghệ mới nhất, mở khóa nhanh 0.3 giây.', '2024-02-17 07:35:46', '2025-06-13 06:19:12', 4, 4, 465),
(14, 'GATEMAN F300-FH', 7950000, 'Gateman F300-FH.jpg', 'Khóa vân tay GATEMAN F300-FH kết nối WiFi, điều khiển từ xa, báo động chống trộm.', '2024-02-17 07:35:46', '2025-06-13 11:34:06', 1, 60, 7),
(15, 'Khóa vân tay GATEMAN F50-FH', 5250000, 'Gateman F50-FH.jpg', 'Khóa vân tay GATEMAN F50-FH thiết kế cổ điển hiện đại, chống nước IP54, tuổi thọ pin lên đến 12 tháng.', '2024-02-17 07:35:46', '2024-02-17 07:35:46', 1, NULL, 0),
(16, 'Khóa vân tay H-Gang TR812', 3350000, 'TR812_3-4.png', 'Khóa vân tay H-Gang TR812 thông minh cao cấp từ Hàn Quốc. Công nghệ hiện đại, bảo mật cao, thiết kế sang trọng.', '2024-02-17 07:35:46', '2025-06-13 07:07:51', 3, 28, 234),
(17, 'Khóa cửa kính H-Gang Sync TG330', 3800000, 'TG330_1.jpg', 'Khóa cửa kính H-Gang Sync TG330 với thiết kế tinh tế cho cửa kính cường lực.', '2024-02-17 07:35:46', '2025-06-13 10:27:31', 10, 73, 31),
(18, 'Khóa điện tử H-Gang TR100', 2150000, 'TR812_3-4.png', 'Khóa điện tử H-Gang TR100 - Giải pháp bảo mật kinh tế, phù hợp cho gia đình.', '2024-02-17 07:35:46', '2024-02-17 07:35:46', 3, NULL, 0),
(19, 'Khóa vân tay H-Gang TM902-KV', 5850000, 'TM700_3-4.png', 'Khóa vân tay H-Gang TM902-KV với tính năng báo động, mở khóa từ xa.', '2024-02-17 07:35:46', '2024-02-17 07:35:46', 3, NULL, 0),
(20, 'Khóa điện tử H-Gang Sync TM700', 3590000, 'TM700_3-4.png', 'Khóa điện tử H-Gang Sync TM700 - Mở khóa bằng mã số, thẻ từ và chìa cơ.', '2024-02-17 07:35:46', '2024-02-17 07:35:46', 3, NULL, 0),
(21, 'Khóa điện tử H-Gang Sync TR700', 2890000, 'TR700_3-4.png', 'Khóa điện tử H-Gang Sync TR700 - Thiết kế tối giản, dễ lắp đặt và sử dụng.', '2024-02-17 07:35:46', '2024-02-17 07:35:46', 3, NULL, 0),
(22, 'Khóa điện tử H-Gang Sync TS700', 3590000, 'TS700_3_4.png', 'Khóa điện tử H-Gang Sync TS700 - Công nghệ mới nhất, bảo mật cao cấp.', '2024-02-17 07:35:46', '2024-02-17 07:35:46', 3, NULL, 0),
(23, 'Khóa vân tay H-Gang TM901', 5500000, 'TM700_3-4.png', 'Khóa vân tay H-Gang TM901 - Vân tay, mật mã, thẻ từ. Thiết kế sang trọng.', '2024-02-17 07:35:46', '2024-02-17 07:35:46', 3, NULL, 0),
(24, 'Khóa vân tay EPIC ES-F700G', 6250000, 'ES-F700G-3-4.png', 'Khóa vân tay EPIC ES-F700G với công nghệ nhận diện vân tay tiên tiến.', '2024-02-17 07:35:46', '2024-02-17 07:35:46', 4, NULL, 0),
(25, 'Khóa vân tay EPIC ES F300D', 4650000, 'ES-F300D_3-4.jpg', 'Khóa vân tay EPIC ES F300D - Thiết kế hiện đại, bảo mật cao, dễ sử dụng.', '2024-02-17 07:35:46', '2024-02-17 07:35:46', 4, NULL, 0),
(26, 'EPIC 100D', 2400000, 'ES-100-1_3-4.jpg', 'EPIC 100D - Khóa điện tử giá rẻ, phù hợp cho mọi loại cửa.', '2024-02-17 07:35:46', '2024-02-17 07:35:46', 4, NULL, 0),
(27, 'Khóa vân tay EPIC EF-8000L', 6100000, 'EPIC 8000L.jpg', 'Khóa vân tay EPIC EF-8000L cao cấp, thiết kế sang trọng, chống nước IP65.', '2024-02-17 07:35:46', '2024-02-17 07:35:46', 4, NULL, 0),
(28, 'EPIC ES-303 GR: Khóa cửa kính', 3450000, 'EPIC ES-303 G (2).jpg', 'EPIC ES-303 GR - Khóa cửa kính với thiết kế tinh tế, bảo mật cao.', '2024-02-17 07:35:46', '2024-02-17 07:35:46', 10, NULL, 0),
(29, 'EPIC POPScan M', 4290000, 'EPIC POPScan M.jpg', 'EPIC POPScan M - Khóa vân tay thông minh với công nghệ POPScan độc quyền.', '2024-02-17 07:35:46', '2024-02-17 07:35:46', 4, NULL, 0),
(30, 'EPIC ES 303 G: Khóa cửa kính', 3450000, 'EPIC ES-303 G (2).jpg', 'EPIC ES 303 G - Khóa cửa kính cao cấp, thiết kế hiện đại, sang trọng.', '2024-02-17 07:35:46', '2024-02-17 07:35:46', 10, NULL, 0),
(31, 'Khóa điện tử EPIC N-Touch', 2250000, 'ES-100-1_3-4.jpg', 'Khóa điện tử EPIC N-Touch - Màn hình cảm ứng, dễ sử dụng, giá cả phải chăng.', '2024-02-17 07:35:46', '2024-02-17 07:35:46', 4, NULL, 0),
(32, 'EPIC 809 L/LR', 5200000, 'ES-809L.jpg', 'EPIC 809 L/LR - Khóa vân tay cao cấp với nhiều tính năng hiện đại.', '2024-02-17 07:35:46', '2024-02-17 07:35:46', 4, NULL, 0),
(33, 'Khóa WELKOM WAT 310', 4200000, 'WAT31dd_0.jpg', 'Khóa WELKOM WAT 310 - Khóa điện tử cao cấp, thiết kế đẹp mắt.', '2024-02-17 07:35:46', '2024-02-17 07:35:46', 5, NULL, 0),
(34, 'WELKOM WSP-2500B', 4800000, 'WDP-2500B_1 3-4.png', 'WELKOM WSP-2500B - Khóa vân tay với công nghệ bảo mật tiên tiến.', '2024-02-17 07:35:46', '2024-02-17 07:35:46', 5, NULL, 0),
(35, 'WELKOM WGT330', 2590000, 'WGT300_1 3-4.png', 'WELKOM WGT330 - Khóa điện tử giá rẻ, chất lượng tốt.', '2024-02-17 07:35:46', '2024-02-17 07:35:46', 5, NULL, 0),
(36, 'WELKOM WRT300', 3800000, 'WRT300_1 3-4.PNG', 'WELKOM WRT300 - Khóa điện tử cao cấp, thiết kế hiện đại.', '2024-02-17 07:35:46', '2024-02-17 07:35:46', 5, NULL, 0),
(37, 'Khóa vân tay KAISER+ M-1190S', 4150000, 'M-1190S_detail 3-4.png', 'Khóa vân tay KAISER+ M-1190S - Công nghệ vân tay tiên tiến, bảo mật cao.', '2024-02-17 07:35:46', '2024-02-17 07:35:46', 7, NULL, 0),
(38, 'Khóa vân tay KAISER+ 7090', 7950000, 'Kaiser 3_4.jpg', 'Khóa vân tay KAISER+ 7090 - Khóa cao cấp, thiết kế sang trọng, nhiều tính năng.', '2024-02-17 07:35:46', '2024-02-17 07:35:46', 7, NULL, 0),
(39, 'Khóa vân tay cửa kính KAISER+ HG-1390', 3850000, 'Kaiser 3_4.jpg', 'Khóa vân tay cửa kính KAISER+ HG-1390 - Thiết kế đẹp cho cửa kính.', '2024-02-17 07:35:46', '2024-02-17 07:35:46', 10, NULL, 0),
(40, 'Khóa vân tay UNICOR UN-7200B', 4690000, '7200B_5 3-4.png', 'Khóa vân tay UNICOR UN-7200B - Công nghệ hiện đại, bảo mật cao cấp.', '2024-02-17 07:35:46', '2024-02-17 07:35:46', 8, NULL, 0),
(41, 'Khóa điện tử Unicor ZEUS 6700sk', 4650000, 'JM6700sk_34.jpg', 'Khóa điện tử Unicor ZEUS 6700sk - Thiết kế sang trọng, dễ sử dụng.', '2024-02-17 07:35:46', '2024-02-17 07:35:46', 8, NULL, 0),
(42, 'Khóa điện tử HiOne+ M-1100S', 2450000, 'img_m1100s_detail 3-4.png', 'Khóa điện tử HiOne+ M-1100S - Giải pháp bảo mật kinh tế cho gia đình.', '2024-02-17 07:35:46', '2024-02-17 07:35:46', 9, NULL, 0),
(43, 'Khóa điện tử HiOne+ H-3400SK', 3450000, 'H-3400SK_3-4.png', 'Khóa điện tử HiOne+ H-3400SK - Thiết kế hiện đại, bảo mật cao.', '2024-02-17 07:35:46', '2024-02-17 07:35:46', 9, NULL, 0),
(44, 'Khóa vân tay HiOne+ H-5490SK', 5890000, 'H-5490SK_3-4.png', 'Khóa vân tay HiOne+ H-5490SK - Công nghệ vân tay tiên tiến, thiết kế đẹp.', '2024-02-17 07:35:46', '2024-02-17 07:35:46', 9, NULL, 0),
(45, 'Bộ chuông cửa có hình KOCOM KCV-434 + KC-C60', 3890000, 'kocom-kcv434.jpg', 'Bộ chuông cửa có hình KOCOM KCV-434 + KC-C60 - Màn hình 4.3 inch, camera HD.', '2024-02-17 07:35:46', '2024-02-17 07:35:46', 11, NULL, 0),
(46, 'Khóa cửa kính TANK GT330', 3290000, 'tank-gt330.jpg', 'Khóa cửa kính TANK GT330 - Thiết kế chuyên dụng cho cửa kính cường lực.', '2024-02-17 07:35:46', '2024-02-17 07:35:46', 10, NULL, 0),
(47, 'Khóa cửa kính Sync Auto 2-way TG310', 3590000, 'sync-tg310.jpg', 'Khóa cửa kính Sync Auto 2-way TG310 - Tự động khóa 2 chiều, an toàn tuyệt đối.', '2024-02-17 07:35:46', '2024-02-17 07:35:46', 10, NULL, 0),
(5784, 'Samsung Galaxy S25 Ultra', 29000000, '17b301fe-dbd0-4c8a-a990-5edef383e497_bsb004501__2__36b648ff5dfb4a0fbc909605f1dc7d53_grande.jpg', 'ádffafas', '2025-06-13 08:28:22', '2025-06-13 11:46:35', 4, 43, 1339),
(5785, 'Mercedes GLE 350', 6990000000, '58760ad5-7ea7-4bc6-a8e6-4c02af90c8cf_images.jpg', 'ádasdasd', '2025-06-13 08:29:52', '2025-06-13 08:29:52', 5, 10, 1);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `product_images`
--

DROP TABLE IF EXISTS `product_images`;
CREATE TABLE `product_images` (
  `id` bigint NOT NULL,
  `product_id` int DEFAULT NULL,
  `image_url` varchar(300) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Đang đổ dữ liệu cho bảng `product_images`
--

INSERT INTO `product_images` (`id`, `product_id`, `image_url`) VALUES
(2, 1, '64baf7b5-635b-4a9e-aec7-03d0fedac82f_nike-air-force-1-low-replica-800x600.jpg'),
(3, 1, '6e7c3444-2475-4880-847d-e6754557316e_af1-full-white-like-auth-6-650x650.jpg'),
(125, 5784, '17b301fe-dbd0-4c8a-a990-5edef383e497_bsb004501__2__36b648ff5dfb4a0fbc909605f1dc7d53_grande.jpg'),
(126, 5785, '58760ad5-7ea7-4bc6-a8e6-4c02af90c8cf_images.jpg');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `product_features`
--

DROP TABLE IF EXISTS `product_features`;
CREATE TABLE `product_features` (
  `id` bigint NOT NULL,
  `product_id` int NOT NULL COMMENT 'ID sản phẩm',
  `feature_id` bigint NOT NULL COMMENT 'ID chức năng',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Đang đổ dữ liệu cho bảng `product_features`
--

INSERT INTO `product_features` (`id`, `product_id`, `feature_id`, `created_at`) VALUES
(1, 1, 1, '2025-06-13 12:00:00'),
(2, 1, 3, '2025-06-13 12:00:00'),
(3, 2, 1, '2025-06-13 12:00:00'),
(4, 2, 2, '2025-06-13 12:00:00');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `reviews`
--

DROP TABLE IF EXISTS `reviews`;
CREATE TABLE `reviews` (
  `id` bigint NOT NULL,
  `product_id` int NOT NULL COMMENT 'ID sản phẩm',
  `user_id` int NOT NULL COMMENT 'ID người dùng',
  `rating` int NOT NULL COMMENT 'Đánh giá từ 1-5 sao',
  `comment` text COMMENT 'Nội dung bình luận',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Đang đổ dữ liệu cho bảng `reviews`
--

INSERT INTO `reviews` (`id`, `product_id`, `user_id`, `rating`, `comment`, `created_at`, `updated_at`) VALUES
(1, 1, 18, 5, 'Sản phẩm rất tốt, chất lượng cao!', '2025-06-13 15:00:00', '2025-06-13 15:00:00'),
(2, 1, 14, 4, 'Tốt, giá hợp lý', '2025-06-13 16:00:00', '2025-06-13 16:00:00'),
(3, 2, 18, 5, 'Rất hài lòng với sản phẩm', '2025-06-13 17:00:00', '2025-06-13 17:00:00'),
(4, 3, 15, 3, 'Tạm được', '2025-06-13 18:00:00', '2025-06-13 18:00:00');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `return_requests`
--

DROP TABLE IF EXISTS `return_requests`;
CREATE TABLE `return_requests` (
  `id` bigint NOT NULL,
  `order_id` int NOT NULL,
  `reason` text NOT NULL,
  `status` varchar(50) NOT NULL DEFAULT 'REQUESTED',
  `refund_amount` decimal(10,2) DEFAULT NULL,
  `admin_notes` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Đang đổ dữ liệu cho bảng `return_requests`
--

INSERT INTO `return_requests` (`id`, `order_id`, `reason`, `status`, `refund_amount`, `admin_notes`, `created_at`, `updated_at`) VALUES
(1, 47, 'sdfdsafsdfsdf', 'REFUNDED', 3030000.00, 'Refunded via Stripe. kml;\'ko\'k\'l;\'', '2025-06-12 23:11:01', '2025-06-12 23:12:46'),
(12, 92, 'àdasfadsfdsafsadfasdf', 'REFUNDED', 29030000.00, 'Refunded via Stripe. àasdfsfds', '2025-06-13 04:47:09', '2025-06-13 04:47:23');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `roles`
--

DROP TABLE IF EXISTS `roles`;
CREATE TABLE `roles` (
  `id` int NOT NULL,
  `name` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Đang đổ dữ liệu cho bảng `roles`
--

INSERT INTO `roles` (`id`, `name`) VALUES
(1, 'USER'),
(2, 'ADMIN');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `social_accounts`
--

DROP TABLE IF EXISTS `social_accounts`;
CREATE TABLE `social_accounts` (
  `id` bigint NOT NULL,
  `provider` varchar(20) NOT NULL COMMENT 'Tên nhà social network',
  `provider_id` varchar(50) NOT NULL,
  `email` varchar(150) NOT NULL COMMENT 'Email tài khoản',
  `name` varchar(100) NOT NULL COMMENT 'Tên người dùng',
  `user_id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tokens`
--

DROP TABLE IF EXISTS `tokens`;
CREATE TABLE `tokens` (
  `id` bigint NOT NULL,
  `token` varchar(255) NOT NULL,
  `token_type` varchar(50) NOT NULL,
  `expiration_date` datetime DEFAULT NULL,
  `revoked` tinyint(1) NOT NULL,
  `expired` tinyint(1) NOT NULL,
  `user_id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` int NOT NULL,
  `fullname` varchar(100) DEFAULT '',
  `phone_number` varchar(10) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `address` varchar(200) DEFAULT '',
  `password` varchar(100) NOT NULL DEFAULT '',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `date_of_birth` datetime(6) DEFAULT NULL,
  `facebook_account_id` int DEFAULT '0',
  `google_account_id` int DEFAULT '0',
  `role_id` int DEFAULT NULL,
  `reset_password_token` varchar(255) DEFAULT NULL,
  `reset_password_token_expiry` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Đang đổ dữ liệu cho bảng `users`
--

INSERT INTO `users` (`id`, `fullname`, `phone_number`, `email`, `address`, `password`, `created_at`, `updated_at`, `is_active`, `date_of_birth`, `facebook_account_id`, `google_account_id`, `role_id`) VALUES
(1, 'Trần Đức Anh', '0865247233', 'tran.duc.anh@gmail.com', 'Hanoi', '21112003', NULL, '2025-06-13 06:07:14', 1, '2003-11-21 00:00:00.000000', 0, 0, 1),
(3, 'ADMIN 1', '0111222333', 'admin.1@gmail.com', 'Hanoi', '$2a$10$zgJgPl51rJQGl8xlznCKgOGipZjbaPMXiF/Zv/03ri1mA1iN1Z.su', '2024-02-21 09:00:03', '2024-02-21 09:00:03', 1, '2003-11-12 00:00:00.000000', 0, 0, 2),
(18, 'lap', '0854768836', 'secroramot123@gmail.com', 'lap', '$2a$10$vagQjcnWTqYMU8mxtWsl.uF8DY3te0JzO6ObqVMkA9TfdMBa1mZEi', '2025-06-09 19:33:13', '2025-06-13 08:31:20', 1, '2003-10-26 00:00:00.000000', 0, 0, 1);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `vouchers`
--

DROP TABLE IF EXISTS `vouchers`;
CREATE TABLE `vouchers` (
  `id` int NOT NULL,
  `code` varchar(50) NOT NULL COMMENT 'Mã voucher duy nhất',
  `name` varchar(100) NOT NULL COMMENT 'Tên voucher',
  `description` text COMMENT 'Mô tả voucher',
  `discount_percentage` int NOT NULL COMMENT 'Phần trăm giảm giá',
  `min_order_value` bigint DEFAULT '0' COMMENT 'Giá trị đơn hàng tối thiểu để áp dụng',
  `max_discount_amount` bigint DEFAULT NULL COMMENT 'Số tiền giảm tối đa',
  `quantity` int NOT NULL DEFAULT '1' COMMENT 'Tổng số lượng voucher',
  `remaining_quantity` int NOT NULL DEFAULT '1' COMMENT 'Số lượng voucher còn lại',
  `valid_from` datetime NOT NULL COMMENT 'Thời gian bắt đầu hiệu lực',
  `valid_to` datetime NOT NULL COMMENT 'Thời gian hết hiệu lực',
  `is_active` tinyint(1) DEFAULT '1' COMMENT 'Trạng thái hoạt động',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Đang đổ dữ liệu cho bảng `vouchers`
--

INSERT INTO `vouchers` (`id`, `code`, `name`, `description`, `discount_percentage`, `min_order_value`, `max_discount_amount`, `quantity`, `remaining_quantity`, `valid_from`, `valid_to`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'SALE66', 'Sale 6/6', 'Giảm giá nhân dịp 6/6', 20, 500000, 100000, 100, 100, '2024-06-01 00:00:00', '2024-06-30 23:59:59', 1, '2025-06-09 18:19:46', '2025-06-09 18:19:46'),
(10, '156SUPERSALE', 'Sale cực sốc 15/6', 'Giảm giá sốc, số lượng có hạn', 20, 1000000, 700000, 10, 10, '2025-06-13 01:14:00', '2025-06-15 01:14:00', 1, '2025-06-13 08:15:04', '2025-06-13 08:15:04');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `voucher_usage`
--

DROP TABLE IF EXISTS `voucher_usage`;
CREATE TABLE `voucher_usage` (
  `id` bigint NOT NULL,
  `voucher_id` int NOT NULL,
  `order_id` int NOT NULL,
  `user_id` int NOT NULL,
  `discount_amount` bigint NOT NULL COMMENT 'Số tiền được giảm',
  `used_at` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Đang đổ dữ liệu cho bảng `voucher_usage`
--

INSERT INTO `voucher_usage` (`id`, `voucher_id`, `order_id`, `user_id`, `discount_amount`, `used_at`) VALUES
(1, 8, 30, 18, 18540688, '2025-06-09 21:06:59'),
(2, 9, 51, 18, 50000, '2025-06-13 06:20:00');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `news`
--

DROP TABLE IF EXISTS `news`;
CREATE TABLE IF NOT EXISTS `news` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Đang đổ dữ liệu cho bảng `news`
--

INSERT INTO `news` (`title`, `content`, `summary`, `author`, `category`, `status`, `featured_image`, `views`, `published_at`) VALUES
('Giới thiệu sản phẩm mới', 'Nội dung chi tiết về sản phẩm mới...', 'Tóm tắt về sản phẩm mới', 'Admin', 'Tin tức', 'PUBLISHED', 'news1.jpg', 150, NOW()),
('Hướng dẫn sử dụng', 'Hướng dẫn chi tiết cách sử dụng sản phẩm...', 'Tóm tắt hướng dẫn', 'Admin', 'Hướng dẫn', 'PUBLISHED', 'news2.jpg', 89, NOW()),
('Chương trình khuyến mãi', 'Thông tin về chương trình khuyến mãi...', 'Tóm tắt khuyến mãi', 'Admin', 'Khuyến mãi', 'PUBLISHED', 'news3.jpg', 200, NOW()),
('Tin tức bản nháp', 'Nội dung tin tức chưa xuất bản...', 'Tóm tắt tin nháp', 'Admin', 'Tin tức', 'DRAFT', NULL, 0, NULL);

--
-- Chỉ mục cho các bảng đã đổ
--

--
-- Chỉ mục cho bảng `carts`
--
ALTER TABLE `carts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `FK__users` (`user_id`),
  ADD KEY `FK__products` (`product_id`);

--
-- Chỉ mục cho bảng `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `orders_voucher_fk` (`voucher_id`),
  ADD KEY `idx_orders_payment_intent_id` (`payment_intent_id`);

--
-- Chỉ mục cho bảng `lock_features`
--
ALTER TABLE `lock_features`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_is_active` (`is_active`);

--
-- Chỉ mục cho bảng `order_details`
--
ALTER TABLE `order_details`
  ADD PRIMARY KEY (`id`),
  ADD KEY `order_id` (`order_id`),
  ADD KEY `product_id` (`product_id`);

--
-- Chỉ mục cho bảng `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`),
  ADD KEY `category_id` (`category_id`);

--
-- Chỉ mục cho bảng `product_images`
--
ALTER TABLE `product_images`
  ADD PRIMARY KEY (`id`),
  ADD KEY `product_id` (`product_id`);

--
-- Chỉ mục cho bảng `return_requests`
--
ALTER TABLE `return_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_return_requests_order_id` (`order_id`),
  ADD KEY `idx_return_requests_status` (`status`);

--
-- Chỉ mục cho bảng `reviews`
--
ALTER TABLE `reviews`
  ADD PRIMARY KEY (`id`),
  ADD KEY `product_id` (`product_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `idx_rating` (`rating`);

--
-- Chỉ mục cho bảng `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `social_accounts`
--
ALTER TABLE `social_accounts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Chỉ mục cho bảng `tokens`
--
ALTER TABLE `tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `token` (`token`),
  ADD KEY `user_id` (`user_id`);

--
-- Chỉ mục cho bảng `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `role_id` (`role_id`);

--
-- Chỉ mục cho bảng `vouchers`
--
ALTER TABLE `vouchers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`),
  ADD KEY `idx_code` (`code`),
  ADD KEY `idx_valid_dates` (`valid_from`,`valid_to`);

--
-- Chỉ mục cho bảng `voucher_usage`
--
ALTER TABLE `voucher_usage`
  ADD PRIMARY KEY (`id`),
  ADD KEY `voucher_id` (`voucher_id`),
  ADD KEY `order_id` (`order_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Chỉ mục cho bảng `product_features`
--
ALTER TABLE `product_features`
  ADD PRIMARY KEY (`id`),
  ADD KEY `product_id` (`product_id`),
  ADD KEY `feature_id` (`feature_id`),
  ADD KEY `created_at` (`created_at`);

--
-- Chỉ mục cho bảng `news`
--
ALTER TABLE `news`
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_category` (`category`),
  ADD KEY `idx_published_at` (`published_at`);

--
-- AUTO_INCREMENT cho các bảng đã đổ
--

--
-- AUTO_INCREMENT cho bảng `carts`
--
ALTER TABLE `carts`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT cho bảng `categories`
--
ALTER TABLE `categories`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT cho bảng `lock_features`
--
ALTER TABLE `lock_features`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT cho bảng `orders`
--
ALTER TABLE `orders`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=93;

--
-- AUTO_INCREMENT cho bảng `order_details`
--
ALTER TABLE `order_details`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=126;

--
-- AUTO_INCREMENT cho bảng `products`
--
ALTER TABLE `products`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5787;

--
-- AUTO_INCREMENT cho bảng `product_images`
--
ALTER TABLE `product_images`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=132;

--
-- AUTO_INCREMENT cho bảng `return_requests`
--
ALTER TABLE `return_requests`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT cho bảng `reviews`
--
ALTER TABLE `reviews`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT cho bảng `roles`
--
ALTER TABLE `roles`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT cho bảng `social_accounts`
--
ALTER TABLE `social_accounts`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `tokens`
--
ALTER TABLE `tokens`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `users`
--
ALTER TABLE `users`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT cho bảng `vouchers`
--
ALTER TABLE `vouchers`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT cho bảng `voucher_usage`
--
ALTER TABLE `voucher_usage`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT cho bảng `product_features`
--
ALTER TABLE `product_features`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT cho bảng `news`
--
ALTER TABLE `news`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Ràng buộc đối với các bảng kết xuất
--

--
-- Ràng buộc cho bảng `carts`
--
ALTER TABLE `carts`
  ADD CONSTRAINT `FK__products` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`),
  ADD CONSTRAINT `FK__users` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Ràng buộc cho bảng `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `orders_voucher_fk` FOREIGN KEY (`voucher_id`) REFERENCES `vouchers` (`id`);

--
-- Ràng buộc cho bảng `order_details`
--
ALTER TABLE `order_details`
  ADD CONSTRAINT `order_details_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`),
  ADD CONSTRAINT `order_details_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`);

--
-- Ràng buộc cho bảng `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `products_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`);

--
-- Ràng buộc cho bảng `product_images`
--
ALTER TABLE `product_images`
  ADD CONSTRAINT `product_images_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Ràng buộc cho bảng `return_requests`
--
ALTER TABLE `return_requests`
  ADD CONSTRAINT `return_requests_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`);

--
-- Ràng buộc cho bảng `reviews`
--
ALTER TABLE `reviews`
  ADD CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `reviews_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ràng buộc cho bảng `social_accounts`
--
ALTER TABLE `social_accounts`
  ADD CONSTRAINT `social_accounts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Ràng buộc cho bảng `tokens`
--
ALTER TABLE `tokens`
  ADD CONSTRAINT `tokens_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Ràng buộc cho bảng `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`);

--
-- Ràng buộc cho bảng `voucher_usage`
--
ALTER TABLE `voucher_usage`
  ADD CONSTRAINT `voucher_usage_ibfk_1` FOREIGN KEY (`voucher_id`) REFERENCES `vouchers` (`id`),
  ADD CONSTRAINT `voucher_usage_ibfk_2` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`),
  ADD CONSTRAINT `voucher_usage_ibfk_3` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Ràng buộc cho bảng `product_features`
--
ALTER TABLE `product_features`
  ADD CONSTRAINT `product_features_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `product_features_ibfk_2` FOREIGN KEY (`feature_id`) REFERENCES `lock_features` (`id`) ON DELETE CASCADE;

SET FOREIGN_KEY_CHECKS=1;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

