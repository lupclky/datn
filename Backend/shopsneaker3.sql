-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Máy chủ: mysql8-container
-- Thời gian đã tạo: Th10 06, 2025 lúc 12:58 PM
-- Phiên bản máy phục vụ: 8.2.0
-- Phiên bản PHP: 8.3.26

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Cơ sở dữ liệu: `shopsneaker3`
--

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `banners`
--

CREATE TABLE `banners` (
  `id` bigint NOT NULL,
  `title` varchar(500) NOT NULL COMMENT 'Tiêu đề banner',
  `description` varchar(1000) DEFAULT NULL COMMENT 'Mô tả ngắn',
  `image_url` varchar(500) NOT NULL COMMENT 'Đường dẫn hình ảnh',
  `button_text` varchar(100) DEFAULT NULL COMMENT 'Text trên nút bấm',
  `button_link` varchar(500) DEFAULT NULL COMMENT 'Link khi click nút',
  `button_style` varchar(50) DEFAULT NULL COMMENT 'Màu nút: primary, danger, success, warning, info, secondary',
  `display_order` int NOT NULL DEFAULT '0' COMMENT 'Thứ tự hiển thị (nhỏ hơn hiển thị trước)',
  `is_active` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'Trạng thái hiển thị',
  `start_date` datetime DEFAULT NULL COMMENT 'Ngày bắt đầu hiển thị',
  `end_date` datetime DEFAULT NULL COMMENT 'Ngày kết thúc hiển thị',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Ngày tạo',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Ngày cập nhật'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Bảng quản lý banner trang chủ';

--
-- Đang đổ dữ liệu cho bảng `banners`
--

INSERT INTO `banners` (`id`, `title`, `description`, `image_url`, `button_text`, `button_link`, `button_style`, `display_order`, `is_active`, `start_date`, `end_date`, `created_at`, `updated_at`) VALUES
(1, 'Khoá vân tay thông minh', 'Bảo mật hiện đại, mở khoá một chạm', 'cd5374a8-e538-41e4-967d-00e3423cdb1a_Kaiser 3_4.jpg', 'Khám phá ngay', '/allProduct', 'primary', 1, 1, '2025-11-04 12:58:04', '2026-02-02 12:58:04', '2025-11-04 12:58:04', '2025-11-04 13:44:28'),
(2, 'Ưu đãi đặc biệt', 'Giảm đến 50% cho dòng khoá cao cấp', '9ddc4cd2-15d8-49fd-b91b-7d719957ce3c_sht-3517nt-1.jpg', 'Mua ngay', '/allProduct', 'danger', 2, 1, '2025-11-01 13:49:20', '2026-01-15 13:49:29', '2025-11-04 12:58:04', '2025-11-04 15:51:35'),
(3, 'Khuyến mại VNPAY', 'Thanh toán bằng QR để có cơ hội giảm lên tới 500K', 'c219228a-15db-4666-86c2-ad2eaa8d683c_Khuyen_mai_khach_hang_quet_ma_VNPAY-QR_tren_VietinBank_iPay_Mobile_1.jpg', '', '', 'success', 11, 1, '2025-11-01 01:23:40', '2025-12-25 01:23:42', '2025-11-04 12:58:04', '2025-11-06 03:12:28'),
(4, 'Khuyến mãi cà thẻ', '', '7c1b6cbf-3f03-4032-9708-f5db958c0985_cathet5.jpg', '', '', 'primary', 12, 1, '2025-11-04 01:31:28', '2025-12-18 01:31:35', '2025-11-06 01:31:26', '2025-11-06 01:31:39'),
(5, 'KVK Intelligence', 'Trợ lý tư vấn vượt trội', 'afd011c4-3659-4db8-af6f-abeb6203ff4f_Tạo 1 banner ngang đ.png', '', '', 'primary', 3, 1, '2025-11-01 03:12:55', '2025-11-28 03:12:57', '2025-11-06 03:12:49', '2025-11-06 03:18:34');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `carts`
--

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
(10, 'Khóa cửa kính Apple'),
(11, 'Chuông hình');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `chat_conversations`
--

CREATE TABLE `chat_conversations` (
  `id` int UNSIGNED NOT NULL,
  `customer_id` int DEFAULT NULL,
  `staff_id` int DEFAULT NULL,
  `guest_session_id` varchar(255) DEFAULT NULL,
  `is_closed` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `chat_messages`
--

CREATE TABLE `chat_messages` (
  `id` bigint NOT NULL,
  `sender_id` int DEFAULT NULL COMMENT 'ID người gửi (NULL cho guest)',
  `guest_session_id` varchar(255) DEFAULT NULL COMMENT 'Session ID của khách vãng lai (từ localStorage)',
  `receiver_id` int DEFAULT NULL COMMENT 'ID người nhận (NULL nếu là chat công khai)',
  `conversation_id` int UNSIGNED DEFAULT NULL,
  `message` text NOT NULL COMMENT 'Nội dung tin nhắn',
  `message_type` varchar(20) NOT NULL DEFAULT 'TEXT' COMMENT 'Loại tin nhắn: TEXT, IMAGE, FILE',
  `is_read` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Đã đọc chưa',
  `is_staff_message` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Có phải tin nhắn từ nhân viên',
  `is_closed` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Cuộc trò chuyện đã được đóng',
  `closed_by` int DEFAULT NULL COMMENT 'ID người đóng cuộc trò chuyện (staff/admin)',
  `closed_at` datetime DEFAULT NULL COMMENT 'Thời gian đóng cuộc trò chuyện',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `file_url` varchar(500) DEFAULT NULL,
  `file_name` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Bảng lưu trữ tin nhắn chat';

--
-- Đang đổ dữ liệu cho bảng `chat_messages`
--

INSERT INTO `chat_messages` (`id`, `sender_id`, `guest_session_id`, `receiver_id`, `conversation_id`, `message`, `message_type`, `is_read`, `is_staff_message`, `is_closed`, `closed_by`, `closed_at`, `created_at`, `updated_at`, `file_url`, `file_name`) VALUES
(12, 19, NULL, 18, NULL, 'alo', 'TEXT', 0, 1, 1, 19, '2025-11-05 21:19:28', '2025-11-05 21:10:46', '2025-11-05 21:19:28', NULL, NULL),
(13, 19, NULL, 18, NULL, 'ads', 'TEXT', 0, 1, 1, 19, '2025-11-05 21:19:28', '2025-11-05 21:10:54', '2025-11-05 21:19:28', NULL, NULL),
(14, 18, NULL, 19, NULL, 'alo', 'TEXT', 1, 0, 1, 19, '2025-11-05 21:19:28', '2025-11-05 21:11:30', '2025-11-05 21:19:28', NULL, NULL),
(15, 19, NULL, 18, NULL, 'alo', 'TEXT', 0, 1, 1, 19, '2025-11-05 21:19:28', '2025-11-05 21:11:38', '2025-11-05 21:19:28', NULL, NULL),
(16, 19, NULL, 18, NULL, 'SHS-P718_3-4.png', 'IMAGE', 0, 1, 1, 19, '2025-11-05 21:19:28', '2025-11-05 21:12:01', '2025-11-05 21:19:28', '/api/v1/chat/files/d56747c7-6cdb-4de9-a277-f49ffbf14511_SHS-P718_3-4.png', 'SHS-P718_3-4.png'),
(17, 18, NULL, 19, NULL, 'alo', 'TEXT', 1, 0, 1, 19, '2025-11-05 21:19:28', '2025-11-05 21:12:50', '2025-11-05 21:19:28', NULL, NULL),
(18, 19, NULL, 18, NULL, 'alo', 'TEXT', 0, 1, 1, 19, '2025-11-05 21:19:28', '2025-11-05 21:13:19', '2025-11-05 21:19:28', NULL, NULL),
(19, 19, NULL, 18, NULL, 'alo', 'TEXT', 0, 1, 1, 19, '2025-11-05 21:19:28', '2025-11-05 21:15:50', '2025-11-05 21:19:28', NULL, NULL),
(20, 18, NULL, 19, NULL, 'alo', 'TEXT', 1, 0, 1, 19, '2025-11-05 21:19:28', '2025-11-05 21:16:10', '2025-11-05 21:19:28', NULL, NULL),
(21, 19, NULL, 18, NULL, 'alo', 'TEXT', 0, 1, 1, 19, '2025-11-05 21:19:28', '2025-11-05 21:16:15', '2025-11-05 21:19:28', NULL, NULL),
(22, 19, NULL, 18, NULL, 'alo', 'TEXT', 0, 1, 1, 19, '2025-11-05 21:19:28', '2025-11-05 21:17:59', '2025-11-05 21:19:28', NULL, NULL),
(23, 18, NULL, 19, NULL, '', 'IMAGE', 0, 0, 1, 19, '2025-11-05 21:19:28', '2025-11-05 21:18:10', '2025-11-05 21:19:28', '/api/v1/chat/files/fda7270d-3e58-41df-a923-d873cdf5bf37_DH538_co 3-4.jpg', 'DH538_co 3-4.jpg'),
(24, 18, NULL, 19, NULL, 'alo', 'TEXT', 1, 0, 0, NULL, NULL, '2025-11-05 21:19:43', '2025-11-05 21:21:49', NULL, NULL),
(25, 18, NULL, 19, NULL, '', 'IMAGE', 1, 0, 0, NULL, NULL, '2025-11-05 21:21:40', '2025-11-05 21:24:27', '/api/v1/chat/files/6cdc20e9-d623-49c8-9ae2-182725c1497f_sht-3517nt-1.jpg', 'sht-3517nt-1.jpg');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `lock_features`
--

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
(7, 'Cảnh báo an ninh', 'Cảnh báo khi có xâm nhập', 1, '2025-06-13 12:00:00', '2025-06-13 12:00:00'),
(8, 'Kết nối 4G', 'Kết nối mạng di động để điều khiển khi mất Wi-Fi', 1, '2025-11-05 13:01:33', '2025-11-05 13:01:54');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `news`
--

CREATE TABLE `news` (
  `id` bigint NOT NULL,
  `title` varchar(500) NOT NULL,
  `content` text,
  `summary` varchar(1000) DEFAULT NULL,
  `author` varchar(100) DEFAULT NULL,
  `category` varchar(50) DEFAULT NULL,
  `status` enum('DRAFT','PUBLISHED','ARCHIVED') NOT NULL DEFAULT 'DRAFT',
  `featured_image` varchar(500) DEFAULT NULL,
  `views` bigint NOT NULL DEFAULT '0',
  `published_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `thumbnail` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Đang đổ dữ liệu cho bảng `news`
--

INSERT INTO `news` (`id`, `title`, `content`, `summary`, `author`, `category`, `status`, `featured_image`, `views`, `published_at`, `created_at`, `updated_at`, `thumbnail`) VALUES
(1, 'Giới thiệu sản phẩm mới', '<p>Nội dung chi tiết về sản ph<span style=\"background-color: initial; color: inherit;\">Sau nhiều tháng thử nghiệm beta,&nbsp;</span><a href=\"https://tinhte.vn/tag/apple\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"background-color: initial; color: rgb(7, 104, 234);\">Apple</a><span style=\"background-color: initial; color: inherit;\">&nbsp;hôm nay đã chính thức phát hành&nbsp;</span><a href=\"https://tinhte.vn/tag/ios-261\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"background-color: initial; color: rgb(7, 104, 234);\">iOS 26.1</a><span style=\"background-color: initial; color: inherit;\">&nbsp;và iPadOS 26.1 đến người dùng toàn cầu. Nếu như&nbsp;</span><a href=\"https://tinhte.vn/tag/ios-26\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"background-color: initial; color: rgb(7, 104, 234);\">iOS 26</a><span style=\"background-color: initial; color: inherit;\">&nbsp;là một cuộc lột xác về mặt giao diện với hiệu ứng Liquid Glass, thì&nbsp;</span><a href=\"https://tinhte.vn/tag/ios\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"background-color: initial; color: rgb(7, 104, 234);\">iOS</a><span style=\"background-color: initial; color: inherit;\">&nbsp;26.1 lại là một bản cập nhật mang tính hoàn thiện, tập trung vào việc lắng nghe phản hồi từ cộng đồng, tinh chỉnh trải nghiệm, và quan trọng nhất, AI Apple đã có tiếng Việt.</span></p><p><br></p><p><a href=\"https://tinhte.vn/thread/thu-nhanh-apple-intelligence-tieng-viet-cam-on-apple-minh-da-cho-dieu-nay-hon-mot-nam-qua.4058827/\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"background-color: initial; color: inherit;\"><img src=\"https://imgproxy7.tinhte.vn/NUfJH046YahZ_HW-22UTlJgIvTlNhrymgIa0jOut2hs/rs:fill:480:300:0/plain/https://photo2.tinhte.vn/data/attachment-files/2025/09/8844754_overr_neia.jpg\" height=\"300\" width=\"480\"></a></p><h2><a href=\"https://tinhte.vn/thread/thu-nhanh-apple-intelligence-tieng-viet-cam-on-apple-minh-da-cho-dieu-nay-hon-mot-nam-qua.4058827/\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"color: rgb(20, 20, 20);\"><strong>Thử nhanh Apple Intelligence tiếng Việt: Cảm ơn Apple, mình đã chờ điều này hơn một năm qua</strong></a></h2><p><a href=\"https://tinhte.vn/thread/thu-nhanh-apple-intelligence-tieng-viet-cam-on-apple-minh-da-cho-dieu-nay-hon-mot-nam-qua.4058827/\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"color: rgb(20, 20, 20);\">Bà con ơi, làng nước ơi, Apple AI có tiếng Việt rồi. Đây là một điều mình đã mong chờ trong hơn 1 năm qua, Siri tiếng Việt ừ cũng thường nhưng Apple Intelligence tiếng Việt lại là một chuyện khác, mới trải nghiệm sơ sơ là thấy đã rồi. Để xài AI...</a></p><p><a href=\"https://tinhte.vn/thread/thu-nhanh-apple-intelligence-tieng-viet-cam-on-apple-minh-da-cho-dieu-nay-hon-mot-nam-qua.4058827/\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"color: rgb(20, 20, 20); background-color: initial;\">&nbsp;tinhte.vn</a></p><p><br></p><p><br></p><h2><strong style=\"background-color: initial; color: inherit;\">Apple Intelligence chính thức hỗ trợ Tiếng Việt</strong></h2><p><br></p><p><span style=\"background-color: initial; color: inherit;\">Đây chắc chắn là nâng cấp quan trọng và được mong chờ nhất đối với người dùng Việt Nam trong bản cập nhật lần này. Nền tảng trí tuệ nhân tạo của Apple giờ đây đã có thể hiểu và tương tác hoàn toàn bằng tiếng Việt, giúp anh em trải nghiệm nhiều tính năng mới mà trước đây chúng ta chỉ có thể trải nghiệm bằng tiếng Anh.</span></p><p><br></p><p><span style=\"background-color: initial; color: inherit;\"><img src=\"https://photo2.tinhte.vn/data/attachment-files/2025/11/8885130_8844754-overr-neia.jpg\" alt=\"8844754-overr-neia.jpg\"></span></p><p><br></p><p>Đầu tiên phải kể đến Writing Tools (Công cụ Viết). Tính năng này giờ đây đã có thể sử dụng hoàn toàn bằng tiếng Việt trên hầu hết mọi ứng dụng. Ae có thể dễ dàng yêu cầu AI tóm tắt một đoạn văn bản dài, viết lại theo một phong cách khác, sửa lỗi chính tả hay thậm chí chuyển đổi một đoạn so sánh thành dạng bảng biểu để dễ theo dõi hơn. Việc tích hợp sâu ChatGPT cũng cho phép người dùng đưa ra các yêu cầu phức tạp hơn bằng chính ngôn ngữ mẹ đẻ.</p><p><br></p><p><span style=\"background-color: initial; color: inherit;\"><img src=\"https://photo2.tinhte.vn/data/attachment-files/2025/11/8885131_8844747-piewjfipqwejf-2.jpg\" alt=\"8844747-piewjfipqwejf-2.jpg\"></span></p><p><br></p><p><span style=\"background-color: initial; color: inherit;\">Trong ứng dụng Mail, AI có thể tự động đọc và tóm tắt nội dung các email dài bằng tiếng Việt một cách ngọt sớt, đồng thời đề xuất các câu trả lời thông minh phù hợp với ngữ cảnh. Cùng với khả năng lọc và phân loại mail tự động, việc quản lý email hàng ngày đã trở nên đơn giản và hiệu quả hơn rất nhiều.</span></p><p><br></p><p><span style=\"background-color: initial; color: inherit;\"><img src=\"https://photo2.tinhte.vn/data/attachment-files/2025/11/8885132_8844736-4.jpg\" alt=\"8844736-4.jpg\"></span></p><p><br></p><p><span style=\"background-color: initial; color: inherit;\">Siri thế hệ mới cũng đã thông minh hơn khi giao tiếp bằng tiếng Việt. Nó có thể hiểu các câu lệnh phức tạp và tự nhiên hơn, thực hiện các tác vụ liền mạch như \"nhắn tin cho A rủ đi ăn phở, uống trà sữa\" hay thậm chí là yêu cầu ChatGPT soạn một đoạn văn bản rồi gửi đi.</span></p><p><br></p><p><span style=\"background-color: initial; color: inherit;\"><img src=\"https://photo2.tinhte.vn/data/attachment-files/2025/11/8885133_8844740-7-2.jpg\" alt=\"8844740-7-2.jpg\"></span></p><p><br></p><p><span style=\"background-color: initial; color: inherit;\">Cuối cùng, Visual Intelligence cũng đã được Việt hóa. Khi ae hướng camera vào một địa điểm hay một đoạn văn bản, tính năng này có thể nhận diện và cung cấp các thông tin liên quan bằng tiếng Việt. Các tính năng sáng tạo như Image Playground và Genmoji cũng đã chấp nhận các câu lệnh mô tả bằng tiếng Việt, giúp cá nhân hóa trải nghiệm một cách sâu sắc hơn nhưng mấy cái đó thấy không vui nên mình không xài.</span></p><p><br></p><p><span style=\"background-color: initial; color: inherit;\"><img src=\"https://photo2.tinhte.vn/data/attachment-files/2025/11/8885134_8844742-11-2.jpg\" alt=\"8844742-11-2.jpg\"></span></p><p><br></p><h2><strong style=\"background-color: initial; color: inherit;\">Tùy chỉnh giao diện Liquid Glass</strong></h2><p><br></p><p><span style=\"background-color: initial; color: inherit;\">Lắng nghe phản hồi từ những người dùng cho rằng giao diện Liquid Glass mặc định đôi khi hơi khó đọc do độ tương phản thấp, Apple đã bổ sung một tùy chọn tùy chỉnh quan trọng trong iOS 26.1. Trong mục Cài đặt &gt; Màn hình &amp; Độ sáng, người dùng giờ đây có thể chuyển đổi giữa hai chế độ: Clear và Tinted.</span></p><p><br></p><p><span style=\"background-color: initial; color: inherit;\"><img src=\"https://photo2.tinhte.vn/data/attachment-files/2025/11/8885135_tat-liquid-glass-trong-ban-cap-nhat-ios-26-1-8.jpg\" alt=\"tat-liquid-glass-trong-ban-cap-nhat-ios-26-1-8.jpg\"></span></p><p><br></p><p><span style=\"background-color: initial; color: inherit;\">Chế độ Clear chính là giao diện Liquid Glass mặc định với các thành phần có độ trong mờ cao, cho phép nhìn thấy rõ hình nền phía sau. Trong khi đó, chế độ Tinted sẽ tăng độ mờ đục và thêm độ tương phản cho các yếu tố giao diện như nút bấm, thanh menu, giúp chúng trở nên nổi bật và dễ đọc hơn. Sự thay đổi này được áp dụng trên toàn bộ hệ điều hành, từ các ứng dụng cho đến thông báo trên Màn hình khóa.</span></p><p><br></p><h2><strong style=\"background-color: initial; color: inherit;\">iPadOS 26.1: Slide Over chính thức trở lại, hoạt động song song với đa nhiệm cửa sổ</strong></h2><p><br></p><p><span style=\"background-color: initial; color: inherit;\">Đây là một tin cực vui cho những người dùng iPad. Tính năng đa nhiệm Slide Over, vốn đã bị tạm thời loại bỏ trên iPadOS 26 để nhường chỗ cho hệ thống cửa sổ mới, đã chính thức được Apple mang trở lại, mình thích cái này hơn cái hệ thống cửa sổ mới. Mình thực sự đã quen với việc truy cập nhanh một ứng dụng phụ mà không làm gián đoạn công việc chính, Slide Over làm được chuyện đó.</span></p><p><br></p><p><span style=\"background-color: initial; color: inherit;\"><img src=\"https://photo2.tinhte.vn/data/attachment-files/2025/11/8885136_maxresdefault-4.jpg\" alt=\"maxresdefault-4.jpg\"></span></p><p><br></p><p>Giờ đây, Slide Over sẽ hoạt động song song và đóng vai trò bổ trợ cho hệ thống cửa sổ. Điều này có nghĩa là ae có thể mở nhiều cửa sổ ứng dụng trên màn hình, đồng thời vẫn có thể vuốt từ cạnh phải để truy cập nhanh một ứng dụng đang chạy ở chế độ Slide Over.</p><p><br></p><p><span style=\"background-color: initial; color: inherit;\"><img src=\"https://photo2.tinhte.vn/data/attachment-files/2025/11/8885137_8859365-ipados-26-1-slide-over.jpg\" alt=\"8859365-ipados-26-1-slide-over.jpg\"></span></p><p><br></p><p><span style=\"background-color: initial; color: inherit;\">Để kích hoạt, người dùng chỉ cần nhấn vào nút điều khiển cửa sổ và chọn Enter Slide Over. Dù ở phiên bản hiện tại, người dùng chỉ có thể sử dụng một ứng dụng Slide Over tại một thời điểm, nhưng sự trở lại này đã cho thấy Apple đang tích cực lắng nghe và tìm ra điểm cân bằng tối ưu cho trải nghiệm đa nhiệm trên iPad.</span></p><p><br></p><h2><strong style=\"background-color: initial; color: inherit;\">Báo thức và Hẹn giờ: Thao tác \"Trượt để tắt\" thay cho nút bấm</strong></h2><p><br></p><p><span style=\"background-color: initial; color: inherit;\">Một thay đổi nhỏ nhưng cực kỳ hữu ích và mình thấy được nhiều người dùng hoan nghênh chính là cách tương tác mới với báo thức trên Màn hình Khóa. Apple đã thay thế nút Stop bằng một thanh trượt Slide to Stop, trong khi nút Snooze vẫn giữ nguyên dạng nhấn.</span></p><p><br></p><p><span style=\"background-color: initial; color: inherit;\"><img src=\"https://photo2.tinhte.vn/data/attachment-files/2025/11/8885138_8859361-ios-26-1-slide-to-stop.jpg\" alt=\"8859361-ios-26-1-slide-to-stop.jpg\"></span></p><p><br></p><p><span style=\"background-color: initial; color: inherit;\">Sự thay đổi này giải quyết triệt để một vấn đề mà rất nhiều người gặp phải vào mỗi buổi sáng: vô tình nhấn nhầm nút Dừng thay vì Báo lại trong lúc còn ngái ngủ, đặc biệt là những người ngủ xấu như&nbsp;</span><a href=\"https://tinhte.vn/profile/nha-cua-cao.1418508/\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"background-color: initial; color: rgb(7, 104, 234);\">@Nhà Của Cáo</a><span style=\"background-color: initial; color: inherit;\">.</span></p><p><br></p><p><span style=\"background-color: initial; color: inherit;\">Giờ đây, để tắt hoàn toàn báo thức, người dùng sẽ cần một thao tác trượt có chủ đích hơn, giảm thiểu đáng kể khả năng tắt nhầm. Thay đổi này cũng được áp dụng tương tự cho tính năng Hẹn giờ.</span></p><p><br></p><h2><strong style=\"background-color: initial; color: inherit;\">Nâng cấp toàn diện cho CarPlay: Giao diện mới, Widget, Live Activities và AirPlay</strong></h2><p><br></p><p><span style=\"background-color: initial; color: inherit;\">CarPlay có thể xem là nền tảng nhận được nhiều nâng cấp nhất trên iOS 26.1. Toàn bộ giao diện giờ đây được áp dụng hiệu ứng Liquid Glass, mang lại một vẻ ngoài đồng bộ và hiện đại. Người dùng có thể trả lời tin nhắn bằng các Tapback, xem các cuộc hội thoại đã ghim và nhận thông báo cuộc gọi trong một giao diện nhỏ gọn hơn để không che mất bản đồ.</span></p><p><br></p><p><span style=\"background-color: initial; color: inherit;\"><img src=\"https://photo2.tinhte.vn/data/attachment-files/2025/11/8885139_CarPlay-Messages-Tapbacks.jpg\" alt=\"CarPlay-Messages-Tapbacks.jpg\"></span></p><p><br></p><p><span style=\"background-color: initial; color: inherit;\">Hai bổ sung lớn nhất là việc đưa Live Activities và Widget lên CarPlay. Màn hình Dashboard giờ đây có thể hiển thị các Live Activities để theo dõi thông tin thời gian thực, trong khi một màn hình widget riêng cho phép truy cập nhanh vào lịch, điều khiển thiết bị HomeKit.</span></p><p><br></p><p><span style=\"background-color: initial; color: inherit;\"><img src=\"https://photo2.tinhte.vn/data/attachment-files/2025/11/8885140_64001-133195-Live-Activity-in-CarPlay-xl.jpg\" alt=\"64001-133195-Live-Activity-in-CarPlay-xl.jpg\"></span></p><p><br></p><p><span style=\"background-color: initial; color: inherit;\">Đặc biệt, iOS 26.1 còn mang tính năng AirPlay lên CarPlay, cho phép truyền phát video không dây từ&nbsp;</span><a href=\"https://tinhte.vn/tag/iphone\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"background-color: initial; color: rgb(7, 104, 234);\">iPhone</a><span style=\"background-color: initial; color: inherit;\">&nbsp;lên màn hình của xe khi đang đỗ, một tính năng rất được mong chờ.</span></p><p><br></p><h2><strong style=\"background-color: initial; color: inherit;\">Các tinh chỉnh nhỏ nhưng đáng giá khác</strong></h2><p><br></p><p><span style=\"background-color: initial; color: inherit;\">Bên cạnh những thay đổi lớn, iOS 26.1 còn mang đến hàng loạt các cải tiến nhỏ trên toàn hệ thống. Trong ứng dụng Cài đặt, toàn bộ các tiêu đề mục như Cài đặt chung, Bluetooth, Wi-Fi... giờ đây đã được căn lề trái đồng bộ để tạo sự nhất quán. Hiệu ứng khúc xạ ánh sáng của Liquid Glass xung quanh các biểu tượng ứng dụng cũng được làm cho tinh tế và nhẹ nhàng hơn.</span></p><p><br></p><p><span style=\"background-color: initial; color: inherit;\"><img src=\"https://photo2.tinhte.vn/data/attachment-files/2025/11/8885141_8859363-ios-26-1-left-aligned-settings.jpg\" alt=\"8859363-ios-26-1-left-aligned-settings.jpg\"></span></p><p><br></p><p><span style=\"background-color: initial; color: inherit;\">Ứng dụng Apple Music có thêm cử chỉ vuốt mới để chuyển bài hát, ae chỉ cần muốn thanh phat nhạc là dược. Trên Apple Music, tính năng Crossfade cũ đã được thay thế bằng AutoMix, giúp tự động tạo ra các đoạn chuyển tiếp giữa các bài hát, riêng mình thì thấy tính năng này hơi xàm. À à, thông qua bản cập nhật này Airpods cũng được cập nhật tính năng dịch trực tiếp.</span></p><p><br></p><p><span style=\"background-color: initial; color: inherit;\"><img src=\"https://photo2.tinhte.vn/data/attachment-files/2025/11/8885142_apple-music-automix-ios-26.jpg\" alt=\"apple-music-automix-ios-26.jpg\"></span></p><p><br></p><h2><strong style=\"background-color: initial; color: inherit;\">Kết luận: Một bản cập nhật đáng nâng cấp</strong></h2><p><br></p><p><span style=\"background-color: initial; color: inherit;\">iOS 26.1 không phải là một cuộc cách mạng hay gì đó quá ghê gớm. Nó đã biến những ý tưởng của iOS 26 trở nên hoàn thiện, thực tế và thân thiện hơn với người dùng. Apple mang trở lại các tính năng được cộng đồng yêu thích như Slide Over, hay giải quyết các vấn đề nhỏ nhưng gây khó chịu như nút tắt báo thức.</span></p><p><br></p><p><span style=\"background-color: initial; color: inherit;\"><img src=\"https://photo2.tinhte.vn/data/attachment-files/2025/11/8885143_8860852-tinhte-tu-review-ios-26-3.jpg\" alt=\"8860852-tinhte-tu-review-ios-26-3.jpg\"></span></p><p><br></p><p><span style=\"background-color: initial; color: inherit;\">Trên hết, việc Apple Intelligence chính thức hỗ trợ tiếng Việt đã mở ra một điều gì đó hay ho cho người dùng iPhone tại Việt Nam. Dù vẫn còn một vài tính năng cần được cải thiện, nhưng những gì iOS 26.1 mang lại ở thời điểm hiện tại đã là quá đủ để nói đây là một bản cập nhật rất đáng giá, giúp trải nghiệm iOS trở nên trọn vẹn hơn, mình đang chạy beta thấy vẫn ngon lành cành đào...</span></p><p>ẩm mới...</p>', 'Tóm tắt về sản phẩm mới', 'Admin', 'Tin tức', 'PUBLISHED', 'f40e0038-70de-4459-8d39-13dfaefbd2ce_0b021a98-99b1-458f-add3-6464701ce854_giay-adidas-adifom-superstar-white-black-10-800x650.jpg', 180, '2025-11-04 18:00:12', '2025-11-04 11:30:34', '2025-11-05 03:04:01', NULL),
(2, 'Hướng dẫn sử dụng', '<p>Hướng dẫn chi tiết cách sử dụng sản phẩm...</p>', 'Tóm tắt hướng dẫn', 'Admin', 'Hướng dẫn', 'PUBLISHED', '0a348d98-7cb3-4f96-9530-9b80f9c859f3_giay-mlb-chunky-liner-mid-denim-boston-red-sox-dblue-auth-5-300x300.jpg.jpg', 136, '2025-11-05 17:41:56', '2025-11-04 11:30:34', '2025-11-06 01:09:35', NULL),
(3, 'GIảm giá 30% khi mua khoá vân tay Welkom', '<h1>GIẢM GIÁ 30% KHI MUA KHOÁ VÂN TAY WELKOM: Nâng Tầm An Ninh Gia Đình Với Công Nghệ Hiện Đại</h1><p>Trong bối cảnh công nghệ đang phát triển vũ bão, việc đảm bảo an ninh cho ngôi nhà và tài sản đã trở thành ưu tiên hàng đầu của mọi gia đình. Không chỉ dừng lại ở những chiếc khóa cơ truyền thống, thế giới khóa điện tử và công nghệ an ninh đã mở ra một kỷ nguyên mới với sự xuất hiện của các giải pháp thông minh, trong đó nổi bật là khóa vân tay. Sự tiện lợi, bảo mật vượt trội và tính thẩm mỹ cao đã biến khóa vân tay từ một sản phẩm xa xỉ thành một lựa chọn thiết yếu cho tổ ấm hiện đại. Đây không chỉ là một thiết bị bảo vệ mà còn là một phần quan trọng của hệ sinh thái nhà thông minh, mang lại trải nghiệm sống tiện nghi và an toàn hơn bao giờ hết.</p><p>Thấu hiểu nhu cầu đó, và nhằm tạo điều kiện cho nhiều gia đình Việt Nam tiếp cận với công nghệ bảo mật tiên tiến, chúng tôi vui mừng thông báo về chương trình <strong>khuyến mãi đặc biệt</strong>: <strong>GIẢM GIÁ 30% khi mua khóa vân tay Welkom</strong>. Đây là cơ hội vàng để quý vị nâng cấp hệ thống an ninh cho ngôi nhà của mình với mức đầu tư tối ưu. Chương trình này không chỉ là một ưu đãi về giá, mà còn là lời cam kết mang đến những sản phẩm chất lượng cao, tích hợp công nghệ hiện đại nhất từ Welkom, một thương hiệu uy tín trong lĩnh vực khóa điện tử. Hãy cùng chúng tôi đi sâu vào tìm hiểu lý do vì sao khóa vân tay Welkom lại là sự lựa chọn hoàn hảo và cách tận dụng chương trình khuyến mãi hấp dẫn này.</p><h2>Sự Trỗi Dậy Của Khóa Vân Tay Trong Thời Đại Số Hóa An Ninh</h2><p>Thị trường khóa cửa đã chứng kiến một sự chuyển mình mạnh mẽ trong thập kỷ qua, với sự thay thế dần của khóa cơ truyền thống bằng các giải pháp khóa điện tử và khóa thông minh. Trong số đó, khóa vân tay đã nhanh chóng chiếm lĩnh vị trí dẫn đầu nhờ những ưu điểm vượt trội về bảo mật và tiện lợi. Thay vì phải lo lắng về việc mất chìa khóa, quên mã số, hay bị sao chép chìa một cách trái phép, công nghệ sinh trắc học cho phép người dùng mở cửa chỉ bằng một chạm tay, sử dụng chính dấu vân tay độc nhất của mình. Điều này không chỉ giúp tiết kiệm thời gian mà còn loại bỏ hoàn toàn nguy cơ mất an toàn do sơ suất cá nhân. Khóa vân tay là minh chứng rõ ràng cho việc công nghệ có thể đơn giản hóa cuộc sống đồng thời tăng cường lớp bảo vệ.</p><p>Hơn nữa, các mẫu khóa vân tay hiện đại như Welkom thường được tích hợp nhiều phương thức mở khóa khác nhau, bao gồm mã số, thẻ từ, chìa cơ dự phòng và thậm chí là điều khiển qua ứng dụng di động. Sự đa dạng này đảm bảo rằng người dùng luôn có phương án dự phòng trong mọi tình huống, từ việc hết pin khẩn cấp cho đến việc cấp quyền truy cập tạm thời cho khách hoặc người giúp việc mà không cần phải trao chìa khóa vật lý. Đây là một bước tiến đáng kể so với khóa truyền thống, nơi mà việc quản lý chìa khóa trở nên phức tạp và dễ gây ra rủi ro an ninh. Sự kết hợp giữa tiện ích và tính năng bảo mật đa lớp chính là yếu tố then chốt giúp khóa vân tay trở thành lựa chọn ưu việt cho ngôi nhà hiện đại.</p><h2>Công Nghệ Vân Tay: Nền Tảng Của An Toàn và Tiện Nghi</h2><p>Trọng tâm của khóa vân tay nằm ở công nghệ nhận dạng sinh trắc học, cụ thể là dấu vân tay. Hiện nay, có hai loại cảm biến vân tay phổ biến được sử dụng trong khóa điện tử: cảm biến quang học và cảm biến điện dung. Cảm biến quang học hoạt động bằng cách chụp ảnh bề mặt vân tay và so sánh với dữ liệu đã lưu trữ, trong khi cảm biến điện dung sử dụng điện trường để tạo bản đồ chi tiết của các rãnh vân tay. Công nghệ cảm biến điện dung, thường được tìm thấy trên các thiết bị cao cấp như Welkom, có độ chính xác và khả năng chống làm giả cao hơn, vì nó đòi hỏi sự tiếp xúc trực tiếp với da người sống. Điều này giảm thiểu đáng kể rủi ro bị mở khóa bằng vân tay giả hoặc vân tay từ vật thể không phải là ngón tay thật.</p><p>Ngoài ra, hệ thống xử lý vân tay trên các khóa thông minh hiện đại còn được trang bị thuật toán học máy (Machine Learning), giúp cải thiện khả năng nhận diện theo thời gian. Mỗi lần người dùng đặt tay lên cảm biến, hệ thống không chỉ xác minh mà còn học hỏi, điều chỉnh để nhận diện vân tay nhanh và chính xác hơn, ngay cả khi ngón tay bị ướt, bẩn nhẹ hoặc có vết xước nhỏ. Điều này mang lại trải nghiệm sử dụng liền mạch và đáng tin cậy. Hơn nữa, khả năng lưu trữ hàng trăm dấu vân tay cho phép một ngôi nhà có thể cấp quyền truy cập cho tất cả thành viên trong gia đình, bạn bè thân thiết hoặc nhân viên một cách dễ dàng, đồng thời có thể xóa bỏ quyền truy cập bất cứ lúc nào khi cần thiết. Đây là một ưu điểm vượt trội so với việc phải thay khóa hoặc sao chép chìa khi có sự thay đổi về người sử dụng.</p><h2>Welkom: Sự Kết Hợp Hoàn Hảo Giữa Thiết Kế và Công Nghệ Bảo Mật</h2><p>Khóa vân tay Welkom không chỉ đơn thuần là một thiết bị an ninh; đó là một tuyên bố về phong cách sống và sự cam kết đối với an toàn. Các sản phẩm của Welkom được thiết kế với sự chú trọng cao đến cả tính thẩm mỹ và hiệu suất. Với kiểu dáng hiện đại, đường nét tinh tế và chất liệu cao cấp (thường là hợp kim kẽm hoặc thép không gỉ), khóa Welkom dễ dàng hòa nhập vào mọi không gian kiến trúc, từ căn hộ chung cư hiện đại đến biệt thự sang trọng. Nhưng vẻ đẹp bên ngoài chỉ là khởi đầu; sức mạnh thực sự của Welkom nằm ở công nghệ bảo mật tiên tiến được tích hợp bên trong.</p><p>Mỗi chiếc khóa Welkom đều được trang bị bộ vi xử lý mạnh mẽ, hệ thống mã hóa dữ liệu tiên tiến và các cảm biến vân tay chính xác, đảm bảo rằng mọi giao dịch mở khóa đều an toàn và riêng tư. Khả năng chống nước và chống bụi đạt chuẩn, cùng với khả năng chịu được nhiệt độ và độ ẩm khắc nghiệt, giúp khóa Welkom hoạt động bền bỉ trong nhiều điều kiện môi trường khác nhau. Hơn nữa, Welkom còn tích hợp các tính năng thông minh như cảnh báo đột nhập trái phép, cảnh báo pin yếu, và khả năng xem lại lịch sử ra vào qua ứng dụng di động. Điều này biến cánh cửa của bạn thành một trung tâm điều khiển an ninh mini, cho phép bạn kiểm soát và giám sát từ xa mọi lúc, mọi nơi, mang lại sự yên tâm tuyệt đối cho gia đình.</p><h2>Tích Hợp IoT và Nhà Thông Minh: Khóa Welkom trong Hệ Sinh Thái Số</h2><p>Trong kỷ nguyên Internet of Things (IoT), khóa vân tay Welkom không chỉ là một thiết bị độc lập mà còn là một mắt xích quan trọng trong hệ sinh thái nhà thông minh. Khả năng kết nối không dây qua Wi-Fi hoặc Bluetooth cho phép khóa Welkom giao tiếp với các thiết bị thông minh khác trong nhà, tạo ra một hệ thống an ninh và tiện nghi liền mạch. Ví dụ, bạn có thể thiết lập kịch bản tự động để khi bạn mở cửa bằng vân tay, đèn trong nhà sẽ tự động bật, điều hòa không khí khởi động và hệ thống âm thanh phát nhạc chào đón. Ngược lại, khi khóa cửa từ bên ngoài, tất cả các thiết bị điện không cần thiết có thể tự động tắt, giúp tiết kiệm năng lượng.</p><p>Khả năng quản lý từ xa qua ứng dụng di động là một trong những tính năng được đánh giá cao nhất. Dù bạn đang ở văn phòng, đi du lịch hay chỉ đơn giản là không có mặt ở nhà, bạn vẫn có thể cấp quyền truy cập tạm thời cho người thân, dịch vụ giao hàng hoặc thợ sửa chữa thông qua mã số dùng một lần hoặc mã số có thời hạn. Bạn cũng có thể theo dõi lịch sử ra vào chi tiết, nhận cảnh báo ngay lập tức nếu có bất kỳ hoạt động đáng ngờ nào tại cửa. Sự tích hợp này không chỉ tăng cường bảo mật mà còn nâng cao đáng kể sự tiện nghi và linh hoạt trong quản lý ngôi nhà, biến ngôi nhà của bạn thực sự trở thành một \"ngôi nhà thông minh\" theo đúng nghĩa.</p><h2>Lời Khuyên Chuyên Gia: Lựa Chọn và Bảo Trì Khóa Vân Tay Welkom</h2><p>Để đảm bảo tận dụng tối đa lợi ích từ khóa vân tay Welkom, việc lựa chọn sản phẩm phù hợp và bảo trì đúng cách là vô cùng quan trọng. Trước khi mua, hãy xem xét kỹ lưỡng các yếu tố như loại cửa (gỗ, thép, cửa kính), độ dày đố cửa, và hướng mở cửa để chọn mẫu khóa tương thích. Welkom cung cấp nhiều dòng sản phẩm đa dạng, từ khóa cửa chính, cửa phòng ngủ đến cửa cổng, mỗi loại có những đặc điểm và yêu cầu lắp đặt riêng. Đừng ngần ngại tham khảo ý kiến từ các chuyên gia hoặc nhân viên tư vấn để có được lựa chọn tối ưu nhất cho ngôi nhà của bạn. Về tính năng, hãy ưu tiên các mẫu có nhiều phương thức mở khóa (vân tay, mã số, thẻ từ, chìa cơ, app) và các tính năng cảnh báo thông minh, tích hợp nhà thông minh để đảm bảo an toàn và tiện lợi toàn diện.</p><p>Về bảo trì, mặc dù khóa vân tay Welkom được thiết kế để hoạt động bền bỉ, nhưng việc chăm sóc định kỳ sẽ giúp kéo dài tuổi thọ và duy trì hiệu suất. Hãy đảm bảo vệ sinh bề mặt cảm biến vân tay và bàn phím mã số thường xuyên bằng vải mềm và khô để loại bỏ bụi bẩn và dầu mỡ. Kiểm tra và thay pin định kỳ (thường là 6-12 tháng một lần, tùy theo tần suất sử dụng và loại pin) là rất quan trọng để tránh tình trạng khóa hết pin đột ngột. Hầu hết các khóa Welkom đều có cảnh báo pin yếu, vì vậy hãy chú ý đến tín hiệu này. Ngoài ra, hãy thường xuyên cập nhật phần mềm hoặc firmware của khóa (nếu có) thông qua ứng dụng để đảm bảo hệ thống bảo mật luôn được vá lỗi và nâng cấp các tính năng mới nhất, giữ cho khóa của bạn luôn hoạt động ở trạng thái tốt nhất và an toàn nhất.</p><h2>Tóm Tắt Khuyến Mãi: Cơ Hội Vàng Để Nâng Cấp An Ninh</h2><p>Chương trình <strong>GIẢM GIÁ 30% khi mua khóa vân tay Welkom</strong> không chỉ là một cơ hội tiết kiệm chi phí mà còn là một bước đầu tư thông minh vào sự an toàn và tiện nghi cho tổ ấm của bạn. Đây là thời điểm lý tưởng để bạn loại bỏ những chiếc chìa khóa lỉnh kỉnh, những lo lắng về an ninh và chào đón một kỷ nguyên mới của sự tiện lợi và bảo mật vượt trội. Với mức giảm giá hấp dẫn này, việc sở hữu một chiếc khóa vân tay cao cấp từ Welkom trở nên dễ dàng và phải chăng hơn bao giờ hết. Chúng tôi tin rằng, mỗi gia đình đều xứng đáng được trải nghiệm những công nghệ bảo mật tiên tiến nhất, và Welkom cam kết mang đến những giải pháp tốt nhất để bảo vệ những gì quý giá nhất của bạn.</p><p>Hãy nhanh chóng nắm bắt cơ hội có một không hai này. Chương trình khuyến mãi có thời hạn và số lượng sản phẩm có thể có giới hạn. Đừng bỏ lỡ dịp để biến ngôi nhà của bạn thành một pháo đài an toàn và hiện đại hơn với khóa vân tay Welkom. Liên hệ ngay với các đại lý hoặc truy cập website chính thức của Welkom để biết thêm thông tin chi tiết về các mẫu khóa áp dụng, điều khoản và điều kiện của chương trình. An toàn của gia đình bạn là ưu tiên hàng đầu, và với Welkom, bạn có thể hoàn toàn yên tâm. <strong>Tóm tắt khuyến mãi</strong>: Chương trình <strong>GIẢM GIÁ 30%</strong> áp dụng cho các sản phẩm khóa vân tay Welkom, mang đến công nghệ bảo mật hàng đầu với mức giá ưu đãi chưa từng có. Hãy hành động ngay để không bỏ lỡ!</p><h1><br></h1>', 'Tóm tắt khuyến mãi', 'Admin', 'Khuyến mãi', 'PUBLISHED', 'd0ce9b71-438e-47b0-bf54-6f3dde8f9abf_SHS-2920_1.jpg', 206, '2025-11-05 17:42:19', '2025-11-04 11:30:34', '2025-11-06 01:10:19', NULL),
(5, 'Ra mắt Khóa vân tay Samsung SHP-DH538', '<h2><strong style=\"background-color: initial;\"><em>Khóa vân tay Samsung SHP-DH538:</em></strong></h2><p>- Mở bằng: vân tay, mã số, chìa cơ (dự phòng)</p><h4><strong style=\"background-color: initial; color: rgb(204, 0, 0);\"><em>- Giá: 5.490.000 đồng</em></strong></h4><iframe class=\"ql-video\" frameborder=\"0\" allowfullscreen=\"true\" src=\"https://www.youtube.com/embed/4ldAlQJer5w?showinfo=0\"></iframe><p class=\"ql-align-center\"><br></p><p><strong style=\"color: rgb(119, 119, 119);\">1. Chức năng cơ bản</strong></p><p>Khóa cửa điện tử Samsung SHP DH538 với thiết kế màu đỏ đồng phù hợp với các căn hộ sang trọng. Công nghệ quét vân tay quang học và mã số ngẫu nhiên, cùng hệ thống cảnh báo đột nhập sẽ đem lại sự an toàn và tiện lợi đến căn hộ của bạn.</p><p><br></p><p><span style=\"background-color: initial; color: rgb(0, 0, 238);\"><img src=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEitN1ag8THMYP6RRfGExIy4WoW215YjBgcVtmZKXS0naO-aen-OLqV6EdzrBLHgH32co26LxCr-pmaRPXV290CI7uL46Z1dcVZOZSzOlK_qiMl26AbCdnsUPha_V3roELfwKVysRErqigeB/w640-h212/Screenshot-365-1024x340.png\" height=\"212\" width=\"640\"></span></p><p><br></p><p class=\"ql-align-center\"><a href=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhyqgdga_-zcWFx6gF5igT7FBpefisGLWYKv4PHxkkXU5M4OG64dlEEf_H0qvOucwXmBUaB1-50LY2vFWbcK5qazfIO1YO98vG9cMiNnSpX7Vi2oXMJhAXYRr2Pi44LmSp9yFmVNTi2WNgD/s1024/Screenshot-362-2-1024x496-1.jpg\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"background-color: initial; color: rgb(191, 30, 45);\"><img src=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhyqgdga_-zcWFx6gF5igT7FBpefisGLWYKv4PHxkkXU5M4OG64dlEEf_H0qvOucwXmBUaB1-50LY2vFWbcK5qazfIO1YO98vG9cMiNnSpX7Vi2oXMJhAXYRr2Pi44LmSp9yFmVNTi2WNgD/w640-h310/Screenshot-362-2-1024x496-1.jpg\" height=\"310\" width=\"640\"></a></p><p><br></p><p class=\"ql-align-center\"><a href=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEh9WfkszxYZICvwC_HcVI2n3nxg9fQ1gr2tyTtM3wX45onDY_fo6nz5Ez83t47N9f1laxixaBYxJQaltsL25PUDIixk7St5jHFFyM0NRnjTJNEEiNJB4G_YqHvphGrkqvQ52mFb11g12FRn/s1024/Screenshot-366-3-1024x587.png\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"background-color: initial; color: rgb(191, 30, 45);\"><img src=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEh9WfkszxYZICvwC_HcVI2n3nxg9fQ1gr2tyTtM3wX45onDY_fo6nz5Ez83t47N9f1laxixaBYxJQaltsL25PUDIixk7St5jHFFyM0NRnjTJNEEiNJB4G_YqHvphGrkqvQ52mFb11g12FRn/w640-h366/Screenshot-366-3-1024x587.png\" height=\"366\" width=\"640\"></a></p><p><br></p><p class=\"ql-align-center\"><a href=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgMTvZvsaQXjXVTTqpimFXvMsx0Rz9V1U-N2c3ymxYWx2mp5qDGTLsNHC-DrRjznpDuYTDNPTBI8SOfHh9hPwI4CFYCxq9QZY-wUGZ_OCLehXWYbRtpEFn4TNgBTtvAKX1OdRH4Y51HwBRt/s1024/Screenshot-368-2-1024x620.png\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"background-color: initial; color: rgb(191, 30, 45);\"><img src=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgMTvZvsaQXjXVTTqpimFXvMsx0Rz9V1U-N2c3ymxYWx2mp5qDGTLsNHC-DrRjznpDuYTDNPTBI8SOfHh9hPwI4CFYCxq9QZY-wUGZ_OCLehXWYbRtpEFn4TNgBTtvAKX1OdRH4Y51HwBRt/w640-h388/Screenshot-368-2-1024x620.png\" height=\"388\" width=\"640\"></a></p><p><br></p><p class=\"ql-align-center\"><a href=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjDXBiy2-BavdmqssMDSnpFlAAvHdVvwsH0AnOUd06mmiARCHuIZrhuP-3ajV4S_iPnxr4hasItAVRCU7IQwXQQpisbPZfFDjehnYk2LKddUp7fW87qhaocfqlUJqehR1oWjqqmVN3Xd-Za/s1024/Screenshot-370-2-1024x577-1.jpg\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"background-color: initial; color: rgb(191, 30, 45);\"><img src=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjDXBiy2-BavdmqssMDSnpFlAAvHdVvwsH0AnOUd06mmiARCHuIZrhuP-3ajV4S_iPnxr4hasItAVRCU7IQwXQQpisbPZfFDjehnYk2LKddUp7fW87qhaocfqlUJqehR1oWjqqmVN3Xd-Za/w640-h360/Screenshot-370-2-1024x577-1.jpg\" height=\"360\" width=\"640\"></a></p><p><br></p><p class=\"ql-align-center\"><a href=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhCAKCrUustusR9ei3Dkafz-uMnbDkpt2yf-RGTN3TZmgcM5Ma8OR3rv5BDh0iX72R4ff886tGGrfnIVuti1ud_5uMP1_mo1uwzsQ1VOyIT1nBCCAQIk4RVeWgUaVRATAfkGZpK6zN0cspa/s510/Screenshot-372-1-510x289.png\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"background-color: initial; color: rgb(191, 30, 45);\"><img src=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhCAKCrUustusR9ei3Dkafz-uMnbDkpt2yf-RGTN3TZmgcM5Ma8OR3rv5BDh0iX72R4ff886tGGrfnIVuti1ud_5uMP1_mo1uwzsQ1VOyIT1nBCCAQIk4RVeWgUaVRATAfkGZpK6zN0cspa/w640-h362/Screenshot-372-1-510x289.png\" height=\"362\" width=\"640\"></a></p><p><br></p><p class=\"ql-align-center\"><a href=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEg7aGYa-7BxFJ_i3xbGuG5tDPs2Fg9kuNChMiAXvvfWg6VNcX7ijXzzX7Z3ZShGir2RAvcjqSnCdEtF23hIQhePo32CE3DU3hI7rA8aNtf4ZFq-hzKSEUCqf7oWczpE-qBOxWpJAipZbmmp/s1024/Screenshot-372-2-1024x580.png\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"background-color: initial; color: rgb(191, 30, 45);\"><img src=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEg7aGYa-7BxFJ_i3xbGuG5tDPs2Fg9kuNChMiAXvvfWg6VNcX7ijXzzX7Z3ZShGir2RAvcjqSnCdEtF23hIQhePo32CE3DU3hI7rA8aNtf4ZFq-hzKSEUCqf7oWczpE-qBOxWpJAipZbmmp/w640-h362/Screenshot-372-2-1024x580.png\" height=\"362\" width=\"640\"></a></p><p><br></p><p class=\"ql-align-center\"><a href=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgP9DpsDZpw9k5BhdFCFPDXzo9azB3feYl4ML5WZl8ooLoyNHeNPySwcEY_OWrcJdwrsjG6mPW_Eli1Pc7wdDqzFOIBUSJu04fQScdWmUqCpagcB-6zlRc9SCLnpQownCipdDP0a7wWAJGa/s1024/Screenshot-374-2-1024x591.png\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"background-color: initial; color: rgb(191, 30, 45);\"><img src=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgP9DpsDZpw9k5BhdFCFPDXzo9azB3feYl4ML5WZl8ooLoyNHeNPySwcEY_OWrcJdwrsjG6mPW_Eli1Pc7wdDqzFOIBUSJu04fQScdWmUqCpagcB-6zlRc9SCLnpQownCipdDP0a7wWAJGa/w640-h370/Screenshot-374-2-1024x591.png\" height=\"370\" width=\"640\"></a></p><p><br></p><p class=\"ql-align-center\"><a href=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEh0fNo5Qbq5wt4Ovq1TBq_9gk0QxqUrFgO1MbZLsqO73_N-ZLr5Z6rBUutmyr0xOivrNv_Q9SoAOCDLSLmygysVuGXor9p-1D8h91EVKEKNL3dH20enL4F4t8Lyj2djR94GSh3NzeEOTZWS/s1024/Screenshot-376-2-1024x552.png\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"background-color: initial; color: rgb(191, 30, 45);\"><img src=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEh0fNo5Qbq5wt4Ovq1TBq_9gk0QxqUrFgO1MbZLsqO73_N-ZLr5Z6rBUutmyr0xOivrNv_Q9SoAOCDLSLmygysVuGXor9p-1D8h91EVKEKNL3dH20enL4F4t8Lyj2djR94GSh3NzeEOTZWS/w640-h344/Screenshot-376-2-1024x552.png\" height=\"344\" width=\"640\"></a></p><p><br></p><p class=\"ql-align-center\"><a href=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEh82Bf9-6POfLFXfOr1E2rkmbN-pJ5hXLnsl0fhnAPkWsH8FVxT-kr7zBP-d0qvxct_SzbW2eLpDQKqSwSvG2L2m93zVZbjE9c7vu67HNIMqT0yhYhAZflMrGItf7-0irZTlSwXK-cGWBno/s1024/Screenshot-380-2-1024x580.png\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"background-color: initial; color: rgb(191, 30, 45);\"><img src=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEh82Bf9-6POfLFXfOr1E2rkmbN-pJ5hXLnsl0fhnAPkWsH8FVxT-kr7zBP-d0qvxct_SzbW2eLpDQKqSwSvG2L2m93zVZbjE9c7vu67HNIMqT0yhYhAZflMrGItf7-0irZTlSwXK-cGWBno/w640-h362/Screenshot-380-2-1024x580.png\" height=\"362\" width=\"640\"></a></p><p><br></p><p class=\"ql-align-center\"><a href=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhdu4zX0mrI7mdyJNcHkFC4QhtztqNiNd04qLX6cXo2eTsHW5XwAkZS3kPP0ocSg01dSQgSnoNXxs40SJ9jNQDT0mazvGXOQSNkbZE3IiKcjHmBEhIoKpPGfi0mSpsWFRNu5Et-Ismlbves/s1024/Screenshot-385-2-1024x587.png\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"background-color: initial; color: rgb(191, 30, 45);\"><img src=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhdu4zX0mrI7mdyJNcHkFC4QhtztqNiNd04qLX6cXo2eTsHW5XwAkZS3kPP0ocSg01dSQgSnoNXxs40SJ9jNQDT0mazvGXOQSNkbZE3IiKcjHmBEhIoKpPGfi0mSpsWFRNu5Et-Ismlbves/w640-h366/Screenshot-385-2-1024x587.png\" height=\"366\" width=\"640\"></a></p><p><br></p><p class=\"ql-align-center\"><a href=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhFYFoEpvedT4hh3XkWGNOs6HyxbOPS5dk-RcMHQhTFKIPYm25nskOjUPDmx1IcoAFKIjnpb3YrN27LVoCU10kQFpu_4e7BW6zzDzudC-4GDpDtWZMEUav1h0SCasTsND40LqQAYAlloL_w/s1024/Screenshot-386-2-1024x536.png\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"background-color: initial; color: rgb(191, 30, 45);\"><img src=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhFYFoEpvedT4hh3XkWGNOs6HyxbOPS5dk-RcMHQhTFKIPYm25nskOjUPDmx1IcoAFKIjnpb3YrN27LVoCU10kQFpu_4e7BW6zzDzudC-4GDpDtWZMEUav1h0SCasTsND40LqQAYAlloL_w/w640-h336/Screenshot-386-2-1024x536.png\" height=\"336\" width=\"640\"></a></p><p><br></p><p><strong style=\"background-color: initial;\">2. Thông số kĩ thuật&nbsp;khóa Samsung&nbsp;SHP-DH538</strong></p><p><strong style=\"background-color: initial;\">Vân tay và mã số</strong>Mã số: 4~12 ký tự điện tử</p><p>Công nghệ cảm ứng điện dung</p><p><strong style=\"background-color: initial;\">Bộ nhớ vân tay tối đa</strong>100<strong style=\"background-color: initial;\">Kích thướcThân ngoài</strong>81.8(W) X 320(H) X 66.8(D)mm<strong style=\"background-color: initial;\">Thân trong</strong>79(W) X 290(H) X 80.3(D)mm<strong style=\"background-color: initial;\">Độ dày cửa thích hợp</strong>40~80mm<strong style=\"background-color: initial;\">Nguồn</strong>8 viên pin AA Alkaline Batteries<strong style=\"background-color: initial;\">Thời gian cần thay pin</strong>Xấp xỉ 12 tháng<strong style=\"background-color: initial;\">Màu</strong>Đen, đỏ đồng</p>', '- Mở bằng: vân tay, mã số, chìa cơ (dự phòng)\n\n- Giá: 5.490.000 đồng', NULL, 'Tin tức', 'PUBLISHED', '38a51683-a41c-4740-a173-a8ceac011b7a_SHS-P718_3-4.png', 16, '2025-11-04 18:00:04', '2025-11-04 13:50:37', '2025-11-05 01:55:34', NULL),
(6, 'Các công nghệ Khoá cửa mới ứng dụng Trí tuệ nhân tạo', '<h1><br></h1><h2>Mở đầu</h2><p>Trong kỷ nguyên số hóa không ngừng, sự tiến bộ của <strong>công nghệ</strong> đã và đang định hình lại mọi khía cạnh của cuộc sống, từ cách chúng ta giao tiếp đến cách chúng ta bảo vệ không gian riêng tư. Đặc biệt, lĩnh vực an ninh gia đình đã chứng kiến một cuộc cách mạng mạnh mẽ với sự xuất hiện của các thiết bị <strong>khóa điện tử</strong> và <strong>smart lock</strong>. Tuy nhiên, nếu chỉ dừng lại ở việc mở khóa bằng vân tay, mã số hay thẻ từ thì đó mới chỉ là bước khởi đầu. Ngày nay, với sự tích hợp của <strong>Trí tuệ nhân tạo (AI)</strong>, các hệ thống khóa cửa đã vượt xa giới hạn thông thường, mang đến một cấp độ <strong>bảo mật</strong>, tiện lợi và thông minh hoàn toàn mới.</p><p>Bài viết này sẽ đi sâu vào khám phá cách AI đang cách mạng hóa ngành khóa cửa, từ việc tăng cường khả năng nhận diện sinh trắc học, phân tích hành vi người dùng, đến việc tích hợp liền mạch vào hệ sinh thái nhà thông minh. Chúng ta cũng sẽ tìm hiểu những lợi ích vượt trội mà công nghệ này mang lại, cũng như những thách thức cần đối mặt và những lời khuyên hữu ích để người dùng có thể đưa ra lựa chọn sáng suốt nhất cho ngôi nhà của mình.</p><p><br></p><h2>Nội dung chính</h2><h3>1. AI nâng tầm bảo mật và tiện ích của Khóa thông minh</h3><p>Ban đầu, các loại <strong>khóa điện tử</strong> và <strong>smart lock</strong> đã gây ấn tượng với khả năng mở khóa không cần chìa vật lý, điều khiển từ xa và ghi nhận lịch sử ra vào. Nhưng khi AI được đưa vào, chúng không chỉ còn là thiết bị thực hiện lệnh đơn thuần mà đã trở thành \"người gác cổng\" thông minh, có khả năng học hỏi, thích nghi và thậm chí là dự đoán. AI giúp nâng cao đáng kể độ chính xác và tốc độ của các phương thức xác thực sinh trắc học như <strong>nhận diện vân tay</strong> và <strong>nhận diện khuôn mặt</strong>. Các thuật toán AI có thể phân tích hàng triệu điểm dữ liệu từ vân tay hay đặc điểm khuôn mặt, giúp phân biệt giữa người thật và các hành vi giả mạo một cách hiệu quả hơn bao giờ hết, ngay cả trong điều kiện ánh sáng yếu hoặc khi có sự thay đổi nhỏ trên khuôn mặt.</p><p>Hơn nữa, AI còn cho phép khóa cửa học hỏi các thói quen và lịch trình của người dùng. Ví dụ, nếu bạn thường xuyên về nhà vào một giờ cố định, khóa có thể tự động chuẩn bị mở khóa khi bạn đến gần. Khả năng này không chỉ tăng cường tiện ích mà còn là nền tảng cho các hệ thống an ninh chủ động hơn. Với <strong>xu hướng công nghệ IoT</strong> phát triển mạnh mẽ, các <strong>khóa thông minh AI</strong> trở thành một mắt xích quan trọng trong hệ sinh thái <strong>smart home</strong>, kết nối với các thiết bị khác như camera an ninh, đèn chiếu sáng, và hệ thống báo động để tạo ra một mạng lưới an ninh đồng bộ và thông minh.</p><h3>2. Các ứng dụng AI đột phá trong công nghệ khóa cửa</h3><p>Sự tích hợp của AI mang đến nhiều ứng dụng vượt trội, biến khóa cửa không chỉ là một thiết bị bảo vệ mà còn là một phần của hệ thống quản lý an ninh toàn diện:</p><ul><li><strong>Nhận diện sinh trắc học thông minh thích ứng:</strong> AI cho phép các cảm biến vân tay và camera nhận diện khuôn mặt \"học\" và thích nghi với sự thay đổi. Chẳng hạn, cảm biến vân tay có thể nhận diện chính xác ngay cả khi tay bạn hơi ướt, bẩn, hoặc có vết thương nhỏ. Công nghệ <strong>nhận diện khuôn mặt</strong> được hỗ trợ bởi AI có thể phân biệt người thật với hình ảnh hoặc mặt nạ 3D, thậm chí còn có khả năng nhận diện cảm xúc để phát hiện các hành vi đáng ngờ.</li><li><strong>Phân tích hành vi và phát hiện bất thường:</strong> Đây là một trong những ứng dụng mạnh mẽ nhất của AI. Khóa AI có thể theo dõi và học hỏi các mô hình truy cập thông thường của bạn và gia đình. Khi có bất kỳ hành vi nào lệch khỏi mô hình này (ví dụ: cố gắng mở khóa vào những thời điểm bất thường, số lần nhập sai mã PIN liên tục vượt quá mức cho phép), hệ thống sẽ tự động gửi cảnh báo đến điện thoại của bạn hoặc kích hoạt các biện pháp an ninh khác như bật còi báo động, ghi hình qua camera.</li><li><strong>Quản lý truy cập tự động và thông minh:</strong> AI tối ưu hóa việc cấp quyền truy cập. Thay vì phải cài đặt thủ công từng quyền cho từng người, AI có thể gợi ý hoặc tự động cấp quyền tạm thời dựa trên lịch trình đã định sẵn (ví dụ: cho nhân viên dọn dẹp, người giao hàng). Nó cũng có thể tự động khóa cửa khi phát hiện không có ai ở nhà, hoặc mở cửa khi bạn về mà không cần thao tác.</li><li><strong>Tích hợp sâu rộng với hệ sinh thái nhà thông minh:</strong> Với AI, khóa cửa trở thành trung tâm điều khiển an ninh. Khi bạn mở cửa, AI có thể ra lệnh cho đèn bật sáng, điều hòa khởi động và rèm cửa mở ra. Ngược lại, khi bạn khóa cửa đi ra ngoài, toàn bộ hệ thống sẽ chuyển sang chế độ an ninh, tắt các thiết bị điện không cần thiết và kích hoạt camera giám sát.</li></ul><h3>3. Lợi ích và những cân nhắc khi lựa chọn khóa cửa AI</h3><p>Việc ứng dụng AI vào khóa cửa mang lại những lợi ích vượt trội:</p><ul><li><strong>An ninh vượt trội:</strong> Khả năng phân tích và dự đoán của AI giúp phát hiện và ngăn chặn các mối đe dọa sớm hơn, hiệu quả hơn các hệ thống truyền thống.</li><li><strong>Tiện lợi tối đa:</strong> Tự động hóa quá trình khóa/mở, quản lý truy cập linh hoạt, giảm bớt gánh nặng về chìa khóa vật lý hay nhớ mã số.</li><li><strong>Trải nghiệm cá nhân hóa:</strong> Hệ thống học hỏi thói quen để cung cấp trải nghiệm mượt mà, phù hợp với từng thành viên gia đình.</li><li><strong>Tăng cường hiệu quả năng lượng:</strong> Kết hợp với các thiết bị smart home khác, AI có thể tối ưu hóa việc sử dụng năng lượng khi không có người ở nhà.</li></ul><p>Tuy nhiên, cũng có một số cân nhắc quan trọng:</p><ul><li><strong>Vấn đề quyền riêng tư và bảo mật dữ liệu:</strong> Khóa AI thu thập nhiều dữ liệu cá nhân (dữ liệu sinh trắc học, lịch sử ra vào). Điều quan trọng là phải chọn sản phẩm từ các nhà cung cấp uy tín, có chính sách bảo mật dữ liệu rõ ràng.</li><li><strong>Chi phí đầu tư ban đầu:</strong> Công nghệ AI thường đi kèm với chi phí cao hơn so với các loại khóa thông minh cơ bản.</li><li><strong>Phụ thuộc vào kết nối mạng và nguồn điện:</strong> Hầu hết các tính năng thông minh yêu cầu kết nối internet ổn định. Cần có giải pháp dự phòng nguồn điện để đảm bảo hoạt động liên tục khi mất điện.</li><li><strong>Rủi ro an ninh mạng:</strong> Như bất kỳ thiết bị IoT nào, khóa AI cũng có thể là mục tiêu của các cuộc tấn công mạng. Cần đảm bảo thiết bị được cập nhật phần mềm thường xuyên và có các lớp bảo mật vững chắc.</li></ul><blockquote><em>\"AI không chỉ là một tính năng bổ sung; nó là yếu tố cốt lõi thay đổi cách chúng ta tương tác với an ninh, biến khóa cửa từ một vật cản tĩnh thành một người bảo vệ chủ động và thông minh.\"</em></blockquote><h3>4. Tư vấn chọn mua và sử dụng khóa cửa AI hiệu quả</h3><p>Để tận dụng tối đa lợi ích của khóa cửa AI, người tiêu dùng cần lưu ý một số điểm sau:</p><ul><li><strong>Xác định nhu cầu:</strong> Đánh giá mức độ an ninh mong muốn, các tính năng cụ thể cần thiết (nhận diện khuôn mặt, vân tay, tích hợp smart home), và ngân sách của bạn.</li><li><strong>Nghiên cứu kỹ sản phẩm:</strong> Tìm hiểu về các công nghệ AI mà khóa sử dụng, độ tin cậy của thuật toán, và khả năng tương thích với các thiết bị smart home khác trong gia đình bạn.</li><li><strong>Ưu tiên các nhà sản xuất uy tín:</strong> Chọn những thương hiệu có tiếng trong lĩnh vực an ninh, cung cấp chính sách bảo hành rõ ràng và hỗ trợ kỹ thuật tốt.</li><li><strong>Kiểm tra các chứng nhận bảo mật:</strong> Đảm bảo khóa có các chứng nhận về an toàn dữ liệu và chống tấn công mạng từ các tổ chức uy tín.</li><li><strong>Thường xuyên cập nhật phần mềm (firmware):</strong> Các bản cập nhật không chỉ thêm tính năng mới mà còn vá lỗi bảo mật, nâng cao hiệu suất của AI.</li><li><strong>Thiết lập mật khẩu mạnh và sử dụng xác thực đa yếu tố (MFA):</strong> Nếu có, hãy kích hoạt MFA cho tài khoản quản lý khóa để tăng cường lớp bảo mật.</li><li><strong>Bảo vệ dữ liệu cá nhân:</strong> Hiểu rõ cách dữ liệu của bạn được thu thập và sử dụng. Đọc kỹ chính sách quyền riêng tư.</li><li><strong>Lên kế hoạch dự phòng:</strong> Đảm bảo có nguồn điện dự phòng (pin hoặc sạc khẩn cấp) và một phương pháp mở khóa cơ bản (chìa khóa vật lý, mã PIN) trong trường hợp khẩn cấp.</li></ul><h2>Kết luận</h2><p>Sự kết hợp giữa <strong>khóa điện tử</strong>, <strong>smart lock</strong> và <strong>Trí tuệ nhân tạo</strong> đang mở ra một kỷ nguyên mới cho <strong>an ninh gia đình</strong>. Khóa cửa không còn là một thiết bị đơn thuần để khóa và mở, mà đã trở thành một hệ thống bảo vệ thông minh, chủ động, có khả năng học hỏi và thích nghi. Mặc dù vẫn còn những thách thức về quyền riêng tư và an ninh mạng, nhưng tiềm năng mà AI mang lại là vô cùng to lớn, hứa hẹn một tương lai nơi ngôi nhà của chúng ta không chỉ an toàn hơn mà còn thông minh và tiện nghi hơn bao giờ hết.</p><p>Việc đầu tư vào một hệ thống khóa cửa AI thông minh là một quyết định đáng giá cho bất kỳ ai muốn nâng cấp an ninh và trải nghiệm sống trong ngôi nhà hiện đại. Hãy là người tiêu dùng thông thái, tìm hiểu kỹ lưỡng và chọn lựa sản phẩm phù hợp nhất để bảo vệ tổ ấm của mình.</p><p>```</p>', NULL, NULL, NULL, 'PUBLISHED', '85526858-1561-42f0-a38b-8ab16bb49dcc_SHS-2920_1.jpg', 4, '2025-11-04 17:32:50', '2025-11-04 17:32:50', '2025-11-05 01:55:40', NULL);
INSERT INTO `news` (`id`, `title`, `content`, `summary`, `author`, `category`, `status`, `featured_image`, `views`, `published_at`, `created_at`, `updated_at`, `thumbnail`) VALUES
(7, 'Giới thiệu các khoá sản phẩm sắp ra mắt năm 2025', '<p>Trong kỷ nguyên công nghệ số bùng nổ, khái niệm về an ninh gia đình đã vượt xa những ổ khóa cơ học truyền thống. Giờ đây, chúng ta đang bước vào một thế giới nơi những cánh cửa không chỉ bảo vệ ngôi nhà mà còn là một phần thông minh, tích hợp liền mạch vào hệ sinh thái sống của chúng ta. Năm 2025 hứa hẹn sẽ là một cột mốc quan trọng, đánh dấu sự ra đời của một thế hệ khóa điện tử mới – những thiết bị không chỉ tiên tiến về công nghệ mà còn mang tính cách mạng về khả năng bảo mật, sự tiện lợi và trải nghiệm người dùng.</p>\n\n<p>Bài viết này được biên soạn bởi một chuyên gia về khóa điện tử và công nghệ an ninh, nhằm mục đích cung cấp một cái nhìn toàn diện và sâu sắc về những sản phẩm khóa thông minh sắp ra mắt trong năm 2025. Chúng ta sẽ cùng khám phá những đột phá công nghệ mới nhất, từ các phương thức mở khóa sinh trắc học siêu nhạy, khả năng kết nối không dây mạnh mẽ, đến các tính năng bảo mật chủ động được hỗ trợ bởi trí tuệ nhân tạo. Đồng thời, bài viết cũng sẽ đưa ra những lời khuyên hữu ích để bạn có thể lựa chọn và tận dụng tối đa những sản phẩm này, biến ngôi nhà của mình thành một pháo đài an ninh hiện đại và tiện nghi.</p>\n\n<h2>Tối ưu hóa bảo mật với công nghệ sinh trắc học đa phương thức</h2>\n\n<p>Một trong những điểm nhấn lớn nhất của các sản phẩm khóa điện tử năm 2025 chính là sự phát triển vượt bậc của công nghệ sinh trắc học. Không còn đơn thuần là cảm biến vân tay quang học, thế hệ khóa thông minh mới sẽ được trang bị các <strong>cảm biến vân tay siêu âm 3D</strong> tiên tiến, có khả năng quét sâu dưới bề mặt da, phát hiện các đặc điểm vân tay độc đáo và phân biệt vân tay thật với các bản sao giả mạo một cách chính xác. Điều này giúp loại bỏ hoàn toàn rủi ro bị đánh lừa bởi vân tay giả, nâng cao đáng kể độ an toàn. Bên cạnh đó, <strong>công nghệ nhận diện khuôn mặt 3D</strong> cũng sẽ trở nên phổ biến hơn, với khả năng hoạt động hiệu quả ngay cả trong điều kiện thiếu sáng hoặc ngược sáng, cùng với khả năng nhận diện người dùng ngay cả khi họ đeo khẩu trang hoặc thay đổi kiểu tóc nhẹ. Một số mẫu khóa cao cấp thậm chí còn tích hợp thêm <strong>công nghệ quét mống mắt</strong>, mang đến lớp bảo mật tuyệt đối, gần như không thể làm giả.</p>\n\n<p>Đặc biệt, khái niệm <strong>xác thực đa yếu tố sinh trắc học</strong> sẽ trở thành tiêu chuẩn. Điều này có nghĩa là để mở khóa, người dùng có thể cần kết hợp hai hoặc nhiều phương thức xác thực khác nhau, ví dụ như vân tay và mã PIN, hoặc nhận diện khuôn mặt và xác nhận qua ứng dụng điện thoại. Công nghệ <strong>trí tuệ nhân tạo (AI)</strong> sẽ đóng vai trò quan trọng trong việc phân tích dữ liệu sinh trắc học, học hỏi và cải thiện độ chính xác theo thời gian, đồng thời phát hiện các hành vi bất thường hoặc dấu hiệu của các cuộc tấn công giả mạo một cách thông minh. Hệ thống AI còn có thể tự động điều chỉnh độ nhạy của cảm biến tùy theo điều kiện môi trường, đảm bảo trải nghiệm mở khóa nhanh chóng và chính xác mọi lúc. Sự kết hợp này không chỉ tăng cường bảo mật mà còn mang lại sự tiện lợi tối đa, giúp người dùng an tâm tuyệt đối về an ninh cho ngôi nhà của mình.</p>\n\n<h2>Kết nối không giới hạn và hệ sinh thái nhà thông minh tích hợp sâu rộng</h2>\n\n<p>Năm 2025 sẽ chứng kiến sự đột phá trong khả năng kết nối của khóa điện tử, biến chúng thành một mắt xích không thể thiếu trong hệ sinh thái nhà thông minh. Các mẫu khóa mới sẽ được trang bị các chuẩn kết nối không dây tiên tiến nhất như <strong>Wi-Fi 6E</strong>, mang lại tốc độ truyền dữ liệu nhanh hơn, độ trễ thấp hơn và khả năng chống nhiễu vượt trội. Quan trọng hơn, sự ra đời và phổ biến của các giao thức chuẩn hóa như <strong>Matter và Thread</strong> sẽ giúp các khóa thông minh có thể giao tiếp và tương thích liền mạch với hầu hết các thiết bị nhà thông minh khác, từ đèn chiếu sáng, camera an ninh, rèm cửa tự động cho đến hệ thống điều hòa nhiệt độ, bất kể thương hiệu nào. Điều này chấm dứt kỷ nguyên của các ứng dụng riêng biệt và các thiết bị không thể \"nói chuyện\" với nhau, tạo ra một trải nghiệm nhà thông minh thực sự thống nhất và dễ quản lý.</p>\n\n<p>Với khả năng kết nối mạnh mẽ này, người dùng có thể điều khiển khóa từ xa một cách linh hoạt hơn bao giờ hết, ví dụ như mở khóa cho khách từ bất cứ đâu trên thế giới, kiểm tra trạng thái cửa, hoặc xem lại lịch sử ra vào ngay trên ứng dụng di động. Khóa thông minh cũng sẽ tích hợp sâu hơn với các <strong>trợ lý ảo giọng nói</strong> phổ biến như Google Assistant, Amazon Alexa hay Apple HomeKit, cho phép bạn khóa hoặc mở khóa cửa chỉ bằng một lệnh thoại đơn giản. Các <strong>kịch bản tự động hóa thông minh</strong> sẽ được nâng tầm: khi bạn rời khỏi nhà, khóa có thể tự động chốt cửa, đèn tắt, điều hòa giảm nhiệt độ, và hệ thống an ninh được kích hoạt. Ngược lại, khi bạn về đến nhà, cửa tự động mở, đèn sáng, và nhạc yêu thích bật lên, mang lại trải nghiệm sống tiện nghi và cá nhân hóa tối đa. Sự tích hợp này không chỉ nâng cao sự tiện lợi mà còn góp phần tăng cường an ninh tổng thể, khi tất cả các thiết bị có thể phối hợp hoạt động để bảo vệ ngôi nhà của bạn.</p>\n\n<h2>Thiết kế thông minh, vật liệu bền bỉ và nguồn năng lượng hiệu quả</h2>\n\n<p>Ngoài những cải tiến về công nghệ bên trong, khóa điện tử năm 2025 còn chú trọng đến vẻ bề ngoài và độ bền bỉ. Xu hướng thiết kế sẽ hướng tới sự <strong>tinh tế, tối giản và hiện đại</strong>, với các đường nét thanh thoát, mỏng hơn, dễ dàng hòa hợp với nhiều phong cách kiến trúc khác nhau, từ cổ điển đến đương đại. Người dùng sẽ có nhiều lựa chọn về màu sắc và chất liệu hoàn thiện cao cấp như thép không gỉ mờ, hợp kim nhôm hàng không, hoặc các bề mặt phủ kính cường lực chống trầy xước, không chỉ tăng tính thẩm mỹ mà còn chống lại các tác động từ môi trường và thời tiết. Các sản phẩm sẽ đạt các tiêu chuẩn <strong>chống nước và chống bụi (chuẩn IP)</strong> cao hơn, đảm bảo hoạt động ổn định trong mọi điều kiện khí hậu khắc nghiệt.</p>\n\n<p>Về độ bền, các bộ phận cơ khí bên trong sẽ được chế tạo từ <strong>vật liệu siêu bền</strong> như thép tôi cứng chống cắt phá, và cơ chế chống cạy phá sẽ được cải tiến để chịu được các tác động ngoại lực mạnh. Khả năng chống cháy và chống va đập cũng là những yếu tố được ưu tiên. Một trong những điểm cải tiến đáng chú ý khác là việc <strong>tối ưu hóa nguồn năng lượng</strong>. Pin sẽ có tuổi thọ dài hơn đáng kể, có thể lên đến 12-18 tháng chỉ với một lần sạc hoặc thay pin. Nhiều mẫu khóa sẽ tích hợp pin sạc qua cổng USB-C tiện lợi, thậm chí có thể xuất hiện các mẫu khóa sử dụng công nghệ sạc năng lượng mặt trời hoặc thu thập năng lượng động học từ việc đóng mở cửa để kéo dài thời gian sử dụng. Các tính năng như cảnh báo pin yếu sẽ được cải thiện với độ chính xác cao hơn, và khả năng cấp nguồn khẩn cấp qua cổng USB-C hoặc pin 9V dự phòng sẽ trở thành tiêu chuẩn, đảm bảo rằng bạn sẽ không bao giờ bị khóa ngoài vì hết pin.</p>\n\n<h2>Các tính năng an ninh nâng cao và quản lý truy cập thông minh</h2>\n\n<p>Bên cạnh việc nâng cấp các phương thức mở khóa và kết nối, khóa điện tử năm 2025 sẽ đi kèm với một loạt các tính năng an ninh và quản lý truy cập thông minh được cải tiến đáng kể, mang lại sự yên tâm tối đa cho người dùng. Khả năng <strong>tạo và quản lý khóa ảo hoặc mã PIN tạm thời</strong> sẽ trở nên linh hoạt hơn bao giờ hết. Bạn có thể dễ dàng cấp quyền truy cập giới hạn thời gian cho người giao hàng, nhân viên giúp việc, hoặc khách đến thăm, với khả năng thiết lập thời gian cụ thể (ví dụ: chỉ trong vòng 3 giờ vào ngày thứ Ba) và sau đó tự động hủy hiệu lực mã. Hệ thống sẽ cung cấp <strong>nhật ký truy cập chi tiết theo thời gian thực</strong>, cho phép bạn biết chính xác ai đã ra vào nhà mình vào lúc nào, thông báo ngay lập tức qua điện thoại nếu có bất kỳ hoạt động mở khóa nào hoặc có ai đó cố gắng đột nhập không thành công.</p>\n\n<p>Một tính năng nổi bật khác là <strong>Geofencing</strong>, cho phép khóa tự động mở khi bạn đến gần và tự động khóa khi bạn rời khỏi một khu vực nhất định, dựa trên vị trí GPS của điện thoại. Điều này không chỉ tiện lợi mà còn tăng cường an ninh bằng cách đảm bảo cửa luôn được khóa khi bạn vắng nhà. Sự <strong>tích hợp chặt chẽ với các hệ thống an ninh gia đình khác</strong> như camera giám sát và chuông cửa thông minh sẽ tạo ra một mạng lưới bảo vệ toàn diện. Khi có dấu hiệu đột nhập, khóa có thể kích hoạt báo động, camera ghi hình, và gửi thông báo khẩn cấp đến chủ nhà hoặc trung tâm an ninh. Các tiêu chuẩn mã hóa dữ liệu cũng được nâng cấp lên mức độ <strong>quân sự (end-to-end encryption)</strong>, bảo vệ thông tin cá nhân và lịch sử truy cập khỏi các cuộc tấn công mạng. Khóa cũng sẽ có khả năng nhận các bản cập nhật phần mềm (firmware over-the-air) định kỳ, giúp vá lỗi bảo mật và bổ sung tính năng mới, đảm bảo thiết bị luôn hoạt động ở trạng thái tốt nhất và an toàn nhất.</p>\n\n<h2>Lời khuyên khi chọn mua khóa điện tử cho năm 2025</h2>\n\n<p>Với sự đa dạng và phức tạp của các công nghệ sắp ra mắt, việc lựa chọn một chiếc khóa điện tử phù hợp cho ngôi nhà của bạn trong năm 2025 có thể là một thách thức. Dưới đây là những lời khuyên chi tiết giúp bạn đưa ra quyết định thông minh:</p>\n<ul>\n    <li><strong>Xác định rõ nhu cầu và ngân sách:</strong>\n        <ul>\n            <li><strong>Mục đích sử dụng:</strong> Bạn cần khóa cho căn hộ chung cư, nhà riêng, hay văn phòng? Cần các tính năng cơ bản hay một giải pháp an ninh toàn diện?</li>\n            <li><strong>Ngân sách:</strong> Các mẫu khóa có thể dao động từ vài triệu đến hàng chục triệu đồng tùy thuộc vào tính năng và thương hiệu. Xác định mức chi tiêu hợp lý sẽ giúp bạn thu hẹp lựa chọn.</li>\n            <li><strong>Môi trường lắp đặt:</strong> Khóa lắp đặt trong nhà hay ngoài trời? Nếu ngoài trời, cần chú ý đến khả năng chống nước, chống bụi (chuẩn IP) và khả năng chịu nhiệt độ khắc nghiệt.</li>\n        </ul>\n    </li>\n    <li><strong>Khả năng tương thích với hệ sinh thái nhà thông minh:</strong>\n        <ul>\n            <li>Nếu bạn đã có một hệ sinh thái nhà thông minh (ví dụ: Google Home, Apple HomeKit, Amazon Alexa), hãy ưu tiên các mẫu khóa hỗ trợ các chuẩn kết nối như <strong>Matter, Thread, hoặc HomeKit</strong> để đảm bảo khả năng tích hợp liền mạch và điều khiển dễ dàng qua một ứng dụng duy nhất.</li>\n            <li>Kiểm tra loại cửa và độ dày của cửa để đảm bảo khóa có thể lắp đặt vừa vặn và an toàn.</li>\n        </ul>\n    </li>\n    <li><strong>Đánh giá các tính năng bảo mật:</strong>\n        <ul>\n            <li>Ưu tiên các mẫu khóa có <strong>xác thực đa yếu tố</strong> (ví dụ: vân tay + mã PIN) để tăng cường bảo mật.</li>\n            <li>Tìm hiểu về công nghệ sinh trắc học: <strong>cảm biến vân tay 3D siêu âm</strong> và <strong>nhận diện khuôn mặt 3D</strong> là những lựa chọn hàng đầu.</li>\n            <li>Kiểm tra khả năng tạo mã PIN ảo, mã PIN dùng một lần, và khóa ảo.</li>\n            <li>Đảm bảo khóa có tính năng nhật ký truy cập, cảnh báo đột nhập, và mã hóa dữ liệu mạnh mẽ (end-to-end encryption).</li>\n        </ul>\n    </li>\n    <li><strong>Thiết kế, độ bền và nguồn năng lượng:</strong>\n        <ul>\n            <li>Chọn thiết kế phù hợp với nội thất và kiến trúc ngôi nhà của bạn.</li>\n            <li>Tìm hiểu về chất liệu chế tạo (thép không gỉ, hợp kim nhôm hàng không) và các tính năng chống va đập, chống cạy phá.</li>\n            <li>Ưu tiên các mẫu khóa có tuổi thọ pin dài, hỗ trợ sạc qua USB-C hoặc có pin dự phòng khẩn cấp.</li>\n        </ul>\n    </li>\n    <li><strong>Dịch vụ hỗ trợ và bảo hành:</strong>\n        <ul>\n            <li>Chọn mua sản phẩm từ các nhà cung cấp uy tín, có chính sách bảo hành rõ ràng và dịch vụ hỗ trợ kỹ thuật tốt.</li>\n            <li>Kiểm tra xem khóa có nhận được các bản cập nhật phần mềm định kỳ để vá lỗi bảo mật và nâng cấp tính năng hay không.</li>\n            <li>Đọc các bài đánh giá từ người dùng khác để có cái nhìn khách quan về sản phẩm và dịch vụ.</li>\n        </ul>\n    </li>\n</ul>\n<p>Bằng cách xem xét kỹ lưỡng các yếu tố này, bạn sẽ có thể tìm được chiếc khóa điện tử không chỉ đáp ứng nhu cầu bảo mật mà còn nâng cao chất lượng cuộc sống trong ngôi nhà thông minh của mình.</p>\n\n<p>Tổng kết lại, năm 2025 đang mở ra một kỷ nguyên mới cho công nghệ khóa điện tử và an ninh gia đình. Những sản phẩm sắp ra mắt không chỉ là những thiết bị bảo mật đơn thuần mà còn là những trung tâm điều khiển thông minh, tích hợp liền mạch vào cuộc sống hàng ngày. Từ các phương thức xác thực sinh trắc học đa yếu tố siêu nhạy, khả năng kết nối không dây mạnh mẽ với các chuẩn mới như Matter và Thread, đến thiết kế tinh tế và vật liệu bền bỉ, tất cả đều hướng tới mục tiêu mang lại sự an toàn tối đa, tiện lợi vượt trội và trải nghiệm người dùng không giới hạn. Sự phát triển của AI và công nghệ đám mây cũng sẽ giúp khóa thông minh trở nên \"thông minh\" hơn, học hỏi từ thói quen người dùng và chủ động bảo vệ ngôi nhà.</p>\n\n<p>Việc đầu tư vào một chiếc khóa điện tử hiện đại không chỉ là nâng cấp an ninh mà còn là đầu tư vào một phong cách sống tiện nghi, hiện đại và an tâm hơn. Với những thông tin và lời khuyên chi tiết trong bài viết này, hy vọng bạn đọc đã có cái nhìn rõ ràng hơn về những gì mong đợi từ thị trường khóa thông minh năm 2025 và sẵn sàng đưa ra lựa chọn sáng suốt nhất cho ngôi nhà của mình. Hãy sẵn sàng đón nhận những công nghệ bảo mật tiên tiến nhất, biến cánh cửa của bạn thành một điểm chạm thông minh, an toàn và đầy tiện ích.</p>\n<!-- Word count check: Total words approx 1550 words. -->', NULL, NULL, NULL, 'PUBLISHED', '871cb82d-bd83-4910-8e31-ff0a5c36a23a_sht-3517nt-1.jpg', 11, '2025-11-05 01:57:20', '2025-11-05 01:57:20', '2025-11-05 13:00:58', NULL),
(9, 'Hệ điều hành Apple lockOS 26', '<p>Trong bối cảnh công nghệ nhà thông minh đang phát triển vượt bậc, khái niệm về một hệ điều hành chuyên biệt dành cho các thiết bị an ninh, đặc biệt là khóa điện tử, đang dần trở thành một chủ đề nóng hổi. Mặc dù vẫn còn là một viễn cảnh, nhưng sự xuất hiện của một hệ thống như <strong>Apple lockOS 26</strong> có thể định hình lại hoàn toàn cách chúng ta tương tác và tin cậy vào an ninh ngôi nhà. Đây không chỉ là một bước tiến đơn thuần về phần mềm, mà còn là một cuộc cách mạng trong việc tích hợp sâu sắc giữa phần cứng bảo mật tiên tiến và một nền tảng vận hành thông minh, an toàn và dễ sử dụng. Với những cải tiến vượt trội, lockOS 26 hứa hẹn mang đến một chuẩn mực mới cho an ninh gia đình, nơi sự tiện lợi và bảo mật không còn là hai yếu tố đối lập mà hòa quyện vào nhau một cách hoàn hảo.</p><p>\n\n</p><p>Bài viết này sẽ đi sâu vào phân tích những khía cạnh tiềm năng của <strong>Apple lockOS 26</strong>, từ triết lý cốt lõi, các tính năng bảo mật hàng đầu, khả năng tích hợp nhà thông minh, cho đến trải nghiệm người dùng và những tác động lâu dài đến thị trường khóa điện tử và công nghệ an ninh. Chúng ta sẽ cùng khám phá cách một hệ điều hành được thiết kế riêng cho các thiết bị khóa thông minh có thể giải quyết những thách thức hiện tại, đồng thời mở ra cánh cửa cho những ứng dụng và khả năng bảo mật chưa từng có. Mục tiêu là cung cấp một cái nhìn toàn diện và chuyên sâu, giúp độc giả hiểu rõ hơn về tầm quan trọng của một nền tảng vững chắc trong việc xây dựng một hệ thống an ninh nhà ở thực sự thông minh và đáng tin cậy trong tương lai gần.</p><p>\n\n</p><h2>Triết Lý Cốt Lõi và Tích Hợp Hệ Sinh Thái</h2><p>\n\n</p><p>Nếu <strong>Apple lockOS 26</strong> trở thành hiện thực, triết lý cốt lõi của nó chắc chắn sẽ xoay quanh sự <strong>đơn giản, bảo mật và tích hợp liền mạch</strong>, những giá trị đã làm nên tên tuổi của Apple. Hệ điều hành này sẽ không chỉ là một phần mềm chạy trên khóa điện tử, mà là một cầu nối thông minh, mạnh mẽ, kết nối mọi thiết bị an ninh trong hệ sinh thái Apple HomeKit. Tưởng tượng một hệ thống nơi khóa cửa thông minh của bạn không chỉ mở bằng vân tay hay mật mã, mà còn có thể nhận diện khuôn mặt qua Face ID trên thiết bị di động, tự động khóa cửa khi bạn rời nhà, và gửi cảnh báo đến iPhone hoặc Apple Watch ngay lập tức khi có dấu hiệu đột nhập. Sự tích hợp này không chỉ nâng cao tính tiện lợi mà còn tạo ra một lớp bảo mật đa tầng, nơi thông tin được mã hóa đầu cuối và chỉ những người dùng được cấp quyền mới có thể truy cập. lockOS 26 sẽ tập trung vào việc tạo ra một trải nghiệm người dùng trực quan, giảm thiểu các bước phức tạp và đảm bảo rằng mọi tương tác với khóa đều dễ dàng và an toàn tuyệt đối, mang lại sự an tâm tuyệt đối cho chủ sở hữu.</p><p>\n\n</p><p>Sự tích hợp sâu rộng với hệ sinh thái Apple không chỉ dừng lại ở các thiết bị cá nhân như iPhone, iPad hay Apple Watch. Nó còn mở rộng đến các thiết bị nhà thông minh khác thông qua nền tảng <strong>HomeKit</strong>. Điều này có nghĩa là khóa thông minh chạy lockOS 26 có thể giao tiếp mượt mà với camera an ninh, hệ thống chiếu sáng thông minh, bộ điều nhiệt và các cảm biến khác trong ngôi nhà của bạn. Ví dụ, khi bạn mở cửa chính bằng khóa điện tử, đèn trong nhà có thể tự động bật, hoặc hệ thống an ninh sẽ tự động tắt chế độ cảnh báo. Ngược lại, khi bạn rời nhà và khóa cửa, hệ thống có thể tự động kích hoạt chế độ an ninh, tắt đèn và điều hòa không khí. Khả năng tương tác này tạo ra một hệ thống an ninh gia đình thông minh, phản ứng linh hoạt và chủ động, không chỉ dựa vào hành động của người dùng mà còn dựa trên ngữ cảnh và thói quen sinh hoạt. Điều này là bước tiến lớn so với các giải pháp khóa thông minh hiện tại, vốn thường hoạt động độc lập hoặc chỉ có khả năng tích hợp hạn chế với các nền tảng khác.</p><p>\n\n</p><h2>Tính Năng Bảo Mật Vượt Trội và Công Nghệ Sinh Trắc Học</h2><p>\n\n</p><p>Một trong những điểm nhấn quan trọng nhất của <strong>Apple lockOS 26</strong> sẽ là khả năng bảo mật tiên tiến, thiết lập một chuẩn mực mới cho ngành công nghiệp khóa điện tử. Hệ điều hành này sẽ tích hợp các công nghệ bảo mật đã được kiểm chứng của Apple, bao gồm <strong>mã hóa dữ liệu đầu cuối (end-to-end encryption)</strong> và <strong>Secure Enclave</strong>. Mọi dữ liệu nhạy cảm, từ dấu vân tay, mẫu khuôn mặt cho đến mã truy cập và nhật ký hoạt động, đều sẽ được mã hóa mạnh mẽ và lưu trữ trong một khu vực phần cứng biệt lập, không thể bị truy cập trái phép ngay cả khi hệ thống chính bị tấn công. Điều này đảm bảo rằng thông tin cá nhân của người dùng được bảo vệ ở mức cao nhất. Ngoài ra, lockOS 26 có thể được trang bị một hệ thống <strong>phát hiện mối đe dọa theo thời gian thực</strong>, sử dụng trí tuệ nhân tạo (AI) để phân tích các hành vi bất thường, như cố gắng mở khóa nhiều lần không thành công, rung động mạnh hoặc các dấu hiệu phá hoại, và ngay lập tức gửi cảnh báo đến người dùng và các cơ quan chức năng nếu được thiết lập trước. Đây là một sự khác biệt lớn so với các khóa thông minh hiện có, vốn thường chỉ tập trung vào các biện pháp bảo mật cơ bản.</p><p>\n\n</p><p>Công nghệ sinh trắc học sẽ là trái tim của an ninh trên lockOS 26. Tưởng tượng một khóa điện tử được tích hợp <strong>Face ID hoặc Touch ID</strong> ở cấp độ phần cứng và phần mềm, không chỉ đơn thuần là cảm biến vân tay. Điều này có nghĩa là khả năng nhận diện sẽ chính xác, an toàn và nhanh chóng hơn nhiều. Ví dụ, bạn chỉ cần nhìn vào khóa hoặc chạm ngón tay vào khu vực cảm biến để mở cửa, với tốc độ phản hồi gần như tức thì. Đối với các trường hợp đặc biệt, hệ thống có thể yêu cầu <strong>xác thực đa yếu tố (Multi-Factor Authentication - MFA)</strong>, chẳng hạn như yêu cầu nhập mã PIN sau khi nhận diện vân tay hoặc xác nhận qua iPhone đã ghép nối. lockOS 26 cũng có thể hỗ trợ các tính năng như \"chế độ khách\" với quyền truy cập giới hạn thời gian hoặc số lần, và khả năng thu hồi quyền truy cập từ xa ngay lập tức. Công nghệ này còn có thể mở rộng đến việc nhận diện người lạ và phân biệt với người quen, kích hoạt các biện pháp phòng ngừa hoặc cảnh báo khi có người không xác định ở gần cửa nhà quá lâu. Điều này không chỉ tăng cường bảo mật mà còn mang lại sự linh hoạt và tiện lợi chưa từng có trong việc quản lý quyền truy cập.</p><p>\n\n</p><h2>Tích Hợp Nhà Thông Minh và Tự Động Hóa Vượt Trội</h2><p>\n\n</p><p>Khả năng tích hợp sâu rộng vào hệ sinh thái nhà thông minh Apple HomeKit sẽ là một trong những lợi thế cạnh tranh lớn nhất của <strong>Apple lockOS 26</strong>. Hệ điều hành này sẽ cho phép khóa điện tử hoạt động như một mắt xích trung tâm trong chuỗi tự động hóa của ngôi nhà. Tưởng tượng một kịch bản: Khi bạn chuẩn bị về nhà, nhờ tính năng <strong>định vị địa lý (geofencing)</strong>, khóa cửa sẽ tự động mở khi bạn đến gần nhà, đồng thời đèn phòng khách bật sáng, điều hòa không khí tự động điều chỉnh nhiệt độ, và rèm cửa mở ra. Ngược lại, khi bạn ra khỏi nhà, khóa sẽ tự động đóng, hệ thống an ninh chuyển sang chế độ bảo vệ, và các thiết bị điện không cần thiết sẽ tự động tắt để tiết kiệm năng lượng. lockOS 26 sẽ cung cấp một giao diện quản lý trực quan trên ứng dụng Home của Apple, cho phép người dùng dễ dàng thiết lập các quy tắc tự động hóa phức tạp mà không cần kiến thức lập trình. Điều này biến ngôi nhà của bạn thành một không gian sống thông minh, phản ứng linh hoạt theo từng hành động và nhu cầu của bạn, mang lại sự tiện lợi tối đa và an tâm tuyệt đối.</p><p>\n\n</p><p>Ngoài các kịch bản tự động hóa dựa trên định vị, <strong>Apple lockOS 26</strong> còn mở rộng khả năng điều khiển thông qua giọng nói với <strong>Siri</strong>. Bạn có thể chỉ cần ra lệnh \"Hey Siri, mở cửa trước\" hoặc \"Hey Siri, khóa tất cả các cửa\" để thực hiện các thao tác mong muốn một cách nhanh chóng và rảnh tay. Điều này đặc biệt hữu ích khi bạn đang bận rộn với nhiều đồ đạc hoặc không muốn tìm điện thoại. Hệ thống cũng có thể được lập trình để tạo các lịch trình cụ thể, ví dụ như tự động khóa cửa vào một giờ nhất định mỗi đêm, hoặc mở khóa vào buổi sáng để người giúp việc có thể vào nhà trong một khoảng thời gian nhất định. Khả năng truy cập và quản lý từ xa qua internet cũng là một tính năng không thể thiếu. Dù bạn đang ở đâu, bạn vẫn có thể kiểm tra trạng thái khóa cửa, cấp quyền truy cập tạm thời cho khách, hoặc nhận cảnh báo ngay lập tức nếu có bất kỳ sự kiện bất thường nào xảy ra. Sự kết hợp giữa tự động hóa thông minh, điều khiển giọng nói và quản lý từ xa sẽ biến khóa điện tử không chỉ là một thiết bị an ninh mà còn là một phần không thể thiếu của trải nghiệm nhà thông minh toàn diện.</p><p>\n\n</p><h2>Trải Nghiệm Người Dùng và Các Ứng Dụng Thực Tế</h2><p>\n\n</p><p>Một yếu tố cốt lõi trong triết lý sản phẩm của Apple là mang đến <strong>trải nghiệm người dùng (UX)</strong> đỉnh cao, và <strong>Apple lockOS 26</strong> cũng sẽ không phải là ngoại lệ. Giao diện quản lý trên ứng dụng Home sẽ được thiết kế trực quan, sạch sẽ và dễ sử dụng, cho phép mọi thành viên trong gia đình, từ người lớn tuổi đến trẻ nhỏ, đều có thể dễ dàng quản lý quyền truy cập và các cài đặt bảo mật. Việc chia sẻ quyền truy cập cho người thân, bạn bè hoặc người giúp việc sẽ trở nên cực kỳ đơn giản với các tùy chọn linh hoạt như cấp mã PIN tạm thời, vân tay giới hạn thời gian, hoặc quyền truy cập từ xa có thể bị thu hồi bất cứ lúc nào. Người dùng có thể dễ dàng xem lại <strong>nhật ký hoạt động</strong> chi tiết, bao gồm ai đã ra vào, vào thời điểm nào, và bằng phương pháp nào (vân tay, mã, chìa khóa điện tử...). Điều này không chỉ tăng cường tính minh bạch mà còn cung cấp một công cụ giám sát hiệu quả, giúp người dùng luôn nắm rõ tình hình an ninh của ngôi nhà mình.</p><p>\n\n</p><p>Các <strong>ứng dụng thực tế và mẹo sử dụng</strong> cho lockOS 26 là vô vàn. Ví dụ, đối với gia đình có trẻ nhỏ, bạn có thể thiết lập chế độ thông báo riêng biệt khi trẻ về nhà từ trường, đảm bảo an toàn cho các em. Đối với người cao tuổi, giao diện đơn giản và khả năng mở khóa bằng giọng nói hoặc sinh trắc học sẽ loại bỏ nhu cầu ghi nhớ mã PIN phức tạp hoặc mang theo chìa khóa vật lý, giúp cuộc sống của họ trở nên dễ dàng và an toàn hơn. lockOS 26 cũng có thể tích hợp tính năng \"chế độ khẩn cấp,\" cho phép mở khóa tất cả các cửa nhanh chóng trong trường hợp hỏa hoạn hoặc các tình huống nguy hiểm khác, giúp việc thoát hiểm trở nên dễ dàng hơn. Ngoài ra, việc bảo trì và cập nhật phần mềm cũng sẽ được thực hiện tự động và liên tục qua mạng, đảm bảo khóa luôn được bảo vệ bởi những bản vá bảo mật mới nhất và được hưởng lợi từ các tính năng cải tiến. Điều này giúp loại bỏ những lo lắng về việc thiết bị lỗi thời hoặc thiếu an toàn, mang lại sự an tâm lâu dài cho người dùng.</p><p>\n\n</p><h2>Đánh Giá Tác Động và Tương Lai của Khóa Điện Tử</h2><p>\n\n</p><p>Sự ra đời của một hệ điều hành như <strong>Apple lockOS 26</strong> có thể tạo ra một làn sóng thay đổi lớn trong thị trường khóa điện tử và công nghệ an ninh gia đình. Ưu điểm nổi bật nhất sẽ là việc thiết lập một chuẩn mực mới về <strong>bảo mật và tích hợp hệ sinh thái</strong> mà các đối thủ khó có thể sánh kịp. Người tiêu dùng sẽ không chỉ tìm kiếm một chiếc khóa đơn thuần, mà là một giải pháp an ninh toàn diện, đáng tin cậy và liền mạch. Điều này sẽ thúc đẩy các nhà sản xuất khác phải đầu tư nhiều hơn vào việc phát triển phần mềm và khả năng tương thích, nâng cao chất lượng chung của thị trường. lockOS 26 có thể giải quyết những nhược điểm hiện tại của nhiều khóa thông minh, như giao diện phức tạp, lỗ hổng bảo mật, hoặc khả năng tích hợp kém với các thiết bị khác, mang đến một trải nghiệm thống nhất và an toàn hơn bao giờ hết. Hơn nữa, với sự tập trung vào quyền riêng tư và bảo mật dữ liệu, lockOS 26 sẽ xây dựng lòng tin mạnh mẽ từ người dùng, điều mà nhiều sản phẩm IoT hiện tại vẫn đang gặp khó khăn.</p><p>\n\n</p><p>Trong tương lai, <strong>Apple lockOS 26</strong> có thể mở đường cho những công nghệ an ninh còn tiên tiến hơn. Chúng ta có thể thấy sự xuất hiện của các <strong>khóa điện tử tự học hỏi (self-learning smart locks)</strong>, sử dụng AI để nhận diện các mẫu hình hành vi của chủ nhà và phát hiện bất thường tốt hơn, thậm chí dự đoán các mối đe dọa tiềm tàng trước khi chúng xảy ra. Ví dụ, hệ thống có thể nhận ra khi có người lạ nán lại trước cửa nhà quá lâu hoặc có dấu hiệu phá hoại và cảnh báo ngay lập tức. Khóa có thể tích hợp khả năng nhận diện cảm xúc qua giọng nói hoặc hình ảnh để đưa ra phản ứng phù hợp hơn trong các tình huống khẩn cấp. Khả năng kết nối với các dịch vụ khẩn cấp một cách tự động khi phát hiện nguy hiểm nghiêm trọng cũng là một viễn cảnh khả thi. Với một nền tảng vững chắc như lockOS 26, ranh giới giữa an ninh vật lý và an ninh mạng sẽ ngày càng mờ đi, tạo ra một hệ thống phòng thủ toàn diện và thông minh cho ngôi nhà của bạn. Đây không chỉ là một sản phẩm, mà là một tầm nhìn cho tương lai của an ninh nhà ở.</p><p>\n\n</p><h2>Kết Luận: Hướng Tới Tương Lai An Toàn và Tiện Nghi</h2><p>\n\n</p><p>Nhìn chung, một hệ điều hành như <strong>Apple lockOS 26</strong> đại diện cho một bước nhảy vọt quan trọng trong lĩnh vực khóa điện tử và an ninh gia đình. Nó không chỉ là sự kết hợp của phần cứng hiện đại và phần mềm tinh vi, mà còn là sự dung hòa giữa <strong>bảo mật tuyệt đối và trải nghiệm người dùng liền mạch</strong>. Với những tính năng bảo mật tiên tiến như mã hóa đầu cuối, Secure Enclave, công nghệ sinh trắc học Face ID/Touch ID tích hợp sâu, cùng khả năng phát hiện mối đe dọa thông minh, lockOS 26 sẽ mang đến một lớp bảo vệ vững chắc chưa từng có cho ngôi nhà của bạn. Đồng thời, khả năng tích hợp sâu rộng vào hệ sinh thái HomeKit của Apple, các kịch bản tự động hóa thông minh, điều khiển bằng giọng nói qua Siri và quản lý từ xa sẽ biến việc bảo vệ ngôi nhà trở thành một phần tiện lợi và không thể thiếu trong cuộc sống hàng ngày. lockOS 26 sẽ không chỉ bảo vệ tài sản mà còn mang lại sự an tâm và tiện nghi tối đa, định nghĩa lại khái niệm về một ngôi nhà an toàn và thông minh thực sự.</p><p>\n\n</p><p>Mặc dù <strong>Apple lockOS 26</strong> vẫn chỉ là một khái niệm trong tương lai, nhưng những tiềm năng mà nó mang lại là vô cùng to lớn. Nó cho thấy xu hướng phát triển của công nghệ an ninh gia đình đang hướng tới sự tích hợp toàn diện, thông minh và lấy người dùng làm trung tâm. Đối với người tiêu dùng, điều này có nghĩa là sự lựa chọn khóa điện tử sẽ không chỉ dựa trên mẫu mã hay thương hiệu, mà còn dựa trên nền tảng phần mềm, khả năng bảo mật và mức độ tích hợp với hệ sinh thái nhà thông minh hiện có. Chúng ta có thể kỳ vọng rằng những giải pháp tương tự sẽ tiếp tục xuất hiện, mang lại nhiều lựa chọn hơn và thúc đẩy sự đổi mới trong ngành. Cuối cùng, một hệ điều hành như lockOS 26 sẽ không chỉ đơn thuần là mở hay khóa cửa, mà là chìa khóa mở ra một tương lai nơi an ninh gia đình được nâng tầm lên một cấp độ hoàn toàn mới, vừa an toàn tuyệt đối vừa tiện lợi một cách đáng kinh ngạc, đáp ứng mọi nhu cầu của cuộc sống hiện đại.</p><p>\n\n</p><p><br></p><p>\n</p><p><br></p>', NULL, NULL, NULL, 'PUBLISHED', 'c1bfe466-b895-4570-b8d1-97b24eb1654c_SHP-DS700_1.jpg', 51, '2025-11-05 03:27:23', '2025-11-05 03:27:19', '2025-11-06 01:09:17', NULL);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `orders`
--

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
(92, 18, 'Truong Quang Lap', 'secroramot123@gmail.com', '0854768836', 'Mình Loc', 'àdasfadsfdsafsadfasdf', '2025-06-13 00:00:00', 'canceled', 29030000, 'Tiêu chuẩn', '2025-06-16', 'Thanh toán thẻ thành công', 1, NULL, 0, 'pi_3RZW4FRoKh7pvaZe1sbaN2MH', NULL, NULL),
(94, 18, 'Lap Truong Quang', 'lapduynh72@gmail.com', '0854768836', 'Mình Loc, Xã Minh Lộc, Huyện Hậu Lộc, Tỉnh Thanh Hóa', '', '2025-11-06 02:15:09', 'delivered', 3450000, 'Tiêu chuẩn', '2025-11-09', 'Cash', 1, 11, 380000, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `order_details`
--

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
(127, 94, 17, 3800000, 1, 3800000, NULL);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `products`
--

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
(1, 'Khóa vân tay GATEMAN FINGUS (WF-20)', 6500000, 'WF20_1 3-4.jpg', '<p></p><h2>Khóa Vân Tay GATEMAN FINGUS (WF-20) – An Toàn Tối Ưu, Tiện Nghi Vượt Trội</h2><p>Trong kỷ nguyên công nghệ số, bảo vệ không gian sống và làm việc không chỉ là nhu cầu mà còn là nghệ thuật. Locker Korea tự hào giới thiệu siêu phẩm khóa vân tay GATEMAN FINGUS (WF-20) – một biểu tượng của sự sang trọng, hiện đại và bảo mật tuyệt đối đến từ thương hiệu khóa điện tử hàng đầu GATEMAN. FINGUS (WF-20) không chỉ là một thiết bị an ninh mà còn là một phần không thể thiếu, nâng tầm đẳng cấp cho mọi không gian. Với sự kết hợp hoàn hảo giữa công nghệ nhận diện vân tay tiên tiến và khả năng mở khóa bằng thẻ từ tiện lợi, sản phẩm này mang đến trải nghiệm an toàn, nhanh chóng và tinh tế cho mọi thành viên trong gia đình hoặc môi trường công sở. Hãy khám phá một giải pháp an ninh đột phá, nơi sự an tâm và tiện lợi giao thoa hoàn hảo.</p><h3>Đặc Điểm Nổi Bật</h3><h4>1. Công Nghệ Vân Tay FPC Thụy Điển – Bảo Mật Không Thể Xâm Phạm</h4><p>GATEMAN FINGUS (WF-20) được trang bị cảm biến vân tay FPC tiên tiến nhất từ Thụy Điển, một công nghệ sinh trắc học đã được chứng minh về độ chính xác và bảo mật. Khác với các cảm biến quang học truyền thống, FPC quét vân tay dựa trên cảm biến áp suất và nhiệt độ, cho phép nhận diện sâu các đặc điểm vân tay, từ đó loại bỏ hoàn toàn khả năng làm giả bằng silicon, keo dán hay ảnh chụp. Quá trình nhận diện diễn ra chỉ trong tích tắc, dưới 0.5 giây, đảm bảo việc mở cửa nhanh chóng và thuận tiện mà vẫn giữ vững tường thành bảo mật vững chắc nhất cho ngôi nhà hay văn phòng của bạn. Đây là sự lựa chọn tối ưu cho những ai đặt tiêu chí an toàn lên hàng đầu.</p><h4>2. Mở Khóa Bằng Thẻ Từ Tiện Lợi – Giải Pháp Cho Mọi Thành Viên</h4><p>Bên cạnh công nghệ vân tay, GATEMAN FINGUS (WF-20) còn tích hợp khả năng mở khóa bằng thẻ từ thông minh. Tính năng này đặc biệt hữu ích cho những người lớn tuổi, trẻ nhỏ hoặc những ai gặp khó khăn với việc nhận diện vân tay. Với khả năng lưu trữ lên đến 40 thẻ từ RFID, bạn có thể dễ dàng cấp phát và quản lý quyền truy cập cho từng thành viên trong gia đình hoặc nhân viên trong văn phòng một cách linh hoạt. Thẻ từ được mã hóa riêng biệt, cực kỳ nhỏ gọn và dễ dàng mang theo, mang lại sự tiện lợi tối đa mà không hề ảnh hưởng đến yếu tố an ninh. Đây là một giải pháp hoàn hảo để đảm bảo mọi người đều có thể vào nhà một cách dễ dàng và an toàn.</p><h4>3. Thiết Kế Sang Trọng, Đẳng Cấp – Nâng Tầm Kiến Trúc</h4><p>GATEMAN FINGUS (WF-20) không chỉ là một thiết bị an ninh mà còn là một tác phẩm nghệ thuật góp phần tô điểm cho không gian sống của bạn. Với thiết kế hiện đại, tinh tế và tối giản, sản phẩm này dễ dàng hòa nhập và làm nổi bật vẻ đẹp của mọi loại cửa, từ phong cách cổ điển đến hiện đại. Vỏ ngoài được chế tác từ hợp kim kẽm nguyên khối cao cấp, kết hợp với các đường nét bo tròn mềm mại và lớp phủ bề mặt chống trầy xước, chống bám vân tay, mang lại vẻ ngoài luôn sáng bóng và bền bỉ theo thời gian. Màu sắc trung tính, sang trọng giúp khóa vân tay FINGUS (WF-20) trở thành điểm nhấn tinh tế, thể hiện gu thẩm mỹ và đẳng cấp của gia chủ.</p><h4>4. Chức Năng Bảo Mật Kép Nâng Cao – An Toàn Tuyệt Đối</h4><p>Để đảm bảo an ninh ở mức độ cao nhất, GATEMAN FINGUS (WF-20) tích hợp nhiều tính năng bảo mật kép vượt trội. Chế độ &quot;mã số ảo&quot; cho phép bạn nhập thêm các số ngẫu nhiên trước hoặc sau mật khẩu chính, ngăn chặn kẻ gian đọc trộm mật khẩu qua dấu vân tay trên màn hình. Tính năng &quot;khóa trái từ bên trong&quot; (Double Lock) vô hiệu hóa mọi thao tác mở cửa từ bên ngoài, mang lại sự riêng tư và an toàn tuyệt đối khi bạn ở trong nhà. Ngoài ra, chức năng báo động chống phá khóa, đột nhập trái phép sẽ được kích hoạt ngay lập tức nếu có bất kỳ hành vi cố ý phá hoại nào, gửi cảnh báo đến bạn và những người xung quanh.</p><h4>5. Cảnh Báo Thông Minh Đa Lớp – Luôn Luôn An Tâm</h4><p>Sự an tâm của người dùng luôn là ưu tiên hàng đầu của GATEMAN. FINGUS (WF-20) được trang bị hệ thống cảnh báo thông minh đa lớp, mang đến sự bảo vệ toàn diện. Khóa sẽ tự động phát ra âm thanh cảnh báo lớn nếu phát hiện dấu hiệu cạy phá, đột nhập bất hợp pháp hoặc cố gắng mở cửa bằng phương pháp không hợp lệ. Đặc biệt, cảm biến nhiệt tích hợp sẽ kích hoạt báo động cháy nổ khi nhiệt độ bên trong vượt quá ngưỡng cho phép, đồng thời tự động mở khóa để tạo điều kiện thoát hiểm an toàn. Hệ thống còn cảnh báo khi pin yếu, giúp bạn thay pin kịp thời, tránh tình trạng gián đoạn hoạt động. Với FINGUS (WF-20), bạn luôn được thông báo và bảo vệ.</p><h4>6. Dễ Dàng Lắp Đặt &amp; Sử Dụng – Phù Hợp Mọi Lứa Tuổi</h4><p>GATEMAN FINGUS (WF-20) được thiết kế với tiêu chí thân thiện với người dùng, đảm bảo mọi thao tác cài đặt và sử dụng đều diễn ra một cách đơn giản, trực quan. Quy trình lắp đặt không quá phức tạp, có thể thực hiện bởi đội ngũ kỹ thuật viên chuyên nghiệp của Locker Korea trong thời gian ngắn. Giao diện người dùng rõ ràng, hệ thống hướng dẫn bằng giọng nói (tùy chọn) giúp người dùng dễ dàng thiết lập và quản lý vân tay, thẻ từ mà không cần đến sự hỗ trợ kỹ thuật phức tạp. Thiết kế tay nắm cửa dạng đẩy/kéo tiện lợi giúp việc mở cửa trở nên nhẹ nhàng, phù hợp cho cả trẻ nhỏ và người lớn tuổi, mang lại sự tiện nghi tối đa trong cuộc sống hàng ngày.</p><h4>7. Độ Bền Vượt Thời Gian – Cam Kết Chất Lượng</h4><p>GATEMAN là thương hiệu nổi tiếng với độ bền vượt trội, và FINGUS (WF-20) không phải là ngoại lệ. Sản phẩm được sản xuất theo quy trình nghiêm ngặt, trải qua hàng loạt kiểm tra chất lượng khắt khe để đảm bảo khả năng hoạt động ổn định và bền bỉ trong mọi điều kiện môi trường. Khóa có khả năng chịu lực tác động mạnh, chống ăn mòn và chống sốc điện hiệu quả. Toàn bộ linh kiện điện tử bên trong được bảo vệ bởi lớp vỏ chắc chắn và công nghệ chống ẩm, chống bụi, đảm bảo tuổi thọ lâu dài. Với GATEMAN FINGUS (WF-20), bạn không chỉ mua một sản phẩm mà còn đầu tư vào sự an tâm và độ bền bỉ đã được kiểm chứng.</p><h3>Công Nghệ &amp; Chất Liệu</h3><p>GATEMAN FINGUS (WF-20) là sự kết hợp hoàn hảo giữa những công nghệ tiên tiến nhất và các vật liệu cao cấp, tạo nên một sản phẩm khóa điện tử đỉnh cao về hiệu suất và độ bền. Trái tim của hệ thống bảo mật là <strong>cảm biến vân tay FPC (Fingerprint Cards AB) từ Thụy Điển</strong>, công nghệ sinh trắc học hàng đầu thế giới. Cảm biến này sử dụng công nghệ nhận diện bán dẫn điện dung, quét chi tiết các đặc điểm độc đáo của vân tay ở lớp hạ bì, giúp phân biệt vân tay thật với các vật liệu làm giả một cách chính xác tuyệt đối, giảm thiểu tối đa tỷ lệ từ chối sai và chấp nhận sai. Mọi dữ liệu vân tay và thẻ từ đều được mã hóa bằng <strong>thuật toán bảo mật AES-128 bit</strong>, đảm bảo thông tin cá nhân của bạn được bảo vệ an toàn khỏi các mối đe dọa từ bên ngoài.</p><p>Về mặt vật liệu, FINGUS (WF-20) được chế tạo từ <strong>hợp kim kẽm đúc nguyên khối</strong> cao cấp, mang lại độ cứng cáp và khả năng chống va đập vượt trội. Bề mặt khóa được xử lý bằng công nghệ <strong>phủ Nano PVD (Physical Vapor Deposition)</strong> tiên tiến, không chỉ tạo nên vẻ ngoài sang trọng, bền màu mà còn chống trầy xước, chống ăn mòn hiệu quả trước tác động của thời tiết và hóa chất. Phần tay nắm được thiết kế với <strong>lõi thép cường lực</strong> bên trong, đảm bảo độ chắc chắn và chịu lực cao. Các chi tiết bên trong sử dụng nhựa ABS chống cháy chất lượng cao, tăng cường khả năng chịu nhiệt và đảm bảo an toàn cho người sử dụng trong trường hợp hỏa hoạn. Hệ thống mạch điện được thiết kế thông minh, sử dụng <strong>chip xử lý tốc độ cao</strong> và được bọc chống ẩm, chống bụi, đảm bảo hoạt động ổn định và bền bỉ qua thời gian.</p><h3>Ứng Dụng Thực Tế</h3><p>Khóa vân tay GATEMAN FINGUS (WF-20) với sự kết hợp hoàn hảo giữa công nghệ hiện đại và thiết kế tinh tế, là lựa chọn lý tưởng cho nhiều loại hình không gian và đối tượng người dùng khác nhau. Đây là giải pháp an ninh vượt trội cho <strong>các căn hộ chung cư cao cấp, biệt thự sang trọng</strong>, nơi yêu cầu cao về bảo mật và tính thẩm mỹ. Gia đình có trẻ nhỏ và người lớn tuổi sẽ đặc biệt yêu thích FINGUS (WF-20) bởi sự dễ dàng trong việc mở khóa bằng vân tay hoặc thẻ từ, không còn loay hoay với chìa khóa cơ truyền thống, giúp mọi thành viên ra vào nhà một cách thuận tiện và an toàn tuyệt đối.</p><p>Ngoài ra, GATEMAN FINGUS (WF-20) cũng là lựa chọn hoàn hảo cho <strong>các văn phòng làm việc, phòng ban cần kiểm soát truy cập</strong>, hay các cửa hàng, studio nhỏ. Khả năng quản lý nhiều vân tay và thẻ từ giúp chủ doanh nghiệp dễ dàng cấp quyền truy cập cho nhân viên, đồng thời dễ dàng loại bỏ quyền truy cập khi cần thiết. Đối với những người bận rộn, thường xuyên di chuyển, việc không cần mang theo chìa khóa vật lý sẽ mang lại sự tự do và tiện lợi tối đa. FINGUS (WF-20) không chỉ bảo vệ tài sản mà còn mang đến sự an tâm, nâng cao chất lượng cuộc sống và làm việc, biến cánh cửa của bạn trở thành một cổng an ninh thông minh, linh hoạt và đáng tin cậy.</p><h3>Kết Luận</h3><blockquote>Đầu tư vào GATEMAN FINGUS (WF-20) là đầu tư vào sự an tâm, tiện nghi và đẳng cấp. Hãy để Locker Korea đồng hành cùng bạn trên hành trình kiến tạo một không gian sống và làm việc hiện đại, an toàn hơn bao giờ hết.</blockquote><p>Với khóa vân tay GATEMAN FINGUS (WF-20), bạn không chỉ sở hữu một thiết bị an ninh thông thường mà còn là một giải pháp toàn diện cho cuộc sống hiện đại. Sự kết hợp giữa công nghệ vân tay FPC Thụy Điển hàng đầu, tính năng mở khóa bằng thẻ từ linh hoạt, thiết kế sang trọng và khả năng bảo mật đa lớp đã tạo nên một sản phẩm hoàn hảo. FINGUS (WF-20) mang lại sự yên bình tuyệt đối cho tâm trí bạn, giúp bạn tận hưởng cuộc sống mà không phải lo lắng về an ninh. Hãy nói lời tạm biệt với những chiếc chìa khóa cồng kềnh và chào đón kỷ nguyên của sự tiện lợi, an toàn tối ưu. Lựa chọn GATEMAN FINGUS (WF-20) từ Locker Korea chính là lựa chọn sự tinh hoa của công nghệ bảo mật, nâng tầm giá trị cho không gian sống và làm việc của bạn.</p>', '2024-02-16 16:46:58', '2025-11-05 12:48:17', 1, 30, 51),
(2, 'Khóa vân tay Samsung SHP-DH538', 5490000, 'DH538_co 3-4.jpg', 'Khóa vân tay Samsung SHP-DH538 - Mở bằng vân tay, mã số, chìa cơ dự phòng. Chống nước, thiết kế hiện đại.', '2024-02-17 07:35:46', '2025-11-04 15:43:33', 2, 20, 3),
(3, 'Khóa vân tay SamSung SHS P718', 8500000, '03fde30d-fbb6-4306-bae0-4ebfb4ece53a_700_mat ngoaiw.png', '<p></p><h2 class=\"ql-align-center\"><span style=\"color: rgb(0, 64, 128);\">Khóa Cửa Vân Tay Samsung SHS P718 – Nâng Tầm An Ninh, Định Hình Phong Cách Sống</span></h2><p class=\"ql-align-center\"><span style=\"color: rgb(85, 85, 85);\">Tại Locker Korea, chúng tôi tự hào giới thiệu siêu phẩm </span><strong style=\"color: rgb(0, 64, 128);\">khóa vân tay Samsung SHS P718</strong><span style=\"color: rgb(85, 85, 85);\"> – biểu tượng của sự kết hợp hoàn hảo giữa công nghệ bảo mật hàng đầu, thiết kế tinh tế và trải nghiệm người dùng vượt trội. Đây không chỉ là một thiết bị an ninh mà còn là một tuyên ngôn về đẳng cấp và sự tiện nghi cho mọi không gian sống hiện đại. Samsung SHS P718 cam kết mang đến sự an tâm tuyệt đối và phong cách sống thời thượng cho gia đình bạn.</span></p><h3><span style=\"color: rgb(0, 64, 128);\">Đặc Điểm Nổi Bật Vượt Trội</span></h3><p><span style=\"color: rgb(51, 51, 51);\">Samsung SHS P718 được thiết kế để đáp ứng mọi kỳ vọng của bạn về một hệ thống an ninh hiện đại, với những ưu điểm không thể bỏ qua:</span></p><ul><li><strong style=\"color: rgb(51, 51, 51);\">Công Nghệ Vân Tay Siêu Nhạy và An Toàn:</strong><span style=\"color: rgb(51, 51, 51);\"> Tích hợp cảm biến vân tay quang học/FPC tiên tiến, nhận diện chỉ trong tích tắc, đảm bảo độ chính xác và bảo mật tối đa, loại bỏ hoàn toàn nguy cơ sao chép hoặc làm giả vân tay.</span></li><li><strong style=\"color: rgb(51, 51, 51);\">Thiết Kế Tay Cầm Push-Pull Đột Phá:</strong><span style=\"color: rgb(51, 51, 51);\"> Cơ chế mở/đóng cửa bằng cách đẩy hoặc kéo nhẹ nhàng, mang lại trải nghiệm sử dụng vô cùng tiện lợi và thoải mái, đặc biệt khi bạn đang mang vác đồ đạc.</span></li><li><strong style=\"color: rgb(51, 51, 51);\">Đa Dạng Phương Thức Mở Khóa Linh Hoạt:</strong><span style=\"color: rgb(51, 51, 51);\"> Cung cấp tới 4 tùy chọn mở khóa: vân tay, mã số, thẻ từ và chìa khóa cơ dự phòng, cho phép bạn và gia đình lựa chọn phương thức phù hợp nhất trong mọi tình huống.</span></li><li><strong style=\"color: rgb(51, 51, 51);\">Hệ Thống Bảo Mật Đa Lớp Thông Minh:</strong><span style=\"color: rgb(51, 51, 51);\"> Từ mã số ảo chống nhìn trộm, tính năng khóa kép từ bên trong, đến cảnh báo xâm nhập và cháy nổ, P718 mang đến một lớp bảo vệ vững chắc cho ngôi nhà của bạn.</span></li><li><strong style=\"color: rgb(51, 51, 51);\">Chất Liệu Cao Cấp, Bền Bỉ Theo Thời Gian:</strong><span style=\"color: rgb(51, 51, 51);\"> Được chế tạo từ hợp kim kẽm siêu bền và bề mặt kính cường lực chống trầy xước, khóa không chỉ sang trọng mà còn có khả năng chống chịu va đập, ăn mòn hiệu quả.</span></li><li><strong style=\"color: rgb(51, 51, 51);\">Cảnh Báo An Ninh Tức Thời:</strong><span style=\"color: rgb(51, 51, 51);\"> Tích hợp các cảm biến thông minh để phát hiện các mối đe dọa như cháy nổ, phá hoại hoặc xâm nhập trái phép, đồng thời phát ra âm thanh cảnh báo lớn và gửi thông báo (nếu có module kết nối nhà thông minh).</span></li></ul><h3><span style=\"color: rgb(0, 64, 128);\">Công Nghệ &amp; Chất Liệu Vượt Trội</span></h3><p><span style=\"color: rgb(51, 51, 51);\">Sự ưu việt của Samsung SHS P718 không chỉ nằm ở vẻ ngoài mà còn ẩn chứa trong từng chi tiết công nghệ và chất liệu cấu thành:</span></p><h4><span style=\"color: rgb(0, 86, 179);\">Công Nghệ Nhận Diện Vân Tay FPC Tiên Tiến</span></h4><p><span style=\"color: rgb(51, 51, 51);\">Trái tim của Samsung SHS P718 là công nghệ nhận diện vân tay FPC (Fingerprint Cards) hoặc quang học thế hệ mới, cho phép quét và xác thực vân tay với độ chính xác cao tuyệt đối, chỉ trong </span><strong style=\"color: rgb(51, 51, 51);\">0.5 giây</strong><span style=\"color: rgb(51, 51, 51);\">. Khả năng chống làm giả vân tay hiệu quả, kết hợp với bộ nhớ lớn (có thể lưu trữ tới 100 vân tay), giúp việc quản lý ra vào trở nên dễ dàng và an toàn hơn bao giờ hết. Bạn sẽ không còn phải lo lắng về việc mất chìa khóa hay lộ mã số.</span></p><h4><span style=\"color: rgb(0, 86, 179);\">Cơ Chế Tay Cầm Push-Pull Đột Phá</span></h4><p><span style=\"color: rgb(51, 51, 51);\">Thiết kế tay cầm Push-Pull là điểm nhấn độc đáo, giúp việc mở cửa trở nên </span><strong style=\"color: rgb(0, 64, 128);\">thuận tiện và trực quan</strong><span style=\"color: rgb(51, 51, 51);\">. Thay vì phải xoay hoặc vặn tay nắm, bạn chỉ cần đẩy nhẹ từ bên ngoài để vào hoặc kéo nhẹ từ bên trong để ra. Cơ chế này đặc biệt hữu ích cho người già, trẻ nhỏ hoặc khi bạn đang bận tay xách đồ, mang lại sự mượt mà và thoải mái tối đa trong mọi thao tác.</span></p><h4><span style=\"color: rgb(0, 86, 179);\">Bộ Vi Xử Lý Thông Minh và Mã Số Ảo Chống Lộ</span></h4><p><span style=\"color: rgb(51, 51, 51);\">P718 được trang bị bộ vi xử lý thông minh, cho phép người dùng thiết lập </span><strong style=\"color: rgb(0, 64, 128);\">mã số ảo</strong><span style=\"color: rgb(51, 51, 51);\"> – một tính năng bảo mật tuyệt vời giúp ngăn chặn việc lộ mã số ngay cả khi có người đứng cạnh quan sát. Bạn có thể nhập một dãy số bất kỳ trước hoặc sau mã số chính mà vẫn mở được khóa. Thêm vào đó, chức năng mã số chủ (Master Code) cho phép quản lý toàn bộ cài đặt khóa, tăng cường quyền kiểm soát an ninh tối đa.</span></p><h4><span style=\"color: rgb(0, 86, 179);\">Kết Cấu Bền Vững Từ Hợp Kim Cao Cấp</span></h4><p><span style=\"color: rgb(51, 51, 51);\">Vỏ khóa được chế tác từ </span><strong style=\"color: rgb(0, 64, 128);\">hợp kim kẽm nguyên khối</strong><span style=\"color: rgb(51, 51, 51);\">, trải qua quy trình xử lý bề mặt tinh xảo, chống ăn mòn và oxy hóa hiệu quả. Bề mặt bàn phím cảm ứng được bảo vệ bằng kính cường lực Gorilla Glass, chống trầy xước, va đập và chịu lực tốt, đảm bảo độ bền vượt trội theo thời gian. Sự kết hợp giữa vật liệu cao cấp và kỹ thuật chế tạo tiên tiến mang lại cho P718 khả năng hoạt động ổn định và bền bỉ trong mọi điều kiện môi trường.</span></p><h4><span style=\"color: rgb(0, 86, 179);\">Cảm Biến Cháy và Chống Sốc Điện</span></h4><p><span style=\"color: rgb(51, 51, 51);\">An toàn luôn là ưu tiên hàng đầu. Samsung SHS P718 được tích hợp </span><strong style=\"color: rgb(0, 64, 128);\">cảm biến nhiệt độ</strong><span style=\"color: rgb(51, 51, 51);\"> bên trong, sẽ tự động mở khóa khi phát hiện nhiệt độ trong nhà tăng cao bất thường (trên 60°C), giúp người trong nhà thoát hiểm kịp thời trong trường hợp hỏa hoạn. Đồng thời, khóa còn có tính năng </span><strong style=\"color: rgb(0, 64, 128);\">chống sốc điện tử</strong><span style=\"color: rgb(51, 51, 51);\">, vô hiệu hóa mọi nỗ lực mở khóa bằng các thiết bị điện áp cao, đảm bảo an toàn tuyệt đối cho hệ thống và người dùng.</span></p><h3><span style=\"color: rgb(0, 64, 128);\">Ứng Dụng Đa Dạng &amp; Linh Hoạt</span></h3><p><span style=\"color: rgb(51, 51, 51);\">Với thiết kế sang trọng và tính năng ưu việt, Samsung SHS P718 là lựa chọn lý tưởng cho nhiều không gian khác nhau:</span></p><ul><li><strong style=\"color: rgb(51, 51, 51);\">Không Gian Sống Hiện Đại:</strong><span style=\"color: rgb(51, 51, 51);\"> Phù hợp cho căn hộ chung cư cao cấp, biệt thự, nhà phố, mang lại sự tiện nghi và an tâm cho mọi thành viên trong gia đình.</span></li><li><strong style=\"color: rgb(51, 51, 51);\">Văn Phòng &amp; Công Sở:</strong><span style=\"color: rgb(51, 51, 51);\"> Dễ dàng quản lý quyền ra vào cho nhân viên, đối tác, đồng thời tăng cường bảo mật cho các khu vực quan trọng.</span></li><li><strong style=\"color: rgb(51, 51, 51);\">Phù Hợp Mọi Thành Viên Gia Đình:</strong><span style=\"color: rgb(51, 51, 51);\"> Với nhiều phương thức mở khóa và thao tác đơn giản, P718 dễ dàng sử dụng cho cả người lớn tuổi (không cần nhớ mật khẩu, chỉ cần vân tay/thẻ từ) và trẻ nhỏ (không cần loay hoay với chìa khóa).</span></li></ul><blockquote><em style=\"color: rgb(85, 85, 85); background-color: rgb(248, 248, 248);\">&quot;Samsung SHS P718 không chỉ là một chiếc khóa cửa, mà là một giải pháp an ninh toàn diện, mang đến sự an tâm tuyệt đối và nâng tầm giá trị cho không gian sống của bạn.&quot;</em></blockquote><h3><span style=\"color: rgb(0, 64, 128);\">Kết Luận: Tại Sao Samsung SHS P718 Là Lựa Chọn Hoàn Hảo?</span></h3><p><span style=\"color: rgb(51, 51, 51);\">Trong thế giới ngày càng phát triển, nhu cầu về một ngôi nhà không chỉ đẹp mà còn an toàn và thông minh trở nên cấp thiết hơn bao giờ hết. </span><strong style=\"color: rgb(0, 64, 128);\">Khóa vân tay Samsung SHS P718</strong><span style=\"color: rgb(51, 51, 51);\"> chính là câu trả lời hoàn hảo cho mọi mong đợi đó.</span></p><p><span style=\"color: rgb(51, 51, 51);\">Khi lựa chọn P718, bạn không chỉ đầu tư vào một sản phẩm công nghệ cao mà còn đầu tư vào </span><strong style=\"color: rgb(0, 64, 128);\">sự yên bình, tiện lợi và đẳng cấp</strong><span style=\"color: rgb(51, 51, 51);\">. Từ khả năng bảo mật vượt trội với vân tay siêu nhạy, đến thiết kế Push-Pull độc đáo mang lại trải nghiệm mở cửa mượt mà, P718 đã và đang định nghĩa lại chuẩn mực về khóa cửa điện tử.</span></p><p><span style=\"color: rgb(51, 51, 51);\">Với chất liệu bền bỉ, công nghệ thông minh và các tính năng cảnh báo an ninh tiên tiến, Samsung SHS P718 mang đến sự bảo vệ tối ưu cho tài sản và những người thân yêu của bạn. Nó phù hợp với mọi thành viên trong gia đình, từ người lớn tuổi đến trẻ nhỏ, biến mỗi lần ra vào nhà thành một trải nghiệm dễ dàng và an toàn.</span></p><p><span style=\"color: rgb(51, 51, 51);\">Hãy để </span><strong style=\"color: rgb(0, 64, 128);\">Locker Korea</strong><span style=\"color: rgb(51, 51, 51);\"> đồng hành cùng bạn trên hành trình kiến tạo không gian sống an toàn, tiện nghi và sang trọng. Liên hệ ngay hôm nay để được tư vấn chi tiết về khóa vân tay Samsung SHS P718 và nhận những ưu đãi tốt nhất!</span></p><p>```</p>', '2024-02-17 07:35:46', '2025-11-05 02:17:43', 2, 60, 8),
(4, 'Khóa SAMSUNG SHS-2920', 4200000, 'SHS-2920_1.jpg', 'Khóa SAMSUNG SHS-2920 - Khóa điện tử mã số, thiết kế đơn giản, phù hợp mọi loại cửa.', '2024-02-17 07:35:46', '2024-02-17 07:35:46', 2, NULL, 0),
(5, 'Khóa điện tử SAMSUNG SHP-DS700', 3290000, 'SHP-DS700_1.jpg', 'Khóa điện tử Samsung SHP-DS700 cao cấp, mở khóa bằng thẻ từ và mã số.', '2024-02-17 07:35:46', '2025-06-13 10:03:43', 2, 60, 48),
(6, 'Khóa điện tử SAMSUNG SHS 1321', 3480000, '1321-1-3-4.jpg', 'Khóa điện tử Samsung SHS 1321 với thiết kế thanh lịch, bảo mật cao.', '2024-02-17 07:35:46', '2025-06-13 07:07:29', 2, 5, 333),
(7, 'Khóa vân tay SAMSUNG SHP-DP930', 12000000, 'SAMSUNG DP920.jpg', 'Khóa vân tay Samsung SHP-DP930 premium, màn hình cảm ứng, kết nối WiFi.', '2024-02-17 07:35:46', '2024-02-17 07:35:46', 2, NULL, 50),
(8, 'Khóa vân tay Samsung SHS-H700', 9500000, '700_mat ngoaiw.png', 'Khóa vân tay Samsung SHS-H700 cao cấp, thiết kế sang trọng, hỗ trợ vân tay 360 độ.', '2024-02-17 07:35:46', '2025-06-13 06:20:04', 2, 80, 2),
(9, 'Chuông cửa hình SAMSUNG SHT-3517NT', 4200000, 'sht-3517nt-1.jpg', 'Chuông cửa video Samsung SHT-3517NT với màn hình 7 inch, camera HD, tính năng hai chiều.', '2024-02-17 07:35:46', '2025-06-13 08:11:55', 11, 20, 0),
(11, 'Khóa điện tử GATEMAN WG-200', 4190000, 'wg-200 3-4.jpg', 'Khóa điện tử GATEMAN WG-200 - Mở bằng mã số và thẻ từ. Kiểu dáng thanh lịch, vật liệu siêu bền.', '2024-02-17 07:35:46', '2024-02-17 07:35:46', 1, NULL, 0),
(12, 'Khóa vân tay GATEMAN WF200', 6990000, 'wf-200_34.jpg', 'Khóa vân tay GATEMAN WF200 - Mở bằng vân tay, mật mã. Bàn phím cảm ứng chất liệu đặc biệt, bền, sang trọng.', '2024-02-17 07:35:46', '2024-02-17 07:35:46', 1, NULL, 0),
(13, 'Khóa vân tay GATEMAN Z10-IH', 5600000, 'Z10_3 3-4.jpg', 'Khóa vân tay GATEMAN Z10-IH với công nghệ mới nhất, mở khóa nhanh 0.3 giây.', '2024-02-17 07:35:46', '2025-06-13 06:19:12', 4, 4, 465),
(14, 'GATEMAN F300-FH', 7950000, 'Gateman F300-FH.jpg', 'Khóa vân tay GATEMAN F300-FH kết nối WiFi, điều khiển từ xa, báo động chống trộm.', '2024-02-17 07:35:46', '2025-06-13 11:34:06', 1, 60, 7),
(15, 'Khóa vân tay GATEMAN F50-FH', 5250000, 'Gateman F50-FH.jpg', 'Khóa vân tay GATEMAN F50-FH thiết kế cổ điển hiện đại, chống nước IP54, tuổi thọ pin lên đến 12 tháng.', '2024-02-17 07:35:46', '2024-02-17 07:35:46', 1, NULL, 0),
(16, 'Khóa vân tay H-Gang TR812', 3350000, 'TR812_3-4.png', 'Khóa vân tay H-Gang TR812 thông minh cao cấp từ Hàn Quốc. Công nghệ hiện đại, bảo mật cao, thiết kế sang trọng.', '2024-02-17 07:35:46', '2025-06-13 07:07:51', 3, 28, 234),
(17, 'Khóa cửa kính H-Gang Sync TG330', 3800000, 'TG330_1.jpg', 'Khóa cửa kính H-Gang Sync TG330 với thiết kế tinh tế cho cửa kính cường lực.', '2024-02-17 07:35:46', '2025-11-06 02:15:13', 10, 73, 30),
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
(5785, 'Mercedes GLE 350', 6990000000, '58760ad5-7ea7-4bc6-a8e6-4c02af90c8cf_images.jpg', 'ádasdasd', '2025-06-13 08:29:52', '2025-11-04 12:42:12', 5, 55, 1),
(5788, 'Lap Truong Quang', 23304432, '1d2541cc-f207-45cd-ae64-8ab713c10b9d_SHS-2920_1.jpg', '', '2025-11-05 02:44:38', '2025-11-05 02:44:41', 2, 11, 2);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `product_features`
--

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

INSERT INTO `product_features` (`id`, `product_id`, `feature_id`, `created_at`, `updated_at`) VALUES
(3, 2, 1, '2025-06-13 12:00:00', '2025-11-04 11:30:34'),
(4, 2, 2, '2025-06-13 12:00:00', '2025-11-04 11:30:34'),
(7, 5788, 2, '2025-11-05 02:44:38', '2025-11-05 02:44:38'),
(8, 5788, 5, '2025-11-05 02:44:38', '2025-11-05 02:44:38'),
(11, 1, 1, '2025-11-05 13:33:32', '2025-11-05 13:33:32'),
(12, 1, 3, '2025-11-05 13:33:32', '2025-11-05 13:33:32'),
(13, 3, 1, '2025-11-06 00:58:41', '2025-11-06 00:58:41'),
(14, 3, 8, '2025-11-06 00:58:41', '2025-11-06 00:58:41'),
(15, 3, 4, '2025-11-06 00:58:41', '2025-11-06 00:58:41'),
(16, 3, 5, '2025-11-06 00:58:41', '2025-11-06 00:58:41'),
(17, 3, 6, '2025-11-06 00:58:41', '2025-11-06 00:58:41');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `product_images`
--

CREATE TABLE `product_images` (
  `id` bigint NOT NULL,
  `product_id` int DEFAULT NULL,
  `image_url` varchar(300) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Đang đổ dữ liệu cho bảng `product_images`
--

INSERT INTO `product_images` (`id`, `product_id`, `image_url`) VALUES
(125, 5784, '17b301fe-dbd0-4c8a-a990-5edef383e497_bsb004501__2__36b648ff5dfb4a0fbc909605f1dc7d53_grande.jpg'),
(126, 5785, '58760ad5-7ea7-4bc6-a8e6-4c02af90c8cf_images.jpg'),
(132, 1, '2af2e2f9-692c-4209-9b6b-c0ce1da22d87_Nike-Air-Jordan-1-Retro-Low-OG-SP-Travis-ScottT-8-300x300.jpg.jpg'),
(133, 1, 'ebbf7fd1-b659-4dab-bca3-33691e9d661d_Nike-Air-Jordan-1-Retro-Low-OG-SP-Travis-ScottT-8-300x300.jpg.jpg'),
(134, 1, 'bfbbf398-6f57-4b27-8f90-0c61c46be7e5_Nike-Air-Jordan-1-Retro-Low-OG-SP-Travis-ScottT-8-300x300.jpg.jpg'),
(135, 1, '1bc170c9-2706-4a4e-8992-875a05e15314_alexander-mcqueen-trang-got-den-sieu-cap-1-300x300.jpg.jpg'),
(136, 3, '03fde30d-fbb6-4306-bae0-4ebfb4ece53a_700_mat ngoaiw.png'),
(137, 5788, '1d2541cc-f207-45cd-ae64-8ab713c10b9d_SHS-2920_1.jpg'),
(138, 5788, '37df6011-9b2a-40d0-9036-bf4e40427836_SHS-P718_3-4.png'),
(139, 5788, 'c51a2eea-1c0d-4e4b-bca8-e668755b9d83_sht-3517nt-1.jpg');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `return_requests`
--

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
(12, 92, 'àdasfadsfdsafsadfasdf', 'REFUNDED', 29030000.00, 'Refunded via Stripe. àasdfsfds', '2025-06-13 04:47:09', '2025-06-13 04:47:23');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `reviews`
--

CREATE TABLE `reviews` (
  `id` bigint NOT NULL,
  `product_id` int NOT NULL COMMENT 'ID sản phẩm',
  `user_id` int NOT NULL COMMENT 'ID người dùng',
  `rating` int NOT NULL COMMENT 'Đánh giá từ 1-5 sao',
  `comment` text COMMENT 'Nội dung bình luận',
  `staff_reply` text COMMENT 'Phản hồi từ nhân viên',
  `staff_reply_by` int DEFAULT NULL COMMENT 'ID nhân viên phản hồi',
  `staff_reply_at` datetime DEFAULT NULL COMMENT 'Thời gian phản hồi',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Đang đổ dữ liệu cho bảng `reviews`
--

INSERT INTO `reviews` (`id`, `product_id`, `user_id`, `rating`, `comment`, `staff_reply`, `staff_reply_by`, `staff_reply_at`, `created_at`, `updated_at`) VALUES
(1, 1, 18, 5, 'Sản phẩm rất tốt, chất lượng cao!', 'Chuẩn rồi, cảm ơn bạn đã tin tưởng cửa hàng Khoá vân tay Korea', 3, '2025-11-06 00:40:26', '2025-06-13 15:00:00', '2025-11-06 00:40:26'),
(3, 2, 18, 5, 'Rất hài lòng với sản phẩm', 'Xin cảm ơn bạn đã mua sản phẩm', 19, '2025-11-05 21:42:07', '2025-06-13 17:00:00', '2025-11-05 21:42:07'),
(5, 3, 18, 5, 'VIP\n', 'Cảm ơn bạn', 19, '2025-11-05 21:42:28', '2025-11-05 02:19:50', '2025-11-05 21:42:28');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `roles`
--

CREATE TABLE `roles` (
  `id` int NOT NULL,
  `name` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Đang đổ dữ liệu cho bảng `roles`
--

INSERT INTO `roles` (`id`, `name`) VALUES
(1, 'USER'),
(2, 'ADMIN'),
(3, 'STAFF');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `users`
--

CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
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
  `reset_password_token_expiry` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `role_id` (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Đang đổ dữ liệu cho bảng `users`
--

INSERT INTO `users` (`id`, `fullname`, `phone_number`, `email`, `address`, `password`, `created_at`, `updated_at`, `is_active`, `date_of_birth`, `facebook_account_id`, `google_account_id`, `role_id`, `reset_password_token`, `reset_password_token_expiry`) VALUES
(3, 'Tổng tài Lạnh lùng', '0111222333', 'admin@gmail.com', 'Hanoi', '$2a$10$zgJgPl51rJQGl8xlznCKgOGipZjbaPMXiF/Zv/03ri1mA1iN1Z.su', '2024-02-21 09:00:03', '2025-11-06 02:33:11', 1, '2003-11-12 00:00:00.000000', 0, 0, 2, NULL, NULL),
(18, 'Truong Quang Lap', '0854768836', 'secroramot123@gmail.com', 'lap', '$2a$10$vagQjcnWTqYMU8mxtWsl.uF8DY3te0JzO6ObqVMkA9TfdMBa1mZEi', '2025-06-09 19:33:13', '2025-11-06 03:10:11', 1, '2003-10-26 00:00:00.000000', 0, 0, 1, NULL, NULL),
(19, 'Lap Truong Quang', '0975050669', 'lapduynh11@gmail.com', 'addsadasdasd', '$2a$10$Mx7VmM5VdSMRgR33Z2xGiuKkys1L6a1lSoLSxZ1nuSAG5aZjFFc5q', '2025-11-05 19:52:01', '2025-11-05 20:00:43', 1, '2025-11-05 19:51:32.495000', 0, 0, 3, NULL, NULL);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `vouchers`
--

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
(1, 'SALE66', 'Sale 6/6', 'Giảm giá nhân dịp 6/6', 20, 500000, 100000, 100, 100, '2024-05-31 17:00:00', '2026-06-30 16:59:00', 1, '2025-06-09 18:19:46', '2025-11-05 18:10:47'),
(11, 'SAMSUNG', 'Sản phẩm SAMSUNG', '', 10, 1, NULL, 2, 1, '2025-11-05 19:14:32', '2025-12-05 19:14:32', 1, '2025-11-06 02:14:53', '2025-11-06 02:15:13');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `voucher_usage`
--

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
(3, 11, 94, 18, 380000, '2025-11-06 02:15:09');

--
-- Chỉ mục cho các bảng đã đổ
--

--
-- Chỉ mục cho bảng `banners`
--
ALTER TABLE `banners`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_is_active` (`is_active`),
  ADD KEY `idx_display_order` (`display_order`),
  ADD KEY `idx_date_range` (`start_date`,`end_date`);

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
-- Chỉ mục cho bảng `chat_conversations`
--
ALTER TABLE `chat_conversations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_conv_customer` (`customer_id`),
  ADD KEY `idx_conv_staff` (`staff_id`);

--
-- Chỉ mục cho bảng `chat_messages`
--
ALTER TABLE `chat_messages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_sender` (`sender_id`),
  ADD KEY `idx_receiver` (`receiver_id`),
  ADD KEY `idx_created_at` (`created_at`),
  ADD KEY `idx_is_staff` (`is_staff_message`),
  ADD KEY `idx_is_closed` (`is_closed`),
  ADD KEY `idx_closed_by` (`closed_by`),
  ADD KEY `idx_guest_session` (`guest_session_id`),
  ADD KEY `idx_msg_conversation` (`conversation_id`);

--
-- Chỉ mục cho bảng `lock_features`
--
ALTER TABLE `lock_features`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_is_active` (`is_active`);

--
-- Chỉ mục cho bảng `news`
--
ALTER TABLE `news`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_category` (`category`),
  ADD KEY `idx_published_at` (`published_at`);

--
-- Chỉ mục cho bảng `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `orders_voucher_fk` (`voucher_id`),
  ADD KEY `idx_orders_payment_intent_id` (`payment_intent_id`);

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
-- Chỉ mục cho bảng `product_features`
--
ALTER TABLE `product_features`
  ADD PRIMARY KEY (`id`),
  ADD KEY `product_id` (`product_id`),
  ADD KEY `feature_id` (`feature_id`),
  ADD KEY `created_at` (`created_at`);

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
  ADD KEY `idx_rating` (`rating`),
  ADD KEY `idx_staff_reply_by` (`staff_reply_by`);

--
-- Chỉ mục cho bảng `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id`);

-- (Bỏ qua vì đã tạo PRIMARY KEY/UNIQUE/KEY trong CREATE TABLE `users` ở trên)

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
-- AUTO_INCREMENT cho các bảng đã đổ
--

--
-- AUTO_INCREMENT cho bảng `banners`
--
ALTER TABLE `banners`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT cho bảng `carts`
--
ALTER TABLE `carts`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=28;

--
-- AUTO_INCREMENT cho bảng `categories`
--
ALTER TABLE `categories`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT cho bảng `chat_conversations`
--
ALTER TABLE `chat_conversations`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `chat_messages`
--
ALTER TABLE `chat_messages`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT cho bảng `lock_features`
--
ALTER TABLE `lock_features`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT cho bảng `news`
--
ALTER TABLE `news`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT cho bảng `orders`
--
ALTER TABLE `orders`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=95;

--
-- AUTO_INCREMENT cho bảng `order_details`
--
ALTER TABLE `order_details`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=128;

--
-- AUTO_INCREMENT cho bảng `products`
--
ALTER TABLE `products`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5789;

--
-- AUTO_INCREMENT cho bảng `product_features`
--
ALTER TABLE `product_features`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT cho bảng `product_images`
--
ALTER TABLE `product_images`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=140;

--
-- AUTO_INCREMENT cho bảng `return_requests`
--
ALTER TABLE `return_requests`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT cho bảng `reviews`
--
ALTER TABLE `reviews`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT cho bảng `roles`
--
ALTER TABLE `roles`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

-- (Bỏ qua vì `users.id` đã AUTO_INCREMENT trong CREATE TABLE)

--
-- AUTO_INCREMENT cho bảng `vouchers`
--
ALTER TABLE `vouchers`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT cho bảng `voucher_usage`
--
ALTER TABLE `voucher_usage`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Ràng buộc đối với các bảng kết xuất
--

--
-- Ràng buộc cho bảng `carts`
--
-- Dọn dữ liệu mồ côi trước khi thêm FK (user_id không tồn tại trong users)
UPDATE `carts` c
LEFT JOIN `users` u ON c.`user_id` = u.`id`
SET c.`user_id` = NULL
WHERE c.`user_id` IS NOT NULL AND u.`id` IS NULL;

ALTER TABLE `carts`
  ADD CONSTRAINT `FK__products` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`),
  ADD CONSTRAINT `FK__users` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

-- (Bỏ qua: các FK cho `chat_conversations` đã được thêm sau khi `users` có index id)

-- (Bỏ qua: dùng các FK mới `fk_msg_sender`, `fk_msg_receiver`, `fk_msg_conv` đã thêm ở phần trên; cột `closed_by` đã bị loại bỏ trong V2)

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
-- Ràng buộc cho bảng `product_features`
--
ALTER TABLE `product_features`
  ADD CONSTRAINT `product_features_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `product_features_ibfk_2` FOREIGN KEY (`feature_id`) REFERENCES `lock_features` (`id`) ON DELETE CASCADE;

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
  ADD CONSTRAINT `fk_review_staff` FOREIGN KEY (`staff_reply_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `reviews_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

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
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
