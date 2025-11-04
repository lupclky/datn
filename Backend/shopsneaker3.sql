-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Máy chủ: mysql8-container
-- Thời gian đã tạo: Th10 04, 2025 lúc 06:32 PM
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
(3, 'Chất lượng Hàn Quốc', 'Thiết kế sang trọng, vận hành bền bỉ', '77ee50a6-af85-43fe-a7df-94c19e967c29_64baf7b5-635b-4a9e-aec7-03d0fedac82f_nike-air-force-1-low-replica-800x600.jpg', 'Xem thêm', '/allProduct', 'success', 3, 1, NULL, NULL, '2025-11-04 12:58:04', '2025-11-04 13:44:26');

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
(10, 'Khóa cửa kính'),
(11, 'Chuông hình');

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
(7, 'Cảnh báo an ninh', 'Cảnh báo khi có xâm nhập', 1, '2025-06-13 12:00:00', '2025-06-13 12:00:00');

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
(1, 'Giới thiệu sản phẩm mới', '<p>Nội dung chi tiết về sản ph<span style=\"background-color: initial; color: inherit;\">Sau nhiều tháng thử nghiệm beta,&nbsp;</span><a href=\"https://tinhte.vn/tag/apple\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"background-color: initial; color: rgb(7, 104, 234);\">Apple</a><span style=\"background-color: initial; color: inherit;\">&nbsp;hôm nay đã chính thức phát hành&nbsp;</span><a href=\"https://tinhte.vn/tag/ios-261\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"background-color: initial; color: rgb(7, 104, 234);\">iOS 26.1</a><span style=\"background-color: initial; color: inherit;\">&nbsp;và iPadOS 26.1 đến người dùng toàn cầu. Nếu như&nbsp;</span><a href=\"https://tinhte.vn/tag/ios-26\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"background-color: initial; color: rgb(7, 104, 234);\">iOS 26</a><span style=\"background-color: initial; color: inherit;\">&nbsp;là một cuộc lột xác về mặt giao diện với hiệu ứng Liquid Glass, thì&nbsp;</span><a href=\"https://tinhte.vn/tag/ios\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"background-color: initial; color: rgb(7, 104, 234);\">iOS</a><span style=\"background-color: initial; color: inherit;\">&nbsp;26.1 lại là một bản cập nhật mang tính hoàn thiện, tập trung vào việc lắng nghe phản hồi từ cộng đồng, tinh chỉnh trải nghiệm, và quan trọng nhất, AI Apple đã có tiếng Việt.</span></p><p><br></p><p><a href=\"https://tinhte.vn/thread/thu-nhanh-apple-intelligence-tieng-viet-cam-on-apple-minh-da-cho-dieu-nay-hon-mot-nam-qua.4058827/\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"background-color: initial; color: inherit;\"><img src=\"https://imgproxy7.tinhte.vn/NUfJH046YahZ_HW-22UTlJgIvTlNhrymgIa0jOut2hs/rs:fill:480:300:0/plain/https://photo2.tinhte.vn/data/attachment-files/2025/09/8844754_overr_neia.jpg\" height=\"300\" width=\"480\"></a></p><h2><a href=\"https://tinhte.vn/thread/thu-nhanh-apple-intelligence-tieng-viet-cam-on-apple-minh-da-cho-dieu-nay-hon-mot-nam-qua.4058827/\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"color: rgb(20, 20, 20);\"><strong>Thử nhanh Apple Intelligence tiếng Việt: Cảm ơn Apple, mình đã chờ điều này hơn một năm qua</strong></a></h2><p><a href=\"https://tinhte.vn/thread/thu-nhanh-apple-intelligence-tieng-viet-cam-on-apple-minh-da-cho-dieu-nay-hon-mot-nam-qua.4058827/\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"color: rgb(20, 20, 20);\">Bà con ơi, làng nước ơi, Apple AI có tiếng Việt rồi. Đây là một điều mình đã mong chờ trong hơn 1 năm qua, Siri tiếng Việt ừ cũng thường nhưng Apple Intelligence tiếng Việt lại là một chuyện khác, mới trải nghiệm sơ sơ là thấy đã rồi. Để xài AI...</a></p><p><a href=\"https://tinhte.vn/thread/thu-nhanh-apple-intelligence-tieng-viet-cam-on-apple-minh-da-cho-dieu-nay-hon-mot-nam-qua.4058827/\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"color: rgb(20, 20, 20); background-color: initial;\">&nbsp;tinhte.vn</a></p><p><br></p><p><br></p><h2><strong style=\"background-color: initial; color: inherit;\">Apple Intelligence chính thức hỗ trợ Tiếng Việt</strong></h2><p><br></p><p><span style=\"background-color: initial; color: inherit;\">Đây chắc chắn là nâng cấp quan trọng và được mong chờ nhất đối với người dùng Việt Nam trong bản cập nhật lần này. Nền tảng trí tuệ nhân tạo của Apple giờ đây đã có thể hiểu và tương tác hoàn toàn bằng tiếng Việt, giúp anh em trải nghiệm nhiều tính năng mới mà trước đây chúng ta chỉ có thể trải nghiệm bằng tiếng Anh.</span></p><p><br></p><p><span style=\"background-color: initial; color: inherit;\"><img src=\"https://photo2.tinhte.vn/data/attachment-files/2025/11/8885130_8844754-overr-neia.jpg\" alt=\"8844754-overr-neia.jpg\"></span></p><p><br></p><p>Đầu tiên phải kể đến Writing Tools (Công cụ Viết). Tính năng này giờ đây đã có thể sử dụng hoàn toàn bằng tiếng Việt trên hầu hết mọi ứng dụng. Ae có thể dễ dàng yêu cầu AI tóm tắt một đoạn văn bản dài, viết lại theo một phong cách khác, sửa lỗi chính tả hay thậm chí chuyển đổi một đoạn so sánh thành dạng bảng biểu để dễ theo dõi hơn. Việc tích hợp sâu ChatGPT cũng cho phép người dùng đưa ra các yêu cầu phức tạp hơn bằng chính ngôn ngữ mẹ đẻ.</p><p><br></p><p><span style=\"background-color: initial; color: inherit;\"><img src=\"https://photo2.tinhte.vn/data/attachment-files/2025/11/8885131_8844747-piewjfipqwejf-2.jpg\" alt=\"8844747-piewjfipqwejf-2.jpg\"></span></p><p><br></p><p><span style=\"background-color: initial; color: inherit;\">Trong ứng dụng Mail, AI có thể tự động đọc và tóm tắt nội dung các email dài bằng tiếng Việt một cách ngọt sớt, đồng thời đề xuất các câu trả lời thông minh phù hợp với ngữ cảnh. Cùng với khả năng lọc và phân loại mail tự động, việc quản lý email hàng ngày đã trở nên đơn giản và hiệu quả hơn rất nhiều.</span></p><p><br></p><p><span style=\"background-color: initial; color: inherit;\"><img src=\"https://photo2.tinhte.vn/data/attachment-files/2025/11/8885132_8844736-4.jpg\" alt=\"8844736-4.jpg\"></span></p><p><br></p><p><span style=\"background-color: initial; color: inherit;\">Siri thế hệ mới cũng đã thông minh hơn khi giao tiếp bằng tiếng Việt. Nó có thể hiểu các câu lệnh phức tạp và tự nhiên hơn, thực hiện các tác vụ liền mạch như \"nhắn tin cho A rủ đi ăn phở, uống trà sữa\" hay thậm chí là yêu cầu ChatGPT soạn một đoạn văn bản rồi gửi đi.</span></p><p><br></p><p><span style=\"background-color: initial; color: inherit;\"><img src=\"https://photo2.tinhte.vn/data/attachment-files/2025/11/8885133_8844740-7-2.jpg\" alt=\"8844740-7-2.jpg\"></span></p><p><br></p><p><span style=\"background-color: initial; color: inherit;\">Cuối cùng, Visual Intelligence cũng đã được Việt hóa. Khi ae hướng camera vào một địa điểm hay một đoạn văn bản, tính năng này có thể nhận diện và cung cấp các thông tin liên quan bằng tiếng Việt. Các tính năng sáng tạo như Image Playground và Genmoji cũng đã chấp nhận các câu lệnh mô tả bằng tiếng Việt, giúp cá nhân hóa trải nghiệm một cách sâu sắc hơn nhưng mấy cái đó thấy không vui nên mình không xài.</span></p><p><br></p><p><span style=\"background-color: initial; color: inherit;\"><img src=\"https://photo2.tinhte.vn/data/attachment-files/2025/11/8885134_8844742-11-2.jpg\" alt=\"8844742-11-2.jpg\"></span></p><p><br></p><h2><strong style=\"background-color: initial; color: inherit;\">Tùy chỉnh giao diện Liquid Glass</strong></h2><p><br></p><p><span style=\"background-color: initial; color: inherit;\">Lắng nghe phản hồi từ những người dùng cho rằng giao diện Liquid Glass mặc định đôi khi hơi khó đọc do độ tương phản thấp, Apple đã bổ sung một tùy chọn tùy chỉnh quan trọng trong iOS 26.1. Trong mục Cài đặt &gt; Màn hình &amp; Độ sáng, người dùng giờ đây có thể chuyển đổi giữa hai chế độ: Clear và Tinted.</span></p><p><br></p><p><span style=\"background-color: initial; color: inherit;\"><img src=\"https://photo2.tinhte.vn/data/attachment-files/2025/11/8885135_tat-liquid-glass-trong-ban-cap-nhat-ios-26-1-8.jpg\" alt=\"tat-liquid-glass-trong-ban-cap-nhat-ios-26-1-8.jpg\"></span></p><p><br></p><p><span style=\"background-color: initial; color: inherit;\">Chế độ Clear chính là giao diện Liquid Glass mặc định với các thành phần có độ trong mờ cao, cho phép nhìn thấy rõ hình nền phía sau. Trong khi đó, chế độ Tinted sẽ tăng độ mờ đục và thêm độ tương phản cho các yếu tố giao diện như nút bấm, thanh menu, giúp chúng trở nên nổi bật và dễ đọc hơn. Sự thay đổi này được áp dụng trên toàn bộ hệ điều hành, từ các ứng dụng cho đến thông báo trên Màn hình khóa.</span></p><p><br></p><h2><strong style=\"background-color: initial; color: inherit;\">iPadOS 26.1: Slide Over chính thức trở lại, hoạt động song song với đa nhiệm cửa sổ</strong></h2><p><br></p><p><span style=\"background-color: initial; color: inherit;\">Đây là một tin cực vui cho những người dùng iPad. Tính năng đa nhiệm Slide Over, vốn đã bị tạm thời loại bỏ trên iPadOS 26 để nhường chỗ cho hệ thống cửa sổ mới, đã chính thức được Apple mang trở lại, mình thích cái này hơn cái hệ thống cửa sổ mới. Mình thực sự đã quen với việc truy cập nhanh một ứng dụng phụ mà không làm gián đoạn công việc chính, Slide Over làm được chuyện đó.</span></p><p><br></p><p><span style=\"background-color: initial; color: inherit;\"><img src=\"https://photo2.tinhte.vn/data/attachment-files/2025/11/8885136_maxresdefault-4.jpg\" alt=\"maxresdefault-4.jpg\"></span></p><p><br></p><p>Giờ đây, Slide Over sẽ hoạt động song song và đóng vai trò bổ trợ cho hệ thống cửa sổ. Điều này có nghĩa là ae có thể mở nhiều cửa sổ ứng dụng trên màn hình, đồng thời vẫn có thể vuốt từ cạnh phải để truy cập nhanh một ứng dụng đang chạy ở chế độ Slide Over.</p><p><br></p><p><span style=\"background-color: initial; color: inherit;\"><img src=\"https://photo2.tinhte.vn/data/attachment-files/2025/11/8885137_8859365-ipados-26-1-slide-over.jpg\" alt=\"8859365-ipados-26-1-slide-over.jpg\"></span></p><p><br></p><p><span style=\"background-color: initial; color: inherit;\">Để kích hoạt, người dùng chỉ cần nhấn vào nút điều khiển cửa sổ và chọn Enter Slide Over. Dù ở phiên bản hiện tại, người dùng chỉ có thể sử dụng một ứng dụng Slide Over tại một thời điểm, nhưng sự trở lại này đã cho thấy Apple đang tích cực lắng nghe và tìm ra điểm cân bằng tối ưu cho trải nghiệm đa nhiệm trên iPad.</span></p><p><br></p><h2><strong style=\"background-color: initial; color: inherit;\">Báo thức và Hẹn giờ: Thao tác \"Trượt để tắt\" thay cho nút bấm</strong></h2><p><br></p><p><span style=\"background-color: initial; color: inherit;\">Một thay đổi nhỏ nhưng cực kỳ hữu ích và mình thấy được nhiều người dùng hoan nghênh chính là cách tương tác mới với báo thức trên Màn hình Khóa. Apple đã thay thế nút Stop bằng một thanh trượt Slide to Stop, trong khi nút Snooze vẫn giữ nguyên dạng nhấn.</span></p><p><br></p><p><span style=\"background-color: initial; color: inherit;\"><img src=\"https://photo2.tinhte.vn/data/attachment-files/2025/11/8885138_8859361-ios-26-1-slide-to-stop.jpg\" alt=\"8859361-ios-26-1-slide-to-stop.jpg\"></span></p><p><br></p><p><span style=\"background-color: initial; color: inherit;\">Sự thay đổi này giải quyết triệt để một vấn đề mà rất nhiều người gặp phải vào mỗi buổi sáng: vô tình nhấn nhầm nút Dừng thay vì Báo lại trong lúc còn ngái ngủ, đặc biệt là những người ngủ xấu như&nbsp;</span><a href=\"https://tinhte.vn/profile/nha-cua-cao.1418508/\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"background-color: initial; color: rgb(7, 104, 234);\">@Nhà Của Cáo</a><span style=\"background-color: initial; color: inherit;\">.</span></p><p><br></p><p><span style=\"background-color: initial; color: inherit;\">Giờ đây, để tắt hoàn toàn báo thức, người dùng sẽ cần một thao tác trượt có chủ đích hơn, giảm thiểu đáng kể khả năng tắt nhầm. Thay đổi này cũng được áp dụng tương tự cho tính năng Hẹn giờ.</span></p><p><br></p><h2><strong style=\"background-color: initial; color: inherit;\">Nâng cấp toàn diện cho CarPlay: Giao diện mới, Widget, Live Activities và AirPlay</strong></h2><p><br></p><p><span style=\"background-color: initial; color: inherit;\">CarPlay có thể xem là nền tảng nhận được nhiều nâng cấp nhất trên iOS 26.1. Toàn bộ giao diện giờ đây được áp dụng hiệu ứng Liquid Glass, mang lại một vẻ ngoài đồng bộ và hiện đại. Người dùng có thể trả lời tin nhắn bằng các Tapback, xem các cuộc hội thoại đã ghim và nhận thông báo cuộc gọi trong một giao diện nhỏ gọn hơn để không che mất bản đồ.</span></p><p><br></p><p><span style=\"background-color: initial; color: inherit;\"><img src=\"https://photo2.tinhte.vn/data/attachment-files/2025/11/8885139_CarPlay-Messages-Tapbacks.jpg\" alt=\"CarPlay-Messages-Tapbacks.jpg\"></span></p><p><br></p><p><span style=\"background-color: initial; color: inherit;\">Hai bổ sung lớn nhất là việc đưa Live Activities và Widget lên CarPlay. Màn hình Dashboard giờ đây có thể hiển thị các Live Activities để theo dõi thông tin thời gian thực, trong khi một màn hình widget riêng cho phép truy cập nhanh vào lịch, điều khiển thiết bị HomeKit.</span></p><p><br></p><p><span style=\"background-color: initial; color: inherit;\"><img src=\"https://photo2.tinhte.vn/data/attachment-files/2025/11/8885140_64001-133195-Live-Activity-in-CarPlay-xl.jpg\" alt=\"64001-133195-Live-Activity-in-CarPlay-xl.jpg\"></span></p><p><br></p><p><span style=\"background-color: initial; color: inherit;\">Đặc biệt, iOS 26.1 còn mang tính năng AirPlay lên CarPlay, cho phép truyền phát video không dây từ&nbsp;</span><a href=\"https://tinhte.vn/tag/iphone\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"background-color: initial; color: rgb(7, 104, 234);\">iPhone</a><span style=\"background-color: initial; color: inherit;\">&nbsp;lên màn hình của xe khi đang đỗ, một tính năng rất được mong chờ.</span></p><p><br></p><h2><strong style=\"background-color: initial; color: inherit;\">Các tinh chỉnh nhỏ nhưng đáng giá khác</strong></h2><p><br></p><p><span style=\"background-color: initial; color: inherit;\">Bên cạnh những thay đổi lớn, iOS 26.1 còn mang đến hàng loạt các cải tiến nhỏ trên toàn hệ thống. Trong ứng dụng Cài đặt, toàn bộ các tiêu đề mục như Cài đặt chung, Bluetooth, Wi-Fi... giờ đây đã được căn lề trái đồng bộ để tạo sự nhất quán. Hiệu ứng khúc xạ ánh sáng của Liquid Glass xung quanh các biểu tượng ứng dụng cũng được làm cho tinh tế và nhẹ nhàng hơn.</span></p><p><br></p><p><span style=\"background-color: initial; color: inherit;\"><img src=\"https://photo2.tinhte.vn/data/attachment-files/2025/11/8885141_8859363-ios-26-1-left-aligned-settings.jpg\" alt=\"8859363-ios-26-1-left-aligned-settings.jpg\"></span></p><p><br></p><p><span style=\"background-color: initial; color: inherit;\">Ứng dụng Apple Music có thêm cử chỉ vuốt mới để chuyển bài hát, ae chỉ cần muốn thanh phat nhạc là dược. Trên Apple Music, tính năng Crossfade cũ đã được thay thế bằng AutoMix, giúp tự động tạo ra các đoạn chuyển tiếp giữa các bài hát, riêng mình thì thấy tính năng này hơi xàm. À à, thông qua bản cập nhật này Airpods cũng được cập nhật tính năng dịch trực tiếp.</span></p><p><br></p><p><span style=\"background-color: initial; color: inherit;\"><img src=\"https://photo2.tinhte.vn/data/attachment-files/2025/11/8885142_apple-music-automix-ios-26.jpg\" alt=\"apple-music-automix-ios-26.jpg\"></span></p><p><br></p><h2><strong style=\"background-color: initial; color: inherit;\">Kết luận: Một bản cập nhật đáng nâng cấp</strong></h2><p><br></p><p><span style=\"background-color: initial; color: inherit;\">iOS 26.1 không phải là một cuộc cách mạng hay gì đó quá ghê gớm. Nó đã biến những ý tưởng của iOS 26 trở nên hoàn thiện, thực tế và thân thiện hơn với người dùng. Apple mang trở lại các tính năng được cộng đồng yêu thích như Slide Over, hay giải quyết các vấn đề nhỏ nhưng gây khó chịu như nút tắt báo thức.</span></p><p><br></p><p><span style=\"background-color: initial; color: inherit;\"><img src=\"https://photo2.tinhte.vn/data/attachment-files/2025/11/8885143_8860852-tinhte-tu-review-ios-26-3.jpg\" alt=\"8860852-tinhte-tu-review-ios-26-3.jpg\"></span></p><p><br></p><p><span style=\"background-color: initial; color: inherit;\">Trên hết, việc Apple Intelligence chính thức hỗ trợ tiếng Việt đã mở ra một điều gì đó hay ho cho người dùng iPhone tại Việt Nam. Dù vẫn còn một vài tính năng cần được cải thiện, nhưng những gì iOS 26.1 mang lại ở thời điểm hiện tại đã là quá đủ để nói đây là một bản cập nhật rất đáng giá, giúp trải nghiệm iOS trở nên trọn vẹn hơn, mình đang chạy beta thấy vẫn ngon lành cành đào...</span></p><p>ẩm mới...</p>', 'Tóm tắt về sản phẩm mới', 'Admin', 'Tin tức', 'PUBLISHED', 'f40e0038-70de-4459-8d39-13dfaefbd2ce_0b021a98-99b1-458f-add3-6464701ce854_giay-adidas-adifom-superstar-white-black-10-800x650.jpg', 176, '2025-11-04 18:00:12', '2025-11-04 11:30:34', '2025-11-04 18:00:33', NULL),
(2, 'Hướng dẫn sử dụng', 'Hướng dẫn chi tiết cách sử dụng sản phẩm...', 'Tóm tắt hướng dẫn', 'Admin', 'Hướng dẫn', 'ARCHIVED', '0a348d98-7cb3-4f96-9530-9b80f9c859f3_giay-mlb-chunky-liner-mid-denim-boston-red-sox-dblue-auth-5-300x300.jpg.jpg', 134, '2025-11-04 11:30:34', '2025-11-04 11:30:34', '2025-11-04 17:59:55', NULL),
(3, 'Chương trình khuyến mãi', 'Thông tin về chương trình khuyến mãi...', 'Tóm tắt khuyến mãi', 'Admin', 'Khuyến mãi', 'ARCHIVED', 'news3.jpg', 200, '2025-11-04 11:30:34', '2025-11-04 11:30:34', '2025-11-04 17:59:54', NULL),
(5, 'Ra mắt Khóa vân tay Samsung SHP-DH538', '<h2><strong style=\"background-color: initial;\"><em>Khóa vân tay Samsung SHP-DH538:</em></strong></h2><p>- Mở bằng: vân tay, mã số, chìa cơ (dự phòng)</p><h4><strong style=\"background-color: initial; color: rgb(204, 0, 0);\"><em>- Giá: 5.490.000 đồng</em></strong></h4><iframe class=\"ql-video\" frameborder=\"0\" allowfullscreen=\"true\" src=\"https://www.youtube.com/embed/4ldAlQJer5w?showinfo=0\"></iframe><p class=\"ql-align-center\"><br></p><p><strong style=\"color: rgb(119, 119, 119);\">1. Chức năng cơ bản</strong></p><p>Khóa cửa điện tử Samsung SHP DH538 với thiết kế màu đỏ đồng phù hợp với các căn hộ sang trọng. Công nghệ quét vân tay quang học và mã số ngẫu nhiên, cùng hệ thống cảnh báo đột nhập sẽ đem lại sự an toàn và tiện lợi đến căn hộ của bạn.</p><p><br></p><p><span style=\"background-color: initial; color: rgb(0, 0, 238);\"><img src=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEitN1ag8THMYP6RRfGExIy4WoW215YjBgcVtmZKXS0naO-aen-OLqV6EdzrBLHgH32co26LxCr-pmaRPXV290CI7uL46Z1dcVZOZSzOlK_qiMl26AbCdnsUPha_V3roELfwKVysRErqigeB/w640-h212/Screenshot-365-1024x340.png\" height=\"212\" width=\"640\"></span></p><p><br></p><p class=\"ql-align-center\"><a href=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhyqgdga_-zcWFx6gF5igT7FBpefisGLWYKv4PHxkkXU5M4OG64dlEEf_H0qvOucwXmBUaB1-50LY2vFWbcK5qazfIO1YO98vG9cMiNnSpX7Vi2oXMJhAXYRr2Pi44LmSp9yFmVNTi2WNgD/s1024/Screenshot-362-2-1024x496-1.jpg\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"background-color: initial; color: rgb(191, 30, 45);\"><img src=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhyqgdga_-zcWFx6gF5igT7FBpefisGLWYKv4PHxkkXU5M4OG64dlEEf_H0qvOucwXmBUaB1-50LY2vFWbcK5qazfIO1YO98vG9cMiNnSpX7Vi2oXMJhAXYRr2Pi44LmSp9yFmVNTi2WNgD/w640-h310/Screenshot-362-2-1024x496-1.jpg\" height=\"310\" width=\"640\"></a></p><p><br></p><p class=\"ql-align-center\"><a href=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEh9WfkszxYZICvwC_HcVI2n3nxg9fQ1gr2tyTtM3wX45onDY_fo6nz5Ez83t47N9f1laxixaBYxJQaltsL25PUDIixk7St5jHFFyM0NRnjTJNEEiNJB4G_YqHvphGrkqvQ52mFb11g12FRn/s1024/Screenshot-366-3-1024x587.png\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"background-color: initial; color: rgb(191, 30, 45);\"><img src=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEh9WfkszxYZICvwC_HcVI2n3nxg9fQ1gr2tyTtM3wX45onDY_fo6nz5Ez83t47N9f1laxixaBYxJQaltsL25PUDIixk7St5jHFFyM0NRnjTJNEEiNJB4G_YqHvphGrkqvQ52mFb11g12FRn/w640-h366/Screenshot-366-3-1024x587.png\" height=\"366\" width=\"640\"></a></p><p><br></p><p class=\"ql-align-center\"><a href=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgMTvZvsaQXjXVTTqpimFXvMsx0Rz9V1U-N2c3ymxYWx2mp5qDGTLsNHC-DrRjznpDuYTDNPTBI8SOfHh9hPwI4CFYCxq9QZY-wUGZ_OCLehXWYbRtpEFn4TNgBTtvAKX1OdRH4Y51HwBRt/s1024/Screenshot-368-2-1024x620.png\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"background-color: initial; color: rgb(191, 30, 45);\"><img src=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgMTvZvsaQXjXVTTqpimFXvMsx0Rz9V1U-N2c3ymxYWx2mp5qDGTLsNHC-DrRjznpDuYTDNPTBI8SOfHh9hPwI4CFYCxq9QZY-wUGZ_OCLehXWYbRtpEFn4TNgBTtvAKX1OdRH4Y51HwBRt/w640-h388/Screenshot-368-2-1024x620.png\" height=\"388\" width=\"640\"></a></p><p><br></p><p class=\"ql-align-center\"><a href=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjDXBiy2-BavdmqssMDSnpFlAAvHdVvwsH0AnOUd06mmiARCHuIZrhuP-3ajV4S_iPnxr4hasItAVRCU7IQwXQQpisbPZfFDjehnYk2LKddUp7fW87qhaocfqlUJqehR1oWjqqmVN3Xd-Za/s1024/Screenshot-370-2-1024x577-1.jpg\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"background-color: initial; color: rgb(191, 30, 45);\"><img src=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjDXBiy2-BavdmqssMDSnpFlAAvHdVvwsH0AnOUd06mmiARCHuIZrhuP-3ajV4S_iPnxr4hasItAVRCU7IQwXQQpisbPZfFDjehnYk2LKddUp7fW87qhaocfqlUJqehR1oWjqqmVN3Xd-Za/w640-h360/Screenshot-370-2-1024x577-1.jpg\" height=\"360\" width=\"640\"></a></p><p><br></p><p class=\"ql-align-center\"><a href=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhCAKCrUustusR9ei3Dkafz-uMnbDkpt2yf-RGTN3TZmgcM5Ma8OR3rv5BDh0iX72R4ff886tGGrfnIVuti1ud_5uMP1_mo1uwzsQ1VOyIT1nBCCAQIk4RVeWgUaVRATAfkGZpK6zN0cspa/s510/Screenshot-372-1-510x289.png\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"background-color: initial; color: rgb(191, 30, 45);\"><img src=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhCAKCrUustusR9ei3Dkafz-uMnbDkpt2yf-RGTN3TZmgcM5Ma8OR3rv5BDh0iX72R4ff886tGGrfnIVuti1ud_5uMP1_mo1uwzsQ1VOyIT1nBCCAQIk4RVeWgUaVRATAfkGZpK6zN0cspa/w640-h362/Screenshot-372-1-510x289.png\" height=\"362\" width=\"640\"></a></p><p><br></p><p class=\"ql-align-center\"><a href=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEg7aGYa-7BxFJ_i3xbGuG5tDPs2Fg9kuNChMiAXvvfWg6VNcX7ijXzzX7Z3ZShGir2RAvcjqSnCdEtF23hIQhePo32CE3DU3hI7rA8aNtf4ZFq-hzKSEUCqf7oWczpE-qBOxWpJAipZbmmp/s1024/Screenshot-372-2-1024x580.png\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"background-color: initial; color: rgb(191, 30, 45);\"><img src=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEg7aGYa-7BxFJ_i3xbGuG5tDPs2Fg9kuNChMiAXvvfWg6VNcX7ijXzzX7Z3ZShGir2RAvcjqSnCdEtF23hIQhePo32CE3DU3hI7rA8aNtf4ZFq-hzKSEUCqf7oWczpE-qBOxWpJAipZbmmp/w640-h362/Screenshot-372-2-1024x580.png\" height=\"362\" width=\"640\"></a></p><p><br></p><p class=\"ql-align-center\"><a href=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgP9DpsDZpw9k5BhdFCFPDXzo9azB3feYl4ML5WZl8ooLoyNHeNPySwcEY_OWrcJdwrsjG6mPW_Eli1Pc7wdDqzFOIBUSJu04fQScdWmUqCpagcB-6zlRc9SCLnpQownCipdDP0a7wWAJGa/s1024/Screenshot-374-2-1024x591.png\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"background-color: initial; color: rgb(191, 30, 45);\"><img src=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgP9DpsDZpw9k5BhdFCFPDXzo9azB3feYl4ML5WZl8ooLoyNHeNPySwcEY_OWrcJdwrsjG6mPW_Eli1Pc7wdDqzFOIBUSJu04fQScdWmUqCpagcB-6zlRc9SCLnpQownCipdDP0a7wWAJGa/w640-h370/Screenshot-374-2-1024x591.png\" height=\"370\" width=\"640\"></a></p><p><br></p><p class=\"ql-align-center\"><a href=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEh0fNo5Qbq5wt4Ovq1TBq_9gk0QxqUrFgO1MbZLsqO73_N-ZLr5Z6rBUutmyr0xOivrNv_Q9SoAOCDLSLmygysVuGXor9p-1D8h91EVKEKNL3dH20enL4F4t8Lyj2djR94GSh3NzeEOTZWS/s1024/Screenshot-376-2-1024x552.png\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"background-color: initial; color: rgb(191, 30, 45);\"><img src=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEh0fNo5Qbq5wt4Ovq1TBq_9gk0QxqUrFgO1MbZLsqO73_N-ZLr5Z6rBUutmyr0xOivrNv_Q9SoAOCDLSLmygysVuGXor9p-1D8h91EVKEKNL3dH20enL4F4t8Lyj2djR94GSh3NzeEOTZWS/w640-h344/Screenshot-376-2-1024x552.png\" height=\"344\" width=\"640\"></a></p><p><br></p><p class=\"ql-align-center\"><a href=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEh82Bf9-6POfLFXfOr1E2rkmbN-pJ5hXLnsl0fhnAPkWsH8FVxT-kr7zBP-d0qvxct_SzbW2eLpDQKqSwSvG2L2m93zVZbjE9c7vu67HNIMqT0yhYhAZflMrGItf7-0irZTlSwXK-cGWBno/s1024/Screenshot-380-2-1024x580.png\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"background-color: initial; color: rgb(191, 30, 45);\"><img src=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEh82Bf9-6POfLFXfOr1E2rkmbN-pJ5hXLnsl0fhnAPkWsH8FVxT-kr7zBP-d0qvxct_SzbW2eLpDQKqSwSvG2L2m93zVZbjE9c7vu67HNIMqT0yhYhAZflMrGItf7-0irZTlSwXK-cGWBno/w640-h362/Screenshot-380-2-1024x580.png\" height=\"362\" width=\"640\"></a></p><p><br></p><p class=\"ql-align-center\"><a href=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhdu4zX0mrI7mdyJNcHkFC4QhtztqNiNd04qLX6cXo2eTsHW5XwAkZS3kPP0ocSg01dSQgSnoNXxs40SJ9jNQDT0mazvGXOQSNkbZE3IiKcjHmBEhIoKpPGfi0mSpsWFRNu5Et-Ismlbves/s1024/Screenshot-385-2-1024x587.png\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"background-color: initial; color: rgb(191, 30, 45);\"><img src=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhdu4zX0mrI7mdyJNcHkFC4QhtztqNiNd04qLX6cXo2eTsHW5XwAkZS3kPP0ocSg01dSQgSnoNXxs40SJ9jNQDT0mazvGXOQSNkbZE3IiKcjHmBEhIoKpPGfi0mSpsWFRNu5Et-Ismlbves/w640-h366/Screenshot-385-2-1024x587.png\" height=\"366\" width=\"640\"></a></p><p><br></p><p class=\"ql-align-center\"><a href=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhFYFoEpvedT4hh3XkWGNOs6HyxbOPS5dk-RcMHQhTFKIPYm25nskOjUPDmx1IcoAFKIjnpb3YrN27LVoCU10kQFpu_4e7BW6zzDzudC-4GDpDtWZMEUav1h0SCasTsND40LqQAYAlloL_w/s1024/Screenshot-386-2-1024x536.png\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"background-color: initial; color: rgb(191, 30, 45);\"><img src=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhFYFoEpvedT4hh3XkWGNOs6HyxbOPS5dk-RcMHQhTFKIPYm25nskOjUPDmx1IcoAFKIjnpb3YrN27LVoCU10kQFpu_4e7BW6zzDzudC-4GDpDtWZMEUav1h0SCasTsND40LqQAYAlloL_w/w640-h336/Screenshot-386-2-1024x536.png\" height=\"336\" width=\"640\"></a></p><p><br></p><p><strong style=\"background-color: initial;\">2. Thông số kĩ thuật&nbsp;khóa Samsung&nbsp;SHP-DH538</strong></p><p><strong style=\"background-color: initial;\">Vân tay và mã số</strong>Mã số: 4~12 ký tự điện tử</p><p>Công nghệ cảm ứng điện dung</p><p><strong style=\"background-color: initial;\">Bộ nhớ vân tay tối đa</strong>100<strong style=\"background-color: initial;\">Kích thướcThân ngoài</strong>81.8(W) X 320(H) X 66.8(D)mm<strong style=\"background-color: initial;\">Thân trong</strong>79(W) X 290(H) X 80.3(D)mm<strong style=\"background-color: initial;\">Độ dày cửa thích hợp</strong>40~80mm<strong style=\"background-color: initial;\">Nguồn</strong>8 viên pin AA Alkaline Batteries<strong style=\"background-color: initial;\">Thời gian cần thay pin</strong>Xấp xỉ 12 tháng<strong style=\"background-color: initial;\">Màu</strong>Đen, đỏ đồng</p>', '- Mở bằng: vân tay, mã số, chìa cơ (dự phòng)\n\n- Giá: 5.490.000 đồng', NULL, 'Tin tức', 'PUBLISHED', '38a51683-a41c-4740-a173-a8ceac011b7a_SHS-P718_3-4.png', 15, '2025-11-04 18:00:04', '2025-11-04 13:50:37', '2025-11-04 18:00:04', NULL),
(6, 'Các công nghệ Khoá cửa mới ứng dụng Trí tuệ nhân tạo', '<h1><br></h1><h2>Mở đầu</h2><p>Trong kỷ nguyên số hóa không ngừng, sự tiến bộ của <strong>công nghệ</strong> đã và đang định hình lại mọi khía cạnh của cuộc sống, từ cách chúng ta giao tiếp đến cách chúng ta bảo vệ không gian riêng tư. Đặc biệt, lĩnh vực an ninh gia đình đã chứng kiến một cuộc cách mạng mạnh mẽ với sự xuất hiện của các thiết bị <strong>khóa điện tử</strong> và <strong>smart lock</strong>. Tuy nhiên, nếu chỉ dừng lại ở việc mở khóa bằng vân tay, mã số hay thẻ từ thì đó mới chỉ là bước khởi đầu. Ngày nay, với sự tích hợp của <strong>Trí tuệ nhân tạo (AI)</strong>, các hệ thống khóa cửa đã vượt xa giới hạn thông thường, mang đến một cấp độ <strong>bảo mật</strong>, tiện lợi và thông minh hoàn toàn mới.</p><p>Bài viết này sẽ đi sâu vào khám phá cách AI đang cách mạng hóa ngành khóa cửa, từ việc tăng cường khả năng nhận diện sinh trắc học, phân tích hành vi người dùng, đến việc tích hợp liền mạch vào hệ sinh thái nhà thông minh. Chúng ta cũng sẽ tìm hiểu những lợi ích vượt trội mà công nghệ này mang lại, cũng như những thách thức cần đối mặt và những lời khuyên hữu ích để người dùng có thể đưa ra lựa chọn sáng suốt nhất cho ngôi nhà của mình.</p><p><br></p><h2>Nội dung chính</h2><h3>1. AI nâng tầm bảo mật và tiện ích của Khóa thông minh</h3><p>Ban đầu, các loại <strong>khóa điện tử</strong> và <strong>smart lock</strong> đã gây ấn tượng với khả năng mở khóa không cần chìa vật lý, điều khiển từ xa và ghi nhận lịch sử ra vào. Nhưng khi AI được đưa vào, chúng không chỉ còn là thiết bị thực hiện lệnh đơn thuần mà đã trở thành \"người gác cổng\" thông minh, có khả năng học hỏi, thích nghi và thậm chí là dự đoán. AI giúp nâng cao đáng kể độ chính xác và tốc độ của các phương thức xác thực sinh trắc học như <strong>nhận diện vân tay</strong> và <strong>nhận diện khuôn mặt</strong>. Các thuật toán AI có thể phân tích hàng triệu điểm dữ liệu từ vân tay hay đặc điểm khuôn mặt, giúp phân biệt giữa người thật và các hành vi giả mạo một cách hiệu quả hơn bao giờ hết, ngay cả trong điều kiện ánh sáng yếu hoặc khi có sự thay đổi nhỏ trên khuôn mặt.</p><p>Hơn nữa, AI còn cho phép khóa cửa học hỏi các thói quen và lịch trình của người dùng. Ví dụ, nếu bạn thường xuyên về nhà vào một giờ cố định, khóa có thể tự động chuẩn bị mở khóa khi bạn đến gần. Khả năng này không chỉ tăng cường tiện ích mà còn là nền tảng cho các hệ thống an ninh chủ động hơn. Với <strong>xu hướng công nghệ IoT</strong> phát triển mạnh mẽ, các <strong>khóa thông minh AI</strong> trở thành một mắt xích quan trọng trong hệ sinh thái <strong>smart home</strong>, kết nối với các thiết bị khác như camera an ninh, đèn chiếu sáng, và hệ thống báo động để tạo ra một mạng lưới an ninh đồng bộ và thông minh.</p><h3>2. Các ứng dụng AI đột phá trong công nghệ khóa cửa</h3><p>Sự tích hợp của AI mang đến nhiều ứng dụng vượt trội, biến khóa cửa không chỉ là một thiết bị bảo vệ mà còn là một phần của hệ thống quản lý an ninh toàn diện:</p><ul><li><strong>Nhận diện sinh trắc học thông minh thích ứng:</strong> AI cho phép các cảm biến vân tay và camera nhận diện khuôn mặt \"học\" và thích nghi với sự thay đổi. Chẳng hạn, cảm biến vân tay có thể nhận diện chính xác ngay cả khi tay bạn hơi ướt, bẩn, hoặc có vết thương nhỏ. Công nghệ <strong>nhận diện khuôn mặt</strong> được hỗ trợ bởi AI có thể phân biệt người thật với hình ảnh hoặc mặt nạ 3D, thậm chí còn có khả năng nhận diện cảm xúc để phát hiện các hành vi đáng ngờ.</li><li><strong>Phân tích hành vi và phát hiện bất thường:</strong> Đây là một trong những ứng dụng mạnh mẽ nhất của AI. Khóa AI có thể theo dõi và học hỏi các mô hình truy cập thông thường của bạn và gia đình. Khi có bất kỳ hành vi nào lệch khỏi mô hình này (ví dụ: cố gắng mở khóa vào những thời điểm bất thường, số lần nhập sai mã PIN liên tục vượt quá mức cho phép), hệ thống sẽ tự động gửi cảnh báo đến điện thoại của bạn hoặc kích hoạt các biện pháp an ninh khác như bật còi báo động, ghi hình qua camera.</li><li><strong>Quản lý truy cập tự động và thông minh:</strong> AI tối ưu hóa việc cấp quyền truy cập. Thay vì phải cài đặt thủ công từng quyền cho từng người, AI có thể gợi ý hoặc tự động cấp quyền tạm thời dựa trên lịch trình đã định sẵn (ví dụ: cho nhân viên dọn dẹp, người giao hàng). Nó cũng có thể tự động khóa cửa khi phát hiện không có ai ở nhà, hoặc mở cửa khi bạn về mà không cần thao tác.</li><li><strong>Tích hợp sâu rộng với hệ sinh thái nhà thông minh:</strong> Với AI, khóa cửa trở thành trung tâm điều khiển an ninh. Khi bạn mở cửa, AI có thể ra lệnh cho đèn bật sáng, điều hòa khởi động và rèm cửa mở ra. Ngược lại, khi bạn khóa cửa đi ra ngoài, toàn bộ hệ thống sẽ chuyển sang chế độ an ninh, tắt các thiết bị điện không cần thiết và kích hoạt camera giám sát.</li></ul><h3>3. Lợi ích và những cân nhắc khi lựa chọn khóa cửa AI</h3><p>Việc ứng dụng AI vào khóa cửa mang lại những lợi ích vượt trội:</p><ul><li><strong>An ninh vượt trội:</strong> Khả năng phân tích và dự đoán của AI giúp phát hiện và ngăn chặn các mối đe dọa sớm hơn, hiệu quả hơn các hệ thống truyền thống.</li><li><strong>Tiện lợi tối đa:</strong> Tự động hóa quá trình khóa/mở, quản lý truy cập linh hoạt, giảm bớt gánh nặng về chìa khóa vật lý hay nhớ mã số.</li><li><strong>Trải nghiệm cá nhân hóa:</strong> Hệ thống học hỏi thói quen để cung cấp trải nghiệm mượt mà, phù hợp với từng thành viên gia đình.</li><li><strong>Tăng cường hiệu quả năng lượng:</strong> Kết hợp với các thiết bị smart home khác, AI có thể tối ưu hóa việc sử dụng năng lượng khi không có người ở nhà.</li></ul><p>Tuy nhiên, cũng có một số cân nhắc quan trọng:</p><ul><li><strong>Vấn đề quyền riêng tư và bảo mật dữ liệu:</strong> Khóa AI thu thập nhiều dữ liệu cá nhân (dữ liệu sinh trắc học, lịch sử ra vào). Điều quan trọng là phải chọn sản phẩm từ các nhà cung cấp uy tín, có chính sách bảo mật dữ liệu rõ ràng.</li><li><strong>Chi phí đầu tư ban đầu:</strong> Công nghệ AI thường đi kèm với chi phí cao hơn so với các loại khóa thông minh cơ bản.</li><li><strong>Phụ thuộc vào kết nối mạng và nguồn điện:</strong> Hầu hết các tính năng thông minh yêu cầu kết nối internet ổn định. Cần có giải pháp dự phòng nguồn điện để đảm bảo hoạt động liên tục khi mất điện.</li><li><strong>Rủi ro an ninh mạng:</strong> Như bất kỳ thiết bị IoT nào, khóa AI cũng có thể là mục tiêu của các cuộc tấn công mạng. Cần đảm bảo thiết bị được cập nhật phần mềm thường xuyên và có các lớp bảo mật vững chắc.</li></ul><blockquote><em>\"AI không chỉ là một tính năng bổ sung; nó là yếu tố cốt lõi thay đổi cách chúng ta tương tác với an ninh, biến khóa cửa từ một vật cản tĩnh thành một người bảo vệ chủ động và thông minh.\"</em></blockquote><h3>4. Tư vấn chọn mua và sử dụng khóa cửa AI hiệu quả</h3><p>Để tận dụng tối đa lợi ích của khóa cửa AI, người tiêu dùng cần lưu ý một số điểm sau:</p><ul><li><strong>Xác định nhu cầu:</strong> Đánh giá mức độ an ninh mong muốn, các tính năng cụ thể cần thiết (nhận diện khuôn mặt, vân tay, tích hợp smart home), và ngân sách của bạn.</li><li><strong>Nghiên cứu kỹ sản phẩm:</strong> Tìm hiểu về các công nghệ AI mà khóa sử dụng, độ tin cậy của thuật toán, và khả năng tương thích với các thiết bị smart home khác trong gia đình bạn.</li><li><strong>Ưu tiên các nhà sản xuất uy tín:</strong> Chọn những thương hiệu có tiếng trong lĩnh vực an ninh, cung cấp chính sách bảo hành rõ ràng và hỗ trợ kỹ thuật tốt.</li><li><strong>Kiểm tra các chứng nhận bảo mật:</strong> Đảm bảo khóa có các chứng nhận về an toàn dữ liệu và chống tấn công mạng từ các tổ chức uy tín.</li><li><strong>Thường xuyên cập nhật phần mềm (firmware):</strong> Các bản cập nhật không chỉ thêm tính năng mới mà còn vá lỗi bảo mật, nâng cao hiệu suất của AI.</li><li><strong>Thiết lập mật khẩu mạnh và sử dụng xác thực đa yếu tố (MFA):</strong> Nếu có, hãy kích hoạt MFA cho tài khoản quản lý khóa để tăng cường lớp bảo mật.</li><li><strong>Bảo vệ dữ liệu cá nhân:</strong> Hiểu rõ cách dữ liệu của bạn được thu thập và sử dụng. Đọc kỹ chính sách quyền riêng tư.</li><li><strong>Lên kế hoạch dự phòng:</strong> Đảm bảo có nguồn điện dự phòng (pin hoặc sạc khẩn cấp) và một phương pháp mở khóa cơ bản (chìa khóa vật lý, mã PIN) trong trường hợp khẩn cấp.</li></ul><h2>Kết luận</h2><p>Sự kết hợp giữa <strong>khóa điện tử</strong>, <strong>smart lock</strong> và <strong>Trí tuệ nhân tạo</strong> đang mở ra một kỷ nguyên mới cho <strong>an ninh gia đình</strong>. Khóa cửa không còn là một thiết bị đơn thuần để khóa và mở, mà đã trở thành một hệ thống bảo vệ thông minh, chủ động, có khả năng học hỏi và thích nghi. Mặc dù vẫn còn những thách thức về quyền riêng tư và an ninh mạng, nhưng tiềm năng mà AI mang lại là vô cùng to lớn, hứa hẹn một tương lai nơi ngôi nhà của chúng ta không chỉ an toàn hơn mà còn thông minh và tiện nghi hơn bao giờ hết.</p><p>Việc đầu tư vào một hệ thống khóa cửa AI thông minh là một quyết định đáng giá cho bất kỳ ai muốn nâng cấp an ninh và trải nghiệm sống trong ngôi nhà hiện đại. Hãy là người tiêu dùng thông thái, tìm hiểu kỹ lưỡng và chọn lựa sản phẩm phù hợp nhất để bảo vệ tổ ấm của mình.</p><p>```</p>', NULL, NULL, NULL, 'PUBLISHED', '85526858-1561-42f0-a38b-8ab16bb49dcc_SHS-2920_1.jpg', 3, '2025-11-04 17:32:50', '2025-11-04 17:32:50', '2025-11-04 17:53:21', NULL);

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
(92, 18, 'Truong Quang Lap', 'secroramot123@gmail.com', '0854768836', 'Mình Loc', 'àdasfadsfdsafsadfasdf', '2025-06-13 00:00:00', 'canceled', 29030000, 'Tiêu chuẩn', '2025-06-16', 'Thanh toán thẻ thành công', 1, NULL, 0, 'pi_3RZW4FRoKh7pvaZe1sbaN2MH', NULL, NULL);

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
(1, 'Khóa vân tay GATEMAN FINGUS (WF-20)', 6500000, 'WF20_1 3-4.jpg', 'Khóa vân tay GATEMAN WF-20 - Mở khóa bằng vân tay hoặc mật mã. Cài đặt 20 vân tay, 03 mã số.', '2024-02-16 16:46:58', '2025-06-13 06:34:32', 1, 30, 51),
(2, 'Khóa vân tay Samsung SHP-DH538', 5490000, 'DH538_co 3-4.jpg', 'Khóa vân tay Samsung SHP-DH538 - Mở bằng vân tay, mã số, chìa cơ dự phòng. Chống nước, thiết kế hiện đại.', '2024-02-17 07:35:46', '2025-11-04 15:43:33', 2, 20, 3),
(3, 'Khóa vân tay SamSung SHS P718', 8500000, 'SHS-P718_3-4.png', 'Khóa vân tay Samsung SHS P718 với công nghệ cảm biến vân tay tiên tiến, thiết kế hiện đại.', '2024-02-17 07:35:46', '2025-06-13 11:41:35', 2, 60, 8),
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
(5785, 'Mercedes GLE 350', 6990000000, '58760ad5-7ea7-4bc6-a8e6-4c02af90c8cf_images.jpg', 'ádasdasd', '2025-06-13 08:29:52', '2025-11-04 12:42:12', 5, 55, 1);

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
(1, 1, 1, '2025-06-13 12:00:00', '2025-11-04 11:30:34'),
(2, 1, 3, '2025-06-13 12:00:00', '2025-11-04 11:30:34'),
(3, 2, 1, '2025-06-13 12:00:00', '2025-11-04 11:30:34'),
(4, 2, 2, '2025-06-13 12:00:00', '2025-11-04 11:30:34');

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
(2, 1, '64baf7b5-635b-4a9e-aec7-03d0fedac82f_nike-air-force-1-low-replica-800x600.jpg'),
(3, 1, '6e7c3444-2475-4880-847d-e6754557316e_af1-full-white-like-auth-6-650x650.jpg'),
(125, 5784, '17b301fe-dbd0-4c8a-a990-5edef383e497_bsb004501__2__36b648ff5dfb4a0fbc909605f1dc7d53_grande.jpg'),
(126, 5785, '58760ad5-7ea7-4bc6-a8e6-4c02af90c8cf_images.jpg'),
(132, 1, '2af2e2f9-692c-4209-9b6b-c0ce1da22d87_Nike-Air-Jordan-1-Retro-Low-OG-SP-Travis-ScottT-8-300x300.jpg.jpg'),
(133, 1, 'ebbf7fd1-b659-4dab-bca3-33691e9d661d_Nike-Air-Jordan-1-Retro-Low-OG-SP-Travis-ScottT-8-300x300.jpg.jpg'),
(134, 1, 'bfbbf398-6f57-4b27-8f90-0c61c46be7e5_Nike-Air-Jordan-1-Retro-Low-OG-SP-Travis-ScottT-8-300x300.jpg.jpg'),
(135, 1, '1bc170c9-2706-4a4e-8992-875a05e15314_alexander-mcqueen-trang-got-den-sieu-cap-1-300x300.jpg.jpg');

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
(1, 47, 'sdfdsafsdfsdf', 'REFUNDED', 3030000.00, 'Refunded via Stripe. kml;\'ko\'k\'l;\'', '2025-06-12 23:11:01', '2025-06-12 23:12:46'),
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
(2, 'ADMIN');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `social_accounts`
--

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

INSERT INTO `users` (`id`, `fullname`, `phone_number`, `email`, `address`, `password`, `created_at`, `updated_at`, `is_active`, `date_of_birth`, `facebook_account_id`, `google_account_id`, `role_id`, `reset_password_token`, `reset_password_token_expiry`) VALUES
(3, 'ADMIN 1', '0111222333', 'admin.1@gmail.com', 'Hanoi', '$2a$10$zgJgPl51rJQGl8xlznCKgOGipZjbaPMXiF/Zv/03ri1mA1iN1Z.su', '2024-02-21 09:00:03', '2024-02-21 09:00:03', 1, '2003-11-12 00:00:00.000000', 0, 0, 2, NULL, NULL),
(18, 'lap', '0854768836', 'secroramot123@gmail.com', 'lap', '$2a$10$vagQjcnWTqYMU8mxtWsl.uF8DY3te0JzO6ObqVMkA9TfdMBa1mZEi', '2025-06-09 19:33:13', '2025-06-13 08:31:20', 1, '2003-10-26 00:00:00.000000', 0, 0, 1, NULL, NULL);

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
(1, 'SALE66', 'Sale 6/6', 'Giảm giá nhân dịp 6/6', 20, 500000, 100000, 100, 100, '2024-06-01 00:00:00', '2024-06-30 23:59:59', 1, '2025-06-09 18:19:46', '2025-06-09 18:19:46'),
(10, '156SUPERSALE', 'Sale cực sốc 15/6', 'Giảm giá sốc, số lượng có hạn', 20, 1000000, 700000, 10, 10, '2025-06-13 01:14:00', '2025-06-15 01:14:00', 1, '2025-06-13 08:15:04', '2025-06-13 08:15:04');

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
(1, 8, 30, 18, 18540688, '2025-06-09 21:06:59'),
(2, 9, 51, 18, 50000, '2025-06-13 06:20:00');

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
-- AUTO_INCREMENT cho các bảng đã đổ
--

--
-- AUTO_INCREMENT cho bảng `banners`
--
ALTER TABLE `banners`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

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
-- AUTO_INCREMENT cho bảng `lock_features`
--
ALTER TABLE `lock_features`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT cho bảng `news`
--
ALTER TABLE `news`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT cho bảng `orders`
--
ALTER TABLE `orders`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=94;

--
-- AUTO_INCREMENT cho bảng `order_details`
--
ALTER TABLE `order_details`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=127;

--
-- AUTO_INCREMENT cho bảng `products`
--
ALTER TABLE `products`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5787;

--
-- AUTO_INCREMENT cho bảng `product_features`
--
ALTER TABLE `product_features`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT cho bảng `product_images`
--
ALTER TABLE `product_images`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=136;

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
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
