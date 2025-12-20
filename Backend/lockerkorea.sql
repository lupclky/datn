-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Máy chủ: mysql8-container
-- Thời gian đã tạo: Th12 20, 2025 lúc 07:20 AM
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
-- Cơ sở dữ liệu: `lockerkorea`
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
(4, 'Khuyến mãi cà thẻ', '', 'ea2279f4-4cf1-4247-835a-79d9e3b210ea_7c1b6cbf-3f03-4032-9708-f5db958c0985_cathet5.jpg', '', '', 'primary', 12, 1, '2025-11-04 01:31:28', '2025-12-27 01:31:35', '2025-11-06 01:31:26', '2025-12-20 02:31:14'),
(5, 'KVK Intelligence', 'Trợ lý tư vấn vượt trội', 'a89ab3d2-c6e2-481a-9de8-1f202a3a762f_Tạo 1 banner ngang đ.png', '', '', 'primary', 3, 1, '2025-11-01 03:12:55', '2025-12-31 03:12:57', '2025-11-06 03:12:49', '2025-12-15 05:17:39');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `carts`
--

CREATE TABLE `carts` (
  `id` bigint NOT NULL,
  `user_id` int DEFAULT NULL,
  `product_id` int DEFAULT NULL,
  `quantity` bigint DEFAULT NULL,
  `size` bigint DEFAULT NULL,
  `session_id` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Đang đổ dữ liệu cho bảng `carts`
--

INSERT INTO `carts` (`id`, `user_id`, `product_id`, `quantity`, `size`, `session_id`) VALUES
(12, NULL, 11, 1, 43, NULL),
(42, NULL, 5784, 1, NULL, '639ebff0-53c8-48d9-944b-fd5415a8465d'),
(43, NULL, 5788, 4, NULL, '66281cc6-7228-4e9d-a247-3516e974f1c6'),
(44, NULL, 17, 2, NULL, '66281cc6-7228-4e9d-a247-3516e974f1c6');

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
(11, 'Chuông hình'),
(12, 'Xiaomi');

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
  `thumbnail` varchar(255) DEFAULT NULL,
  `facebook_post_id` varchar(255) DEFAULT NULL,
  `facebook_scheduled_at` datetime(6) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Đang đổ dữ liệu cho bảng `news`
--

INSERT INTO `news` (`id`, `title`, `content`, `summary`, `author`, `category`, `status`, `featured_image`, `views`, `published_at`, `created_at`, `updated_at`, `thumbnail`, `facebook_post_id`, `facebook_scheduled_at`) VALUES
(2, 'Hướng dẫn sử dụng', '<p>Hướng dẫn chi tiết cách sử dụng sản phẩm...</p>', 'Tóm tắt hướng dẫn', 'Admin', 'Hướng dẫn', 'PUBLISHED', 'd3ee3985-d911-4fde-bb17-15924a080df7_Tạo 1 banner ngang đ.png', 137, '2025-11-05 17:41:56', '2025-11-04 11:30:34', '2025-12-13 08:51:54', NULL, '945215165331759_122097151191166791', NULL),
(3, 'GIảm giá 30% khi mua khoá vân tay Welkom', '<h2>GIẢM GIÁ 30% KHI MUA KHOÁ VÂN TAY WELKOM: Nâng Tầm An Ninh Gia Đình Với Công Nghệ Hiện Đại</h2><p>Trong bối cảnh công nghệ đang phát triển vũ bão, việc đảm bảo an ninh cho ngôi nhà và tài sản đã trở thành ưu tiên hàng đầu của mọi gia đình. Không chỉ dừng lại ở những chiếc khóa cơ truyền thống, thế giới khóa điện tử và công nghệ an ninh đã mở ra một kỷ nguyên mới với sự xuất hiện của các giải pháp thông minh, trong đó nổi bật là khóa vân tay. Sự tiện lợi, bảo mật vượt trội và tính thẩm mỹ cao đã biến khóa vân tay từ một sản phẩm xa xỉ thành một lựa chọn thiết yếu cho tổ ấm hiện đại. Đây không chỉ là một thiết bị bảo vệ mà còn là một phần quan trọng của hệ sinh thái nhà thông minh, mang lại trải nghiệm sống tiện nghi và an toàn hơn bao giờ hết.</p><p>Thấu hiểu nhu cầu đó, và nhằm tạo điều kiện cho nhiều gia đình Việt Nam tiếp cận với công nghệ bảo mật tiên tiến, chúng tôi vui mừng thông báo về chương trình <strong>khuyến mãi đặc biệt</strong>: <strong>GIẢM GIÁ 30% khi mua khóa vân tay Welkom</strong>. Đây là cơ hội vàng để quý vị nâng cấp hệ thống an ninh cho ngôi nhà của mình với mức đầu tư tối ưu. Chương trình này không chỉ là một ưu đãi về giá, mà còn là lời cam kết mang đến những sản phẩm chất lượng cao, tích hợp công nghệ hiện đại nhất từ Welkom, một thương hiệu uy tín trong lĩnh vực khóa điện tử. Hãy cùng chúng tôi đi sâu vào tìm hiểu lý do vì sao khóa vân tay Welkom lại là sự lựa chọn hoàn hảo và cách tận dụng chương trình khuyến mãi hấp dẫn này.</p><h2>Sự Trỗi Dậy Của Khóa Vân Tay Trong Thời Đại Số Hóa An Ninh</h2><p>Thị trường khóa cửa đã chứng kiến một sự chuyển mình mạnh mẽ trong thập kỷ qua, với sự thay thế dần của khóa cơ truyền thống bằng các giải pháp khóa điện tử và khóa thông minh. Trong số đó, khóa vân tay đã nhanh chóng chiếm lĩnh vị trí dẫn đầu nhờ những ưu điểm vượt trội về bảo mật và tiện lợi. Thay vì phải lo lắng về việc mất chìa khóa, quên mã số, hay bị sao chép chìa một cách trái phép, công nghệ sinh trắc học cho phép người dùng mở cửa chỉ bằng một chạm tay, sử dụng chính dấu vân tay độc nhất của mình. Điều này không chỉ giúp tiết kiệm thời gian mà còn loại bỏ hoàn toàn nguy cơ mất an toàn do sơ suất cá nhân. Khóa vân tay là minh chứng rõ ràng cho việc công nghệ có thể đơn giản hóa cuộc sống đồng thời tăng cường lớp bảo vệ.</p><p>Hơn nữa, các mẫu khóa vân tay hiện đại như Welkom thường được tích hợp nhiều phương thức mở khóa khác nhau, bao gồm mã số, thẻ từ, chìa cơ dự phòng và thậm chí là điều khiển qua ứng dụng di động. Sự đa dạng này đảm bảo rằng người dùng luôn có phương án dự phòng trong mọi tình huống, từ việc hết pin khẩn cấp cho đến việc cấp quyền truy cập tạm thời cho khách hoặc người giúp việc mà không cần phải trao chìa khóa vật lý. Đây là một bước tiến đáng kể so với khóa truyền thống, nơi mà việc quản lý chìa khóa trở nên phức tạp và dễ gây ra rủi ro an ninh. Sự kết hợp giữa tiện ích và tính năng bảo mật đa lớp chính là yếu tố then chốt giúp khóa vân tay trở thành lựa chọn ưu việt cho ngôi nhà hiện đại.</p><h2>Công Nghệ Vân Tay: Nền Tảng Của An Toàn và Tiện Nghi</h2><p>Trọng tâm của khóa vân tay nằm ở công nghệ nhận dạng sinh trắc học, cụ thể là dấu vân tay. Hiện nay, có hai loại cảm biến vân tay phổ biến được sử dụng trong khóa điện tử: cảm biến quang học và cảm biến điện dung. Cảm biến quang học hoạt động bằng cách chụp ảnh bề mặt vân tay và so sánh với dữ liệu đã lưu trữ, trong khi cảm biến điện dung sử dụng điện trường để tạo bản đồ chi tiết của các rãnh vân tay. Công nghệ cảm biến điện dung, thường được tìm thấy trên các thiết bị cao cấp như Welkom, có độ chính xác và khả năng chống làm giả cao hơn, vì nó đòi hỏi sự tiếp xúc trực tiếp với da người sống. Điều này giảm thiểu đáng kể rủi ro bị mở khóa bằng vân tay giả hoặc vân tay từ vật thể không phải là ngón tay thật.</p><p>Ngoài ra, hệ thống xử lý vân tay trên các khóa thông minh hiện đại còn được trang bị thuật toán học máy (Machine Learning), giúp cải thiện khả năng nhận diện theo thời gian. Mỗi lần người dùng đặt tay lên cảm biến, hệ thống không chỉ xác minh mà còn học hỏi, điều chỉnh để nhận diện vân tay nhanh và chính xác hơn, ngay cả khi ngón tay bị ướt, bẩn nhẹ hoặc có vết xước nhỏ. Điều này mang lại trải nghiệm sử dụng liền mạch và đáng tin cậy. Hơn nữa, khả năng lưu trữ hàng trăm dấu vân tay cho phép một ngôi nhà có thể cấp quyền truy cập cho tất cả thành viên trong gia đình, bạn bè thân thiết hoặc nhân viên một cách dễ dàng, đồng thời có thể xóa bỏ quyền truy cập bất cứ lúc nào khi cần thiết. Đây là một ưu điểm vượt trội so với việc phải thay khóa hoặc sao chép chìa khi có sự thay đổi về người sử dụng.</p><h2>Welkom: Sự Kết Hợp Hoàn Hảo Giữa Thiết Kế và Công Nghệ Bảo Mật</h2><p>Khóa vân tay Welkom không chỉ đơn thuần là một thiết bị an ninh; đó là một tuyên bố về phong cách sống và sự cam kết đối với an toàn. Các sản phẩm của Welkom được thiết kế với sự chú trọng cao đến cả tính thẩm mỹ và hiệu suất. Với kiểu dáng hiện đại, đường nét tinh tế và chất liệu cao cấp (thường là hợp kim kẽm hoặc thép không gỉ), khóa Welkom dễ dàng hòa nhập vào mọi không gian kiến trúc, từ căn hộ chung cư hiện đại đến biệt thự sang trọng. Nhưng vẻ đẹp bên ngoài chỉ là khởi đầu; sức mạnh thực sự của Welkom nằm ở công nghệ bảo mật tiên tiến được tích hợp bên trong.</p><p>Mỗi chiếc khóa Welkom đều được trang bị bộ vi xử lý mạnh mẽ, hệ thống mã hóa dữ liệu tiên tiến và các cảm biến vân tay chính xác, đảm bảo rằng mọi giao dịch mở khóa đều an toàn và riêng tư. Khả năng chống nước và chống bụi đạt chuẩn, cùng với khả năng chịu được nhiệt độ và độ ẩm khắc nghiệt, giúp khóa Welkom hoạt động bền bỉ trong nhiều điều kiện môi trường khác nhau. Hơn nữa, Welkom còn tích hợp các tính năng thông minh như cảnh báo đột nhập trái phép, cảnh báo pin yếu, và khả năng xem lại lịch sử ra vào qua ứng dụng di động. Điều này biến cánh cửa của bạn thành một trung tâm điều khiển an ninh mini, cho phép bạn kiểm soát và giám sát từ xa mọi lúc, mọi nơi, mang lại sự yên tâm tuyệt đối cho gia đình.</p><h2>Tích Hợp IoT và Nhà Thông Minh: Khóa Welkom trong Hệ Sinh Thái Số</h2><p>Trong kỷ nguyên Internet of Things (IoT), khóa vân tay Welkom không chỉ là một thiết bị độc lập mà còn là một mắt xích quan trọng trong hệ sinh thái nhà thông minh. Khả năng kết nối không dây qua Wi-Fi hoặc Bluetooth cho phép khóa Welkom giao tiếp với các thiết bị thông minh khác trong nhà, tạo ra một hệ thống an ninh và tiện nghi liền mạch. Ví dụ, bạn có thể thiết lập kịch bản tự động để khi bạn mở cửa bằng vân tay, đèn trong nhà sẽ tự động bật, điều hòa không khí khởi động và hệ thống âm thanh phát nhạc chào đón. Ngược lại, khi khóa cửa từ bên ngoài, tất cả các thiết bị điện không cần thiết có thể tự động tắt, giúp tiết kiệm năng lượng.</p><p>Khả năng quản lý từ xa qua ứng dụng di động là một trong những tính năng được đánh giá cao nhất. Dù bạn đang ở văn phòng, đi du lịch hay chỉ đơn giản là không có mặt ở nhà, bạn vẫn có thể cấp quyền truy cập tạm thời cho người thân, dịch vụ giao hàng hoặc thợ sửa chữa thông qua mã số dùng một lần hoặc mã số có thời hạn. Bạn cũng có thể theo dõi lịch sử ra vào chi tiết, nhận cảnh báo ngay lập tức nếu có bất kỳ hoạt động đáng ngờ nào tại cửa. Sự tích hợp này không chỉ tăng cường bảo mật mà còn nâng cao đáng kể sự tiện nghi và linh hoạt trong quản lý ngôi nhà, biến ngôi nhà của bạn thực sự trở thành một \"ngôi nhà thông minh\" theo đúng nghĩa.</p><h2>Lời Khuyên Chuyên Gia: Lựa Chọn và Bảo Trì Khóa Vân Tay Welkom</h2><p>Để đảm bảo tận dụng tối đa lợi ích từ khóa vân tay Welkom, việc lựa chọn sản phẩm phù hợp và bảo trì đúng cách là vô cùng quan trọng. Trước khi mua, hãy xem xét kỹ lưỡng các yếu tố như loại cửa (gỗ, thép, cửa kính), độ dày đố cửa, và hướng mở cửa để chọn mẫu khóa tương thích. Welkom cung cấp nhiều dòng sản phẩm đa dạng, từ khóa cửa chính, cửa phòng ngủ đến cửa cổng, mỗi loại có những đặc điểm và yêu cầu lắp đặt riêng. Đừng ngần ngại tham khảo ý kiến từ các chuyên gia hoặc nhân viên tư vấn để có được lựa chọn tối ưu nhất cho ngôi nhà của bạn. Về tính năng, hãy ưu tiên các mẫu có nhiều phương thức mở khóa (vân tay, mã số, thẻ từ, chìa cơ, app) và các tính năng cảnh báo thông minh, tích hợp nhà thông minh để đảm bảo an toàn và tiện lợi toàn diện.</p><p>Về bảo trì, mặc dù khóa vân tay Welkom được thiết kế để hoạt động bền bỉ, nhưng việc chăm sóc định kỳ sẽ giúp kéo dài tuổi thọ và duy trì hiệu suất. Hãy đảm bảo vệ sinh bề mặt cảm biến vân tay và bàn phím mã số thường xuyên bằng vải mềm và khô để loại bỏ bụi bẩn và dầu mỡ. Kiểm tra và thay pin định kỳ (thường là 6-12 tháng một lần, tùy theo tần suất sử dụng và loại pin) là rất quan trọng để tránh tình trạng khóa hết pin đột ngột. Hầu hết các khóa Welkom đều có cảnh báo pin yếu, vì vậy hãy chú ý đến tín hiệu này. Ngoài ra, hãy thường xuyên cập nhật phần mềm hoặc firmware của khóa (nếu có) thông qua ứng dụng để đảm bảo hệ thống bảo mật luôn được vá lỗi và nâng cấp các tính năng mới nhất, giữ cho khóa của bạn luôn hoạt động ở trạng thái tốt nhất và an toàn nhất.</p><h2>Tóm Tắt Khuyến Mãi: Cơ Hội Vàng Để Nâng Cấp An Ninh</h2><p>Chương trình <strong>GIẢM GIÁ 30% khi mua khóa vân tay Welkom</strong> không chỉ là một cơ hội tiết kiệm chi phí mà còn là một bước đầu tư thông minh vào sự an toàn và tiện nghi cho tổ ấm của bạn. Đây là thời điểm lý tưởng để bạn loại bỏ những chiếc chìa khóa lỉnh kỉnh, những lo lắng về an ninh và chào đón một kỷ nguyên mới của sự tiện lợi và bảo mật vượt trội. Với mức giảm giá hấp dẫn này, việc sở hữu một chiếc khóa vân tay cao cấp từ Welkom trở nên dễ dàng và phải chăng hơn bao giờ hết. Chúng tôi tin rằng, mỗi gia đình đều xứng đáng được trải nghiệm những công nghệ bảo mật tiên tiến nhất, và Welkom cam kết mang đến những giải pháp tốt nhất để bảo vệ những gì quý giá nhất của bạn.</p><p>Hãy nhanh chóng nắm bắt cơ hội có một không hai này. Chương trình khuyến mãi có thời hạn và số lượng sản phẩm có thể có giới hạn. Đừng bỏ lỡ dịp để biến ngôi nhà của bạn thành một pháo đài an toàn và hiện đại hơn với khóa vân tay Welkom. Liên hệ ngay với các đại lý hoặc truy cập website chính thức của Welkom để biết thêm thông tin chi tiết về các mẫu khóa áp dụng, điều khoản và điều kiện của chương trình. An toàn của gia đình bạn là ưu tiên hàng đầu, và với Welkom, bạn có thể hoàn toàn yên tâm. <strong>Tóm tắt khuyến mãi</strong>: Chương trình <strong>GIẢM GIÁ 30%</strong> áp dụng cho các sản phẩm khóa vân tay Welkom, mang đến công nghệ bảo mật hàng đầu với mức giá ưu đãi chưa từng có. Hãy hành động ngay để không bỏ lỡ!</p><h2>&nbsp;</h2>', 'Tóm tắt khuyến mãi', 'Admin', 'Khuyến mãi', 'PUBLISHED', '08e68548-4635-4d7d-8684-edc21194f141_unnamed.jpg', 218, '2025-11-05 17:42:19', '2025-11-04 11:30:34', '2025-12-20 02:21:44', NULL, '945215165331759_122096991819166791', NULL),
(5, 'Ra mắt Khóa vân tay Samsung SHP-DH538', '<h2><strong style=\"background-color: initial;\"><em>Khóa vân tay Samsung SHP-DH538:</em></strong></h2><p>- Mở bằng: vân tay, mã số, chìa cơ (dự phòng)</p><h4><strong style=\"background-color: initial; color: rgb(204, 0, 0);\"><em>- Giá: 5.490.000 đồng</em></strong></h4><iframe class=\"ql-video\" frameborder=\"0\" allowfullscreen=\"true\" src=\"https://www.youtube.com/embed/4ldAlQJer5w?showinfo=0\"></iframe><p class=\"ql-align-center\"><br></p><p><strong style=\"color: rgb(119, 119, 119);\">1. Chức năng cơ bản</strong></p><p>Khóa cửa điện tử Samsung SHP DH538 với thiết kế màu đỏ đồng phù hợp với các căn hộ sang trọng. Công nghệ quét vân tay quang học và mã số ngẫu nhiên, cùng hệ thống cảnh báo đột nhập sẽ đem lại sự an toàn và tiện lợi đến căn hộ của bạn.</p><p><br></p><p><span style=\"background-color: initial; color: rgb(0, 0, 238);\"><img src=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEitN1ag8THMYP6RRfGExIy4WoW215YjBgcVtmZKXS0naO-aen-OLqV6EdzrBLHgH32co26LxCr-pmaRPXV290CI7uL46Z1dcVZOZSzOlK_qiMl26AbCdnsUPha_V3roELfwKVysRErqigeB/w640-h212/Screenshot-365-1024x340.png\" height=\"212\" width=\"640\"></span></p><p><br></p><p class=\"ql-align-center\"><a href=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhyqgdga_-zcWFx6gF5igT7FBpefisGLWYKv4PHxkkXU5M4OG64dlEEf_H0qvOucwXmBUaB1-50LY2vFWbcK5qazfIO1YO98vG9cMiNnSpX7Vi2oXMJhAXYRr2Pi44LmSp9yFmVNTi2WNgD/s1024/Screenshot-362-2-1024x496-1.jpg\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"background-color: initial; color: rgb(191, 30, 45);\"><img src=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhyqgdga_-zcWFx6gF5igT7FBpefisGLWYKv4PHxkkXU5M4OG64dlEEf_H0qvOucwXmBUaB1-50LY2vFWbcK5qazfIO1YO98vG9cMiNnSpX7Vi2oXMJhAXYRr2Pi44LmSp9yFmVNTi2WNgD/w640-h310/Screenshot-362-2-1024x496-1.jpg\" height=\"310\" width=\"640\"></a></p><p><br></p><p class=\"ql-align-center\"><a href=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEh9WfkszxYZICvwC_HcVI2n3nxg9fQ1gr2tyTtM3wX45onDY_fo6nz5Ez83t47N9f1laxixaBYxJQaltsL25PUDIixk7St5jHFFyM0NRnjTJNEEiNJB4G_YqHvphGrkqvQ52mFb11g12FRn/s1024/Screenshot-366-3-1024x587.png\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"background-color: initial; color: rgb(191, 30, 45);\"><img src=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEh9WfkszxYZICvwC_HcVI2n3nxg9fQ1gr2tyTtM3wX45onDY_fo6nz5Ez83t47N9f1laxixaBYxJQaltsL25PUDIixk7St5jHFFyM0NRnjTJNEEiNJB4G_YqHvphGrkqvQ52mFb11g12FRn/w640-h366/Screenshot-366-3-1024x587.png\" height=\"366\" width=\"640\"></a></p><p><br></p><p class=\"ql-align-center\"><a href=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgMTvZvsaQXjXVTTqpimFXvMsx0Rz9V1U-N2c3ymxYWx2mp5qDGTLsNHC-DrRjznpDuYTDNPTBI8SOfHh9hPwI4CFYCxq9QZY-wUGZ_OCLehXWYbRtpEFn4TNgBTtvAKX1OdRH4Y51HwBRt/s1024/Screenshot-368-2-1024x620.png\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"background-color: initial; color: rgb(191, 30, 45);\"><img src=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgMTvZvsaQXjXVTTqpimFXvMsx0Rz9V1U-N2c3ymxYWx2mp5qDGTLsNHC-DrRjznpDuYTDNPTBI8SOfHh9hPwI4CFYCxq9QZY-wUGZ_OCLehXWYbRtpEFn4TNgBTtvAKX1OdRH4Y51HwBRt/w640-h388/Screenshot-368-2-1024x620.png\" height=\"388\" width=\"640\"></a></p><p><br></p><p class=\"ql-align-center\"><a href=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjDXBiy2-BavdmqssMDSnpFlAAvHdVvwsH0AnOUd06mmiARCHuIZrhuP-3ajV4S_iPnxr4hasItAVRCU7IQwXQQpisbPZfFDjehnYk2LKddUp7fW87qhaocfqlUJqehR1oWjqqmVN3Xd-Za/s1024/Screenshot-370-2-1024x577-1.jpg\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"background-color: initial; color: rgb(191, 30, 45);\"><img src=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjDXBiy2-BavdmqssMDSnpFlAAvHdVvwsH0AnOUd06mmiARCHuIZrhuP-3ajV4S_iPnxr4hasItAVRCU7IQwXQQpisbPZfFDjehnYk2LKddUp7fW87qhaocfqlUJqehR1oWjqqmVN3Xd-Za/w640-h360/Screenshot-370-2-1024x577-1.jpg\" height=\"360\" width=\"640\"></a></p><p><br></p><p class=\"ql-align-center\"><a href=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhCAKCrUustusR9ei3Dkafz-uMnbDkpt2yf-RGTN3TZmgcM5Ma8OR3rv5BDh0iX72R4ff886tGGrfnIVuti1ud_5uMP1_mo1uwzsQ1VOyIT1nBCCAQIk4RVeWgUaVRATAfkGZpK6zN0cspa/s510/Screenshot-372-1-510x289.png\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"background-color: initial; color: rgb(191, 30, 45);\"><img src=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhCAKCrUustusR9ei3Dkafz-uMnbDkpt2yf-RGTN3TZmgcM5Ma8OR3rv5BDh0iX72R4ff886tGGrfnIVuti1ud_5uMP1_mo1uwzsQ1VOyIT1nBCCAQIk4RVeWgUaVRATAfkGZpK6zN0cspa/w640-h362/Screenshot-372-1-510x289.png\" height=\"362\" width=\"640\"></a></p><p><br></p><p class=\"ql-align-center\"><a href=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEg7aGYa-7BxFJ_i3xbGuG5tDPs2Fg9kuNChMiAXvvfWg6VNcX7ijXzzX7Z3ZShGir2RAvcjqSnCdEtF23hIQhePo32CE3DU3hI7rA8aNtf4ZFq-hzKSEUCqf7oWczpE-qBOxWpJAipZbmmp/s1024/Screenshot-372-2-1024x580.png\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"background-color: initial; color: rgb(191, 30, 45);\"><img src=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEg7aGYa-7BxFJ_i3xbGuG5tDPs2Fg9kuNChMiAXvvfWg6VNcX7ijXzzX7Z3ZShGir2RAvcjqSnCdEtF23hIQhePo32CE3DU3hI7rA8aNtf4ZFq-hzKSEUCqf7oWczpE-qBOxWpJAipZbmmp/w640-h362/Screenshot-372-2-1024x580.png\" height=\"362\" width=\"640\"></a></p><p><br></p><p class=\"ql-align-center\"><a href=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgP9DpsDZpw9k5BhdFCFPDXzo9azB3feYl4ML5WZl8ooLoyNHeNPySwcEY_OWrcJdwrsjG6mPW_Eli1Pc7wdDqzFOIBUSJu04fQScdWmUqCpagcB-6zlRc9SCLnpQownCipdDP0a7wWAJGa/s1024/Screenshot-374-2-1024x591.png\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"background-color: initial; color: rgb(191, 30, 45);\"><img src=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgP9DpsDZpw9k5BhdFCFPDXzo9azB3feYl4ML5WZl8ooLoyNHeNPySwcEY_OWrcJdwrsjG6mPW_Eli1Pc7wdDqzFOIBUSJu04fQScdWmUqCpagcB-6zlRc9SCLnpQownCipdDP0a7wWAJGa/w640-h370/Screenshot-374-2-1024x591.png\" height=\"370\" width=\"640\"></a></p><p><br></p><p class=\"ql-align-center\"><a href=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEh0fNo5Qbq5wt4Ovq1TBq_9gk0QxqUrFgO1MbZLsqO73_N-ZLr5Z6rBUutmyr0xOivrNv_Q9SoAOCDLSLmygysVuGXor9p-1D8h91EVKEKNL3dH20enL4F4t8Lyj2djR94GSh3NzeEOTZWS/s1024/Screenshot-376-2-1024x552.png\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"background-color: initial; color: rgb(191, 30, 45);\"><img src=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEh0fNo5Qbq5wt4Ovq1TBq_9gk0QxqUrFgO1MbZLsqO73_N-ZLr5Z6rBUutmyr0xOivrNv_Q9SoAOCDLSLmygysVuGXor9p-1D8h91EVKEKNL3dH20enL4F4t8Lyj2djR94GSh3NzeEOTZWS/w640-h344/Screenshot-376-2-1024x552.png\" height=\"344\" width=\"640\"></a></p><p><br></p><p class=\"ql-align-center\"><a href=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEh82Bf9-6POfLFXfOr1E2rkmbN-pJ5hXLnsl0fhnAPkWsH8FVxT-kr7zBP-d0qvxct_SzbW2eLpDQKqSwSvG2L2m93zVZbjE9c7vu67HNIMqT0yhYhAZflMrGItf7-0irZTlSwXK-cGWBno/s1024/Screenshot-380-2-1024x580.png\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"background-color: initial; color: rgb(191, 30, 45);\"><img src=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEh82Bf9-6POfLFXfOr1E2rkmbN-pJ5hXLnsl0fhnAPkWsH8FVxT-kr7zBP-d0qvxct_SzbW2eLpDQKqSwSvG2L2m93zVZbjE9c7vu67HNIMqT0yhYhAZflMrGItf7-0irZTlSwXK-cGWBno/w640-h362/Screenshot-380-2-1024x580.png\" height=\"362\" width=\"640\"></a></p><p><br></p><p class=\"ql-align-center\"><a href=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhdu4zX0mrI7mdyJNcHkFC4QhtztqNiNd04qLX6cXo2eTsHW5XwAkZS3kPP0ocSg01dSQgSnoNXxs40SJ9jNQDT0mazvGXOQSNkbZE3IiKcjHmBEhIoKpPGfi0mSpsWFRNu5Et-Ismlbves/s1024/Screenshot-385-2-1024x587.png\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"background-color: initial; color: rgb(191, 30, 45);\"><img src=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhdu4zX0mrI7mdyJNcHkFC4QhtztqNiNd04qLX6cXo2eTsHW5XwAkZS3kPP0ocSg01dSQgSnoNXxs40SJ9jNQDT0mazvGXOQSNkbZE3IiKcjHmBEhIoKpPGfi0mSpsWFRNu5Et-Ismlbves/w640-h366/Screenshot-385-2-1024x587.png\" height=\"366\" width=\"640\"></a></p><p><br></p><p class=\"ql-align-center\"><a href=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhFYFoEpvedT4hh3XkWGNOs6HyxbOPS5dk-RcMHQhTFKIPYm25nskOjUPDmx1IcoAFKIjnpb3YrN27LVoCU10kQFpu_4e7BW6zzDzudC-4GDpDtWZMEUav1h0SCasTsND40LqQAYAlloL_w/s1024/Screenshot-386-2-1024x536.png\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"background-color: initial; color: rgb(191, 30, 45);\"><img src=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhFYFoEpvedT4hh3XkWGNOs6HyxbOPS5dk-RcMHQhTFKIPYm25nskOjUPDmx1IcoAFKIjnpb3YrN27LVoCU10kQFpu_4e7BW6zzDzudC-4GDpDtWZMEUav1h0SCasTsND40LqQAYAlloL_w/w640-h336/Screenshot-386-2-1024x536.png\" height=\"336\" width=\"640\"></a></p><p><br></p><p><strong style=\"background-color: initial;\">2. Thông số kĩ thuật&nbsp;khóa Samsung&nbsp;SHP-DH538</strong></p><p><strong style=\"background-color: initial;\">Vân tay và mã số</strong>Mã số: 4~12 ký tự điện tử</p><p>Công nghệ cảm ứng điện dung</p><p><strong style=\"background-color: initial;\">Bộ nhớ vân tay tối đa</strong>100<strong style=\"background-color: initial;\">Kích thướcThân ngoài</strong>81.8(W) X 320(H) X 66.8(D)mm<strong style=\"background-color: initial;\">Thân trong</strong>79(W) X 290(H) X 80.3(D)mm<strong style=\"background-color: initial;\">Độ dày cửa thích hợp</strong>40~80mm<strong style=\"background-color: initial;\">Nguồn</strong>8 viên pin AA Alkaline Batteries<strong style=\"background-color: initial;\">Thời gian cần thay pin</strong>Xấp xỉ 12 tháng<strong style=\"background-color: initial;\">Màu</strong>Đen, đỏ đồng</p>', '- Mở bằng: vân tay, mã số, chìa cơ (dự phòng)\n\n- Giá: 5.490.000 đồng', NULL, 'Tin tức', 'PUBLISHED', '38a51683-a41c-4740-a173-a8ceac011b7a_SHS-P718_3-4.png', 19, '2025-11-04 18:00:04', '2025-11-04 13:50:37', '2025-12-16 10:28:50', NULL, '945215165331759_122100487113166791', NULL),
(6, 'Các công nghệ Khoá cửa mới ứng dụng Trí tuệ nhân tạo', '<h2>&nbsp;</h2><h2>Mở đầu</h2><p>Trong kỷ nguyên số hóa không ngừng, sự tiến bộ của <strong>công nghệ</strong> đã và đang định hình lại mọi khía cạnh của cuộc sống, từ cách chúng ta giao tiếp đến cách chúng ta bảo vệ không gian riêng tư. Đặc biệt, lĩnh vực an ninh gia đình đã chứng kiến một cuộc cách mạng mạnh mẽ với sự xuất hiện của các thiết bị <strong>khóa điện tử</strong> và <strong>smart lock</strong>. Tuy nhiên, nếu chỉ dừng lại ở việc mở khóa bằng vân tay, mã số hay thẻ từ thì đó mới chỉ là bước khởi đầu. Ngày nay, với sự tích hợp của <strong>Trí tuệ nhân tạo (AI)</strong>, các hệ thống khóa cửa đã vượt xa giới hạn thông thường, mang đến một cấp độ <strong>bảo mật</strong>, tiện lợi và thông minh hoàn toàn mới.</p><p>Bài viết này sẽ đi sâu vào khám phá cách AI đang cách mạng hóa ngành khóa cửa, từ việc tăng cường khả năng nhận diện sinh trắc học, phân tích hành vi người dùng, đến việc tích hợp liền mạch vào hệ sinh thái nhà thông minh. Chúng ta cũng sẽ tìm hiểu những lợi ích vượt trội mà công nghệ này mang lại, cũng như những thách thức cần đối mặt và những lời khuyên hữu ích để người dùng có thể đưa ra lựa chọn sáng suốt nhất cho ngôi nhà của mình.</p><p>&nbsp;</p><h2>Nội dung chính</h2><h3>1. AI nâng tầm bảo mật và tiện ích của Khóa thông minh</h3><p>Ban đầu, các loại <strong>khóa điện tử</strong> và <strong>smart lock</strong> đã gây ấn tượng với khả năng mở khóa không cần chìa vật lý, điều khiển từ xa và ghi nhận lịch sử ra vào. Nhưng khi AI được đưa vào, chúng không chỉ còn là thiết bị thực hiện lệnh đơn thuần mà đã trở thành \"người gác cổng\" thông minh, có khả năng học hỏi, thích nghi và thậm chí là dự đoán. AI giúp nâng cao đáng kể độ chính xác và tốc độ của các phương thức xác thực sinh trắc học như <strong>nhận diện vân tay</strong> và <strong>nhận diện khuôn mặt</strong>. Các thuật toán AI có thể phân tích hàng triệu điểm dữ liệu từ vân tay hay đặc điểm khuôn mặt, giúp phân biệt giữa người thật và các hành vi giả mạo một cách hiệu quả hơn bao giờ hết, ngay cả trong điều kiện ánh sáng yếu hoặc khi có sự thay đổi nhỏ trên khuôn mặt.</p><p>Hơn nữa, AI còn cho phép khóa cửa học hỏi các thói quen và lịch trình của người dùng. Ví dụ, nếu bạn thường xuyên về nhà vào một giờ cố định, khóa có thể tự động chuẩn bị mở khóa khi bạn đến gần. Khả năng này không chỉ tăng cường tiện ích mà còn là nền tảng cho các hệ thống an ninh chủ động hơn. Với <strong>xu hướng công nghệ IoT</strong> phát triển mạnh mẽ, các <strong>khóa thông minh AI</strong> trở thành một mắt xích quan trọng trong hệ sinh thái <strong>smart home</strong>, kết nối với các thiết bị khác như camera an ninh, đèn chiếu sáng, và hệ thống báo động để tạo ra một mạng lưới an ninh đồng bộ và thông minh.</p><h3>2. Các ứng dụng AI đột phá trong công nghệ khóa cửa</h3><p>Sự tích hợp của AI mang đến nhiều ứng dụng vượt trội, biến khóa cửa không chỉ là một thiết bị bảo vệ mà còn là một phần của hệ thống quản lý an ninh toàn diện:</p><ul><li><strong>Nhận diện sinh trắc học thông minh thích ứng:</strong> AI cho phép các cảm biến vân tay và camera nhận diện khuôn mặt \"học\" và thích nghi với sự thay đổi. Chẳng hạn, cảm biến vân tay có thể nhận diện chính xác ngay cả khi tay bạn hơi ướt, bẩn, hoặc có vết thương nhỏ. Công nghệ <strong>nhận diện khuôn mặt</strong> được hỗ trợ bởi AI có thể phân biệt người thật với hình ảnh hoặc mặt nạ 3D, thậm chí còn có khả năng nhận diện cảm xúc để phát hiện các hành vi đáng ngờ.</li><li><strong>Phân tích hành vi và phát hiện bất thường:</strong> Đây là một trong những ứng dụng mạnh mẽ nhất của AI. Khóa AI có thể theo dõi và học hỏi các mô hình truy cập thông thường của bạn và gia đình. Khi có bất kỳ hành vi nào lệch khỏi mô hình này (ví dụ: cố gắng mở khóa vào những thời điểm bất thường, số lần nhập sai mã PIN liên tục vượt quá mức cho phép), hệ thống sẽ tự động gửi cảnh báo đến điện thoại của bạn hoặc kích hoạt các biện pháp an ninh khác như bật còi báo động, ghi hình qua camera.</li><li><strong>Quản lý truy cập tự động và thông minh:</strong> AI tối ưu hóa việc cấp quyền truy cập. Thay vì phải cài đặt thủ công từng quyền cho từng người, AI có thể gợi ý hoặc tự động cấp quyền tạm thời dựa trên lịch trình đã định sẵn (ví dụ: cho nhân viên dọn dẹp, người giao hàng). Nó cũng có thể tự động khóa cửa khi phát hiện không có ai ở nhà, hoặc mở cửa khi bạn về mà không cần thao tác.</li><li><strong>Tích hợp sâu rộng với hệ sinh thái nhà thông minh:</strong> Với AI, khóa cửa trở thành trung tâm điều khiển an ninh. Khi bạn mở cửa, AI có thể ra lệnh cho đèn bật sáng, điều hòa khởi động và rèm cửa mở ra. Ngược lại, khi bạn khóa cửa đi ra ngoài, toàn bộ hệ thống sẽ chuyển sang chế độ an ninh, tắt các thiết bị điện không cần thiết và kích hoạt camera giám sát.</li></ul><h3>3. Lợi ích và những cân nhắc khi lựa chọn khóa cửa AI</h3><p>Việc ứng dụng AI vào khóa cửa mang lại những lợi ích vượt trội:</p><ul><li><strong>An ninh vượt trội:</strong> Khả năng phân tích và dự đoán của AI giúp phát hiện và ngăn chặn các mối đe dọa sớm hơn, hiệu quả hơn các hệ thống truyền thống.</li><li><strong>Tiện lợi tối đa:</strong> Tự động hóa quá trình khóa/mở, quản lý truy cập linh hoạt, giảm bớt gánh nặng về chìa khóa vật lý hay nhớ mã số.</li><li><strong>Trải nghiệm cá nhân hóa:</strong> Hệ thống học hỏi thói quen để cung cấp trải nghiệm mượt mà, phù hợp với từng thành viên gia đình.</li><li><strong>Tăng cường hiệu quả năng lượng:</strong> Kết hợp với các thiết bị smart home khác, AI có thể tối ưu hóa việc sử dụng năng lượng khi không có người ở nhà.</li></ul><p>Tuy nhiên, cũng có một số cân nhắc quan trọng:</p><ul><li><strong>Vấn đề quyền riêng tư và bảo mật dữ liệu:</strong> Khóa AI thu thập nhiều dữ liệu cá nhân (dữ liệu sinh trắc học, lịch sử ra vào). Điều quan trọng là phải chọn sản phẩm từ các nhà cung cấp uy tín, có chính sách bảo mật dữ liệu rõ ràng.</li><li><strong>Chi phí đầu tư ban đầu:</strong> Công nghệ AI thường đi kèm với chi phí cao hơn so với các loại khóa thông minh cơ bản.</li><li><strong>Phụ thuộc vào kết nối mạng và nguồn điện:</strong> Hầu hết các tính năng thông minh yêu cầu kết nối internet ổn định. Cần có giải pháp dự phòng nguồn điện để đảm bảo hoạt động liên tục khi mất điện.</li><li><strong>Rủi ro an ninh mạng:</strong> Như bất kỳ thiết bị IoT nào, khóa AI cũng có thể là mục tiêu của các cuộc tấn công mạng. Cần đảm bảo thiết bị được cập nhật phần mềm thường xuyên và có các lớp bảo mật vững chắc.</li></ul><blockquote><p><i>\"AI không chỉ là một tính năng bổ sung; nó là yếu tố cốt lõi thay đổi cách chúng ta tương tác với an ninh, biến khóa cửa từ một vật cản tĩnh thành một người bảo vệ chủ động và thông minh.\"</i></p></blockquote><h3>4. Tư vấn chọn mua và sử dụng khóa cửa AI hiệu quả</h3><p>Để tận dụng tối đa lợi ích của khóa cửa AI, người tiêu dùng cần lưu ý một số điểm sau:</p><ul><li><strong>Xác định nhu cầu:</strong> Đánh giá mức độ an ninh mong muốn, các tính năng cụ thể cần thiết (nhận diện khuôn mặt, vân tay, tích hợp smart home), và ngân sách của bạn.</li><li><strong>Nghiên cứu kỹ sản phẩm:</strong> Tìm hiểu về các công nghệ AI mà khóa sử dụng, độ tin cậy của thuật toán, và khả năng tương thích với các thiết bị smart home khác trong gia đình bạn.</li><li><strong>Ưu tiên các nhà sản xuất uy tín:</strong> Chọn những thương hiệu có tiếng trong lĩnh vực an ninh, cung cấp chính sách bảo hành rõ ràng và hỗ trợ kỹ thuật tốt.</li><li><strong>Kiểm tra các chứng nhận bảo mật:</strong> Đảm bảo khóa có các chứng nhận về an toàn dữ liệu và chống tấn công mạng từ các tổ chức uy tín.</li><li><strong>Thường xuyên cập nhật phần mềm (firmware):</strong> Các bản cập nhật không chỉ thêm tính năng mới mà còn vá lỗi bảo mật, nâng cao hiệu suất của AI.</li><li><strong>Thiết lập mật khẩu mạnh và sử dụng xác thực đa yếu tố (MFA):</strong> Nếu có, hãy kích hoạt MFA cho tài khoản quản lý khóa để tăng cường lớp bảo mật.</li><li><strong>Bảo vệ dữ liệu cá nhân:</strong> Hiểu rõ cách dữ liệu của bạn được thu thập và sử dụng. Đọc kỹ chính sách quyền riêng tư.</li><li><strong>Lên kế hoạch dự phòng:</strong> Đảm bảo có nguồn điện dự phòng (pin hoặc sạc khẩn cấp) và một phương pháp mở khóa cơ bản (chìa khóa vật lý, mã PIN) trong trường hợp khẩn cấp.</li></ul><h2>Kết luận</h2><p>Sự kết hợp giữa <strong>khóa điện tử</strong>, <strong>smart lock</strong> và <strong>Trí tuệ nhân tạo</strong> đang mở ra một kỷ nguyên mới cho <strong>an ninh gia đình</strong>. Khóa cửa không còn là một thiết bị đơn thuần để khóa và mở, mà đã trở thành một hệ thống bảo vệ thông minh, chủ động, có khả năng học hỏi và thích nghi. Mặc dù vẫn còn những thách thức về quyền riêng tư và an ninh mạng, nhưng tiềm năng mà AI mang lại là vô cùng to lớn, hứa hẹn một tương lai nơi ngôi nhà của chúng ta không chỉ an toàn hơn mà còn thông minh và tiện nghi hơn bao giờ hết.</p><p>Việc đầu tư vào một hệ thống khóa cửa AI thông minh là một quyết định đáng giá cho bất kỳ ai muốn nâng cấp an ninh và trải nghiệm sống trong ngôi nhà hiện đại. Hãy là người tiêu dùng thông thái, tìm hiểu kỹ lưỡng và chọn lựa sản phẩm phù hợp nhất để bảo vệ tổ ấm của mình.</p><p>```</p>', NULL, NULL, NULL, 'PUBLISHED', '85526858-1561-42f0-a38b-8ab16bb49dcc_SHS-2920_1.jpg', 5, '2025-11-04 17:32:50', '2025-11-04 17:32:50', '2025-12-12 16:56:15', NULL, '945215165331759_122096558307166791', NULL),
(7, 'Giới thiệu các khoá sản phẩm sắp ra mắt năm 2025', '<p>Trong kỷ nguyên công nghệ số bùng nổ, khái niệm về an ninh gia đình đã vượt xa những ổ khóa cơ học truyền thống. Giờ đây, chúng ta đang bước vào một thế giới nơi những cánh cửa không chỉ bảo vệ ngôi nhà mà còn là một phần thông minh, tích hợp liền mạch vào hệ sinh thái sống của chúng ta. Năm 2025 hứa hẹn sẽ là một cột mốc quan trọng, đánh dấu sự ra đời của một thế hệ khóa điện tử mới – những thiết bị không chỉ tiên tiến về công nghệ mà còn mang tính cách mạng về khả năng bảo mật, sự tiện lợi và trải nghiệm người dùng.</p>\n\n<p>Bài viết này được biên soạn bởi một chuyên gia về khóa điện tử và công nghệ an ninh, nhằm mục đích cung cấp một cái nhìn toàn diện và sâu sắc về những sản phẩm khóa thông minh sắp ra mắt trong năm 2025. Chúng ta sẽ cùng khám phá những đột phá công nghệ mới nhất, từ các phương thức mở khóa sinh trắc học siêu nhạy, khả năng kết nối không dây mạnh mẽ, đến các tính năng bảo mật chủ động được hỗ trợ bởi trí tuệ nhân tạo. Đồng thời, bài viết cũng sẽ đưa ra những lời khuyên hữu ích để bạn có thể lựa chọn và tận dụng tối đa những sản phẩm này, biến ngôi nhà của mình thành một pháo đài an ninh hiện đại và tiện nghi.</p>\n\n<h2>Tối ưu hóa bảo mật với công nghệ sinh trắc học đa phương thức</h2>\n\n<p>Một trong những điểm nhấn lớn nhất của các sản phẩm khóa điện tử năm 2025 chính là sự phát triển vượt bậc của công nghệ sinh trắc học. Không còn đơn thuần là cảm biến vân tay quang học, thế hệ khóa thông minh mới sẽ được trang bị các <strong>cảm biến vân tay siêu âm 3D</strong> tiên tiến, có khả năng quét sâu dưới bề mặt da, phát hiện các đặc điểm vân tay độc đáo và phân biệt vân tay thật với các bản sao giả mạo một cách chính xác. Điều này giúp loại bỏ hoàn toàn rủi ro bị đánh lừa bởi vân tay giả, nâng cao đáng kể độ an toàn. Bên cạnh đó, <strong>công nghệ nhận diện khuôn mặt 3D</strong> cũng sẽ trở nên phổ biến hơn, với khả năng hoạt động hiệu quả ngay cả trong điều kiện thiếu sáng hoặc ngược sáng, cùng với khả năng nhận diện người dùng ngay cả khi họ đeo khẩu trang hoặc thay đổi kiểu tóc nhẹ. Một số mẫu khóa cao cấp thậm chí còn tích hợp thêm <strong>công nghệ quét mống mắt</strong>, mang đến lớp bảo mật tuyệt đối, gần như không thể làm giả.</p>\n\n<p>Đặc biệt, khái niệm <strong>xác thực đa yếu tố sinh trắc học</strong> sẽ trở thành tiêu chuẩn. Điều này có nghĩa là để mở khóa, người dùng có thể cần kết hợp hai hoặc nhiều phương thức xác thực khác nhau, ví dụ như vân tay và mã PIN, hoặc nhận diện khuôn mặt và xác nhận qua ứng dụng điện thoại. Công nghệ <strong>trí tuệ nhân tạo (AI)</strong> sẽ đóng vai trò quan trọng trong việc phân tích dữ liệu sinh trắc học, học hỏi và cải thiện độ chính xác theo thời gian, đồng thời phát hiện các hành vi bất thường hoặc dấu hiệu của các cuộc tấn công giả mạo một cách thông minh. Hệ thống AI còn có thể tự động điều chỉnh độ nhạy của cảm biến tùy theo điều kiện môi trường, đảm bảo trải nghiệm mở khóa nhanh chóng và chính xác mọi lúc. Sự kết hợp này không chỉ tăng cường bảo mật mà còn mang lại sự tiện lợi tối đa, giúp người dùng an tâm tuyệt đối về an ninh cho ngôi nhà của mình.</p>\n\n<h2>Kết nối không giới hạn và hệ sinh thái nhà thông minh tích hợp sâu rộng</h2>\n\n<p>Năm 2025 sẽ chứng kiến sự đột phá trong khả năng kết nối của khóa điện tử, biến chúng thành một mắt xích không thể thiếu trong hệ sinh thái nhà thông minh. Các mẫu khóa mới sẽ được trang bị các chuẩn kết nối không dây tiên tiến nhất như <strong>Wi-Fi 6E</strong>, mang lại tốc độ truyền dữ liệu nhanh hơn, độ trễ thấp hơn và khả năng chống nhiễu vượt trội. Quan trọng hơn, sự ra đời và phổ biến của các giao thức chuẩn hóa như <strong>Matter và Thread</strong> sẽ giúp các khóa thông minh có thể giao tiếp và tương thích liền mạch với hầu hết các thiết bị nhà thông minh khác, từ đèn chiếu sáng, camera an ninh, rèm cửa tự động cho đến hệ thống điều hòa nhiệt độ, bất kể thương hiệu nào. Điều này chấm dứt kỷ nguyên của các ứng dụng riêng biệt và các thiết bị không thể \"nói chuyện\" với nhau, tạo ra một trải nghiệm nhà thông minh thực sự thống nhất và dễ quản lý.</p>\n\n<p>Với khả năng kết nối mạnh mẽ này, người dùng có thể điều khiển khóa từ xa một cách linh hoạt hơn bao giờ hết, ví dụ như mở khóa cho khách từ bất cứ đâu trên thế giới, kiểm tra trạng thái cửa, hoặc xem lại lịch sử ra vào ngay trên ứng dụng di động. Khóa thông minh cũng sẽ tích hợp sâu hơn với các <strong>trợ lý ảo giọng nói</strong> phổ biến như Google Assistant, Amazon Alexa hay Apple HomeKit, cho phép bạn khóa hoặc mở khóa cửa chỉ bằng một lệnh thoại đơn giản. Các <strong>kịch bản tự động hóa thông minh</strong> sẽ được nâng tầm: khi bạn rời khỏi nhà, khóa có thể tự động chốt cửa, đèn tắt, điều hòa giảm nhiệt độ, và hệ thống an ninh được kích hoạt. Ngược lại, khi bạn về đến nhà, cửa tự động mở, đèn sáng, và nhạc yêu thích bật lên, mang lại trải nghiệm sống tiện nghi và cá nhân hóa tối đa. Sự tích hợp này không chỉ nâng cao sự tiện lợi mà còn góp phần tăng cường an ninh tổng thể, khi tất cả các thiết bị có thể phối hợp hoạt động để bảo vệ ngôi nhà của bạn.</p>\n\n<h2>Thiết kế thông minh, vật liệu bền bỉ và nguồn năng lượng hiệu quả</h2>\n\n<p>Ngoài những cải tiến về công nghệ bên trong, khóa điện tử năm 2025 còn chú trọng đến vẻ bề ngoài và độ bền bỉ. Xu hướng thiết kế sẽ hướng tới sự <strong>tinh tế, tối giản và hiện đại</strong>, với các đường nét thanh thoát, mỏng hơn, dễ dàng hòa hợp với nhiều phong cách kiến trúc khác nhau, từ cổ điển đến đương đại. Người dùng sẽ có nhiều lựa chọn về màu sắc và chất liệu hoàn thiện cao cấp như thép không gỉ mờ, hợp kim nhôm hàng không, hoặc các bề mặt phủ kính cường lực chống trầy xước, không chỉ tăng tính thẩm mỹ mà còn chống lại các tác động từ môi trường và thời tiết. Các sản phẩm sẽ đạt các tiêu chuẩn <strong>chống nước và chống bụi (chuẩn IP)</strong> cao hơn, đảm bảo hoạt động ổn định trong mọi điều kiện khí hậu khắc nghiệt.</p>\n\n<p>Về độ bền, các bộ phận cơ khí bên trong sẽ được chế tạo từ <strong>vật liệu siêu bền</strong> như thép tôi cứng chống cắt phá, và cơ chế chống cạy phá sẽ được cải tiến để chịu được các tác động ngoại lực mạnh. Khả năng chống cháy và chống va đập cũng là những yếu tố được ưu tiên. Một trong những điểm cải tiến đáng chú ý khác là việc <strong>tối ưu hóa nguồn năng lượng</strong>. Pin sẽ có tuổi thọ dài hơn đáng kể, có thể lên đến 12-18 tháng chỉ với một lần sạc hoặc thay pin. Nhiều mẫu khóa sẽ tích hợp pin sạc qua cổng USB-C tiện lợi, thậm chí có thể xuất hiện các mẫu khóa sử dụng công nghệ sạc năng lượng mặt trời hoặc thu thập năng lượng động học từ việc đóng mở cửa để kéo dài thời gian sử dụng. Các tính năng như cảnh báo pin yếu sẽ được cải thiện với độ chính xác cao hơn, và khả năng cấp nguồn khẩn cấp qua cổng USB-C hoặc pin 9V dự phòng sẽ trở thành tiêu chuẩn, đảm bảo rằng bạn sẽ không bao giờ bị khóa ngoài vì hết pin.</p>\n\n<h2>Các tính năng an ninh nâng cao và quản lý truy cập thông minh</h2>\n\n<p>Bên cạnh việc nâng cấp các phương thức mở khóa và kết nối, khóa điện tử năm 2025 sẽ đi kèm với một loạt các tính năng an ninh và quản lý truy cập thông minh được cải tiến đáng kể, mang lại sự yên tâm tối đa cho người dùng. Khả năng <strong>tạo và quản lý khóa ảo hoặc mã PIN tạm thời</strong> sẽ trở nên linh hoạt hơn bao giờ hết. Bạn có thể dễ dàng cấp quyền truy cập giới hạn thời gian cho người giao hàng, nhân viên giúp việc, hoặc khách đến thăm, với khả năng thiết lập thời gian cụ thể (ví dụ: chỉ trong vòng 3 giờ vào ngày thứ Ba) và sau đó tự động hủy hiệu lực mã. Hệ thống sẽ cung cấp <strong>nhật ký truy cập chi tiết theo thời gian thực</strong>, cho phép bạn biết chính xác ai đã ra vào nhà mình vào lúc nào, thông báo ngay lập tức qua điện thoại nếu có bất kỳ hoạt động mở khóa nào hoặc có ai đó cố gắng đột nhập không thành công.</p>\n\n<p>Một tính năng nổi bật khác là <strong>Geofencing</strong>, cho phép khóa tự động mở khi bạn đến gần và tự động khóa khi bạn rời khỏi một khu vực nhất định, dựa trên vị trí GPS của điện thoại. Điều này không chỉ tiện lợi mà còn tăng cường an ninh bằng cách đảm bảo cửa luôn được khóa khi bạn vắng nhà. Sự <strong>tích hợp chặt chẽ với các hệ thống an ninh gia đình khác</strong> như camera giám sát và chuông cửa thông minh sẽ tạo ra một mạng lưới bảo vệ toàn diện. Khi có dấu hiệu đột nhập, khóa có thể kích hoạt báo động, camera ghi hình, và gửi thông báo khẩn cấp đến chủ nhà hoặc trung tâm an ninh. Các tiêu chuẩn mã hóa dữ liệu cũng được nâng cấp lên mức độ <strong>quân sự (end-to-end encryption)</strong>, bảo vệ thông tin cá nhân và lịch sử truy cập khỏi các cuộc tấn công mạng. Khóa cũng sẽ có khả năng nhận các bản cập nhật phần mềm (firmware over-the-air) định kỳ, giúp vá lỗi bảo mật và bổ sung tính năng mới, đảm bảo thiết bị luôn hoạt động ở trạng thái tốt nhất và an toàn nhất.</p>\n\n<h2>Lời khuyên khi chọn mua khóa điện tử cho năm 2025</h2>\n\n<p>Với sự đa dạng và phức tạp của các công nghệ sắp ra mắt, việc lựa chọn một chiếc khóa điện tử phù hợp cho ngôi nhà của bạn trong năm 2025 có thể là một thách thức. Dưới đây là những lời khuyên chi tiết giúp bạn đưa ra quyết định thông minh:</p>\n<ul>\n    <li><strong>Xác định rõ nhu cầu và ngân sách:</strong>\n        <ul>\n            <li><strong>Mục đích sử dụng:</strong> Bạn cần khóa cho căn hộ chung cư, nhà riêng, hay văn phòng? Cần các tính năng cơ bản hay một giải pháp an ninh toàn diện?</li>\n            <li><strong>Ngân sách:</strong> Các mẫu khóa có thể dao động từ vài triệu đến hàng chục triệu đồng tùy thuộc vào tính năng và thương hiệu. Xác định mức chi tiêu hợp lý sẽ giúp bạn thu hẹp lựa chọn.</li>\n            <li><strong>Môi trường lắp đặt:</strong> Khóa lắp đặt trong nhà hay ngoài trời? Nếu ngoài trời, cần chú ý đến khả năng chống nước, chống bụi (chuẩn IP) và khả năng chịu nhiệt độ khắc nghiệt.</li>\n        </ul>\n    </li>\n    <li><strong>Khả năng tương thích với hệ sinh thái nhà thông minh:</strong>\n        <ul>\n            <li>Nếu bạn đã có một hệ sinh thái nhà thông minh (ví dụ: Google Home, Apple HomeKit, Amazon Alexa), hãy ưu tiên các mẫu khóa hỗ trợ các chuẩn kết nối như <strong>Matter, Thread, hoặc HomeKit</strong> để đảm bảo khả năng tích hợp liền mạch và điều khiển dễ dàng qua một ứng dụng duy nhất.</li>\n            <li>Kiểm tra loại cửa và độ dày của cửa để đảm bảo khóa có thể lắp đặt vừa vặn và an toàn.</li>\n        </ul>\n    </li>\n    <li><strong>Đánh giá các tính năng bảo mật:</strong>\n        <ul>\n            <li>Ưu tiên các mẫu khóa có <strong>xác thực đa yếu tố</strong> (ví dụ: vân tay + mã PIN) để tăng cường bảo mật.</li>\n            <li>Tìm hiểu về công nghệ sinh trắc học: <strong>cảm biến vân tay 3D siêu âm</strong> và <strong>nhận diện khuôn mặt 3D</strong> là những lựa chọn hàng đầu.</li>\n            <li>Kiểm tra khả năng tạo mã PIN ảo, mã PIN dùng một lần, và khóa ảo.</li>\n            <li>Đảm bảo khóa có tính năng nhật ký truy cập, cảnh báo đột nhập, và mã hóa dữ liệu mạnh mẽ (end-to-end encryption).</li>\n        </ul>\n    </li>\n    <li><strong>Thiết kế, độ bền và nguồn năng lượng:</strong>\n        <ul>\n            <li>Chọn thiết kế phù hợp với nội thất và kiến trúc ngôi nhà của bạn.</li>\n            <li>Tìm hiểu về chất liệu chế tạo (thép không gỉ, hợp kim nhôm hàng không) và các tính năng chống va đập, chống cạy phá.</li>\n            <li>Ưu tiên các mẫu khóa có tuổi thọ pin dài, hỗ trợ sạc qua USB-C hoặc có pin dự phòng khẩn cấp.</li>\n        </ul>\n    </li>\n    <li><strong>Dịch vụ hỗ trợ và bảo hành:</strong>\n        <ul>\n            <li>Chọn mua sản phẩm từ các nhà cung cấp uy tín, có chính sách bảo hành rõ ràng và dịch vụ hỗ trợ kỹ thuật tốt.</li>\n            <li>Kiểm tra xem khóa có nhận được các bản cập nhật phần mềm định kỳ để vá lỗi bảo mật và nâng cấp tính năng hay không.</li>\n            <li>Đọc các bài đánh giá từ người dùng khác để có cái nhìn khách quan về sản phẩm và dịch vụ.</li>\n        </ul>\n    </li>\n</ul>\n<p>Bằng cách xem xét kỹ lưỡng các yếu tố này, bạn sẽ có thể tìm được chiếc khóa điện tử không chỉ đáp ứng nhu cầu bảo mật mà còn nâng cao chất lượng cuộc sống trong ngôi nhà thông minh của mình.</p>\n\n<p>Tổng kết lại, năm 2025 đang mở ra một kỷ nguyên mới cho công nghệ khóa điện tử và an ninh gia đình. Những sản phẩm sắp ra mắt không chỉ là những thiết bị bảo mật đơn thuần mà còn là những trung tâm điều khiển thông minh, tích hợp liền mạch vào cuộc sống hàng ngày. Từ các phương thức xác thực sinh trắc học đa yếu tố siêu nhạy, khả năng kết nối không dây mạnh mẽ với các chuẩn mới như Matter và Thread, đến thiết kế tinh tế và vật liệu bền bỉ, tất cả đều hướng tới mục tiêu mang lại sự an toàn tối đa, tiện lợi vượt trội và trải nghiệm người dùng không giới hạn. Sự phát triển của AI và công nghệ đám mây cũng sẽ giúp khóa thông minh trở nên \"thông minh\" hơn, học hỏi từ thói quen người dùng và chủ động bảo vệ ngôi nhà.</p>\n\n<p>Việc đầu tư vào một chiếc khóa điện tử hiện đại không chỉ là nâng cấp an ninh mà còn là đầu tư vào một phong cách sống tiện nghi, hiện đại và an tâm hơn. Với những thông tin và lời khuyên chi tiết trong bài viết này, hy vọng bạn đọc đã có cái nhìn rõ ràng hơn về những gì mong đợi từ thị trường khóa thông minh năm 2025 và sẵn sàng đưa ra lựa chọn sáng suốt nhất cho ngôi nhà của mình. Hãy sẵn sàng đón nhận những công nghệ bảo mật tiên tiến nhất, biến cánh cửa của bạn thành một điểm chạm thông minh, an toàn và đầy tiện ích.</p>\n<!-- Word count check: Total words approx 1550 words. -->', NULL, NULL, NULL, 'PUBLISHED', '871cb82d-bd83-4910-8e31-ff0a5c36a23a_sht-3517nt-1.jpg', 11, '2025-11-05 01:57:20', '2025-11-05 01:57:20', '2025-12-13 04:20:53', NULL, '945215165331759_122096991441166791', NULL);
INSERT INTO `news` (`id`, `title`, `content`, `summary`, `author`, `category`, `status`, `featured_image`, `views`, `published_at`, `created_at`, `updated_at`, `thumbnail`, `facebook_post_id`, `facebook_scheduled_at`) VALUES
(9, 'Hệ điều hành Apple lockOS 26', '<p>Trong bối cảnh công nghệ nhà thông minh đang phát triển vượt bậc, khái niệm về một hệ điều hành chuyên biệt dành cho các thiết bị an ninh, đặc biệt là khóa điện tử, đang dần trở thành một chủ đề nóng hổi. Mặc dù vẫn còn là một viễn cảnh, nhưng sự xuất hiện của một hệ thống như <strong>Apple lockOS 26</strong> có thể định hình lại hoàn toàn cách chúng ta tương tác và tin cậy vào an ninh ngôi nhà. Đây không chỉ là một bước tiến đơn thuần về phần mềm, mà còn là một cuộc cách mạng trong việc tích hợp sâu sắc giữa phần cứng bảo mật tiên tiến và một nền tảng vận hành thông minh, an toàn và dễ sử dụng. Với những cải tiến vượt trội, lockOS 26 hứa hẹn mang đến một chuẩn mực mới cho an ninh gia đình, nơi sự tiện lợi và bảo mật không còn là hai yếu tố đối lập mà hòa quyện vào nhau một cách hoàn hảo.</p><p>\n\n</p><p>Bài viết này sẽ đi sâu vào phân tích những khía cạnh tiềm năng của <strong>Apple lockOS 26</strong>, từ triết lý cốt lõi, các tính năng bảo mật hàng đầu, khả năng tích hợp nhà thông minh, cho đến trải nghiệm người dùng và những tác động lâu dài đến thị trường khóa điện tử và công nghệ an ninh. Chúng ta sẽ cùng khám phá cách một hệ điều hành được thiết kế riêng cho các thiết bị khóa thông minh có thể giải quyết những thách thức hiện tại, đồng thời mở ra cánh cửa cho những ứng dụng và khả năng bảo mật chưa từng có. Mục tiêu là cung cấp một cái nhìn toàn diện và chuyên sâu, giúp độc giả hiểu rõ hơn về tầm quan trọng của một nền tảng vững chắc trong việc xây dựng một hệ thống an ninh nhà ở thực sự thông minh và đáng tin cậy trong tương lai gần.</p><p>\n\n</p><h2>Triết Lý Cốt Lõi và Tích Hợp Hệ Sinh Thái</h2><p>\n\n</p><p>Nếu <strong>Apple lockOS 26</strong> trở thành hiện thực, triết lý cốt lõi của nó chắc chắn sẽ xoay quanh sự <strong>đơn giản, bảo mật và tích hợp liền mạch</strong>, những giá trị đã làm nên tên tuổi của Apple. Hệ điều hành này sẽ không chỉ là một phần mềm chạy trên khóa điện tử, mà là một cầu nối thông minh, mạnh mẽ, kết nối mọi thiết bị an ninh trong hệ sinh thái Apple HomeKit. Tưởng tượng một hệ thống nơi khóa cửa thông minh của bạn không chỉ mở bằng vân tay hay mật mã, mà còn có thể nhận diện khuôn mặt qua Face ID trên thiết bị di động, tự động khóa cửa khi bạn rời nhà, và gửi cảnh báo đến iPhone hoặc Apple Watch ngay lập tức khi có dấu hiệu đột nhập. Sự tích hợp này không chỉ nâng cao tính tiện lợi mà còn tạo ra một lớp bảo mật đa tầng, nơi thông tin được mã hóa đầu cuối và chỉ những người dùng được cấp quyền mới có thể truy cập. lockOS 26 sẽ tập trung vào việc tạo ra một trải nghiệm người dùng trực quan, giảm thiểu các bước phức tạp và đảm bảo rằng mọi tương tác với khóa đều dễ dàng và an toàn tuyệt đối, mang lại sự an tâm tuyệt đối cho chủ sở hữu.</p><p>\n\n</p><p>Sự tích hợp sâu rộng với hệ sinh thái Apple không chỉ dừng lại ở các thiết bị cá nhân như iPhone, iPad hay Apple Watch. Nó còn mở rộng đến các thiết bị nhà thông minh khác thông qua nền tảng <strong>HomeKit</strong>. Điều này có nghĩa là khóa thông minh chạy lockOS 26 có thể giao tiếp mượt mà với camera an ninh, hệ thống chiếu sáng thông minh, bộ điều nhiệt và các cảm biến khác trong ngôi nhà của bạn. Ví dụ, khi bạn mở cửa chính bằng khóa điện tử, đèn trong nhà có thể tự động bật, hoặc hệ thống an ninh sẽ tự động tắt chế độ cảnh báo. Ngược lại, khi bạn rời nhà và khóa cửa, hệ thống có thể tự động kích hoạt chế độ an ninh, tắt đèn và điều hòa không khí. Khả năng tương tác này tạo ra một hệ thống an ninh gia đình thông minh, phản ứng linh hoạt và chủ động, không chỉ dựa vào hành động của người dùng mà còn dựa trên ngữ cảnh và thói quen sinh hoạt. Điều này là bước tiến lớn so với các giải pháp khóa thông minh hiện tại, vốn thường hoạt động độc lập hoặc chỉ có khả năng tích hợp hạn chế với các nền tảng khác.</p><p>\n\n</p><h2>Tính Năng Bảo Mật Vượt Trội và Công Nghệ Sinh Trắc Học</h2><p>\n\n</p><p>Một trong những điểm nhấn quan trọng nhất của <strong>Apple lockOS 26</strong> sẽ là khả năng bảo mật tiên tiến, thiết lập một chuẩn mực mới cho ngành công nghiệp khóa điện tử. Hệ điều hành này sẽ tích hợp các công nghệ bảo mật đã được kiểm chứng của Apple, bao gồm <strong>mã hóa dữ liệu đầu cuối (end-to-end encryption)</strong> và <strong>Secure Enclave</strong>. Mọi dữ liệu nhạy cảm, từ dấu vân tay, mẫu khuôn mặt cho đến mã truy cập và nhật ký hoạt động, đều sẽ được mã hóa mạnh mẽ và lưu trữ trong một khu vực phần cứng biệt lập, không thể bị truy cập trái phép ngay cả khi hệ thống chính bị tấn công. Điều này đảm bảo rằng thông tin cá nhân của người dùng được bảo vệ ở mức cao nhất. Ngoài ra, lockOS 26 có thể được trang bị một hệ thống <strong>phát hiện mối đe dọa theo thời gian thực</strong>, sử dụng trí tuệ nhân tạo (AI) để phân tích các hành vi bất thường, như cố gắng mở khóa nhiều lần không thành công, rung động mạnh hoặc các dấu hiệu phá hoại, và ngay lập tức gửi cảnh báo đến người dùng và các cơ quan chức năng nếu được thiết lập trước. Đây là một sự khác biệt lớn so với các khóa thông minh hiện có, vốn thường chỉ tập trung vào các biện pháp bảo mật cơ bản.</p><p>\n\n</p><p>Công nghệ sinh trắc học sẽ là trái tim của an ninh trên lockOS 26. Tưởng tượng một khóa điện tử được tích hợp <strong>Face ID hoặc Touch ID</strong> ở cấp độ phần cứng và phần mềm, không chỉ đơn thuần là cảm biến vân tay. Điều này có nghĩa là khả năng nhận diện sẽ chính xác, an toàn và nhanh chóng hơn nhiều. Ví dụ, bạn chỉ cần nhìn vào khóa hoặc chạm ngón tay vào khu vực cảm biến để mở cửa, với tốc độ phản hồi gần như tức thì. Đối với các trường hợp đặc biệt, hệ thống có thể yêu cầu <strong>xác thực đa yếu tố (Multi-Factor Authentication - MFA)</strong>, chẳng hạn như yêu cầu nhập mã PIN sau khi nhận diện vân tay hoặc xác nhận qua iPhone đã ghép nối. lockOS 26 cũng có thể hỗ trợ các tính năng như \"chế độ khách\" với quyền truy cập giới hạn thời gian hoặc số lần, và khả năng thu hồi quyền truy cập từ xa ngay lập tức. Công nghệ này còn có thể mở rộng đến việc nhận diện người lạ và phân biệt với người quen, kích hoạt các biện pháp phòng ngừa hoặc cảnh báo khi có người không xác định ở gần cửa nhà quá lâu. Điều này không chỉ tăng cường bảo mật mà còn mang lại sự linh hoạt và tiện lợi chưa từng có trong việc quản lý quyền truy cập.</p><p>\n\n</p><h2>Tích Hợp Nhà Thông Minh và Tự Động Hóa Vượt Trội</h2><p>\n\n</p><p>Khả năng tích hợp sâu rộng vào hệ sinh thái nhà thông minh Apple HomeKit sẽ là một trong những lợi thế cạnh tranh lớn nhất của <strong>Apple lockOS 26</strong>. Hệ điều hành này sẽ cho phép khóa điện tử hoạt động như một mắt xích trung tâm trong chuỗi tự động hóa của ngôi nhà. Tưởng tượng một kịch bản: Khi bạn chuẩn bị về nhà, nhờ tính năng <strong>định vị địa lý (geofencing)</strong>, khóa cửa sẽ tự động mở khi bạn đến gần nhà, đồng thời đèn phòng khách bật sáng, điều hòa không khí tự động điều chỉnh nhiệt độ, và rèm cửa mở ra. Ngược lại, khi bạn ra khỏi nhà, khóa sẽ tự động đóng, hệ thống an ninh chuyển sang chế độ bảo vệ, và các thiết bị điện không cần thiết sẽ tự động tắt để tiết kiệm năng lượng. lockOS 26 sẽ cung cấp một giao diện quản lý trực quan trên ứng dụng Home của Apple, cho phép người dùng dễ dàng thiết lập các quy tắc tự động hóa phức tạp mà không cần kiến thức lập trình. Điều này biến ngôi nhà của bạn thành một không gian sống thông minh, phản ứng linh hoạt theo từng hành động và nhu cầu của bạn, mang lại sự tiện lợi tối đa và an tâm tuyệt đối.</p><p>\n\n</p><p>Ngoài các kịch bản tự động hóa dựa trên định vị, <strong>Apple lockOS 26</strong> còn mở rộng khả năng điều khiển thông qua giọng nói với <strong>Siri</strong>. Bạn có thể chỉ cần ra lệnh \"Hey Siri, mở cửa trước\" hoặc \"Hey Siri, khóa tất cả các cửa\" để thực hiện các thao tác mong muốn một cách nhanh chóng và rảnh tay. Điều này đặc biệt hữu ích khi bạn đang bận rộn với nhiều đồ đạc hoặc không muốn tìm điện thoại. Hệ thống cũng có thể được lập trình để tạo các lịch trình cụ thể, ví dụ như tự động khóa cửa vào một giờ nhất định mỗi đêm, hoặc mở khóa vào buổi sáng để người giúp việc có thể vào nhà trong một khoảng thời gian nhất định. Khả năng truy cập và quản lý từ xa qua internet cũng là một tính năng không thể thiếu. Dù bạn đang ở đâu, bạn vẫn có thể kiểm tra trạng thái khóa cửa, cấp quyền truy cập tạm thời cho khách, hoặc nhận cảnh báo ngay lập tức nếu có bất kỳ sự kiện bất thường nào xảy ra. Sự kết hợp giữa tự động hóa thông minh, điều khiển giọng nói và quản lý từ xa sẽ biến khóa điện tử không chỉ là một thiết bị an ninh mà còn là một phần không thể thiếu của trải nghiệm nhà thông minh toàn diện.</p><p>\n\n</p><h2>Trải Nghiệm Người Dùng và Các Ứng Dụng Thực Tế</h2><p>\n\n</p><p>Một yếu tố cốt lõi trong triết lý sản phẩm của Apple là mang đến <strong>trải nghiệm người dùng (UX)</strong> đỉnh cao, và <strong>Apple lockOS 26</strong> cũng sẽ không phải là ngoại lệ. Giao diện quản lý trên ứng dụng Home sẽ được thiết kế trực quan, sạch sẽ và dễ sử dụng, cho phép mọi thành viên trong gia đình, từ người lớn tuổi đến trẻ nhỏ, đều có thể dễ dàng quản lý quyền truy cập và các cài đặt bảo mật. Việc chia sẻ quyền truy cập cho người thân, bạn bè hoặc người giúp việc sẽ trở nên cực kỳ đơn giản với các tùy chọn linh hoạt như cấp mã PIN tạm thời, vân tay giới hạn thời gian, hoặc quyền truy cập từ xa có thể bị thu hồi bất cứ lúc nào. Người dùng có thể dễ dàng xem lại <strong>nhật ký hoạt động</strong> chi tiết, bao gồm ai đã ra vào, vào thời điểm nào, và bằng phương pháp nào (vân tay, mã, chìa khóa điện tử...). Điều này không chỉ tăng cường tính minh bạch mà còn cung cấp một công cụ giám sát hiệu quả, giúp người dùng luôn nắm rõ tình hình an ninh của ngôi nhà mình.</p><p>\n\n</p><p>Các <strong>ứng dụng thực tế và mẹo sử dụng</strong> cho lockOS 26 là vô vàn. Ví dụ, đối với gia đình có trẻ nhỏ, bạn có thể thiết lập chế độ thông báo riêng biệt khi trẻ về nhà từ trường, đảm bảo an toàn cho các em. Đối với người cao tuổi, giao diện đơn giản và khả năng mở khóa bằng giọng nói hoặc sinh trắc học sẽ loại bỏ nhu cầu ghi nhớ mã PIN phức tạp hoặc mang theo chìa khóa vật lý, giúp cuộc sống của họ trở nên dễ dàng và an toàn hơn. lockOS 26 cũng có thể tích hợp tính năng \"chế độ khẩn cấp,\" cho phép mở khóa tất cả các cửa nhanh chóng trong trường hợp hỏa hoạn hoặc các tình huống nguy hiểm khác, giúp việc thoát hiểm trở nên dễ dàng hơn. Ngoài ra, việc bảo trì và cập nhật phần mềm cũng sẽ được thực hiện tự động và liên tục qua mạng, đảm bảo khóa luôn được bảo vệ bởi những bản vá bảo mật mới nhất và được hưởng lợi từ các tính năng cải tiến. Điều này giúp loại bỏ những lo lắng về việc thiết bị lỗi thời hoặc thiếu an toàn, mang lại sự an tâm lâu dài cho người dùng.</p><p>\n\n</p><h2>Đánh Giá Tác Động và Tương Lai của Khóa Điện Tử</h2><p>\n\n</p><p>Sự ra đời của một hệ điều hành như <strong>Apple lockOS 26</strong> có thể tạo ra một làn sóng thay đổi lớn trong thị trường khóa điện tử và công nghệ an ninh gia đình. Ưu điểm nổi bật nhất sẽ là việc thiết lập một chuẩn mực mới về <strong>bảo mật và tích hợp hệ sinh thái</strong> mà các đối thủ khó có thể sánh kịp. Người tiêu dùng sẽ không chỉ tìm kiếm một chiếc khóa đơn thuần, mà là một giải pháp an ninh toàn diện, đáng tin cậy và liền mạch. Điều này sẽ thúc đẩy các nhà sản xuất khác phải đầu tư nhiều hơn vào việc phát triển phần mềm và khả năng tương thích, nâng cao chất lượng chung của thị trường. lockOS 26 có thể giải quyết những nhược điểm hiện tại của nhiều khóa thông minh, như giao diện phức tạp, lỗ hổng bảo mật, hoặc khả năng tích hợp kém với các thiết bị khác, mang đến một trải nghiệm thống nhất và an toàn hơn bao giờ hết. Hơn nữa, với sự tập trung vào quyền riêng tư và bảo mật dữ liệu, lockOS 26 sẽ xây dựng lòng tin mạnh mẽ từ người dùng, điều mà nhiều sản phẩm IoT hiện tại vẫn đang gặp khó khăn.</p><p>\n\n</p><p>Trong tương lai, <strong>Apple lockOS 26</strong> có thể mở đường cho những công nghệ an ninh còn tiên tiến hơn. Chúng ta có thể thấy sự xuất hiện của các <strong>khóa điện tử tự học hỏi (self-learning smart locks)</strong>, sử dụng AI để nhận diện các mẫu hình hành vi của chủ nhà và phát hiện bất thường tốt hơn, thậm chí dự đoán các mối đe dọa tiềm tàng trước khi chúng xảy ra. Ví dụ, hệ thống có thể nhận ra khi có người lạ nán lại trước cửa nhà quá lâu hoặc có dấu hiệu phá hoại và cảnh báo ngay lập tức. Khóa có thể tích hợp khả năng nhận diện cảm xúc qua giọng nói hoặc hình ảnh để đưa ra phản ứng phù hợp hơn trong các tình huống khẩn cấp. Khả năng kết nối với các dịch vụ khẩn cấp một cách tự động khi phát hiện nguy hiểm nghiêm trọng cũng là một viễn cảnh khả thi. Với một nền tảng vững chắc như lockOS 26, ranh giới giữa an ninh vật lý và an ninh mạng sẽ ngày càng mờ đi, tạo ra một hệ thống phòng thủ toàn diện và thông minh cho ngôi nhà của bạn. Đây không chỉ là một sản phẩm, mà là một tầm nhìn cho tương lai của an ninh nhà ở.</p><p>\n\n</p><h2>Kết Luận: Hướng Tới Tương Lai An Toàn và Tiện Nghi</h2><p>\n\n</p><p>Nhìn chung, một hệ điều hành như <strong>Apple lockOS 26</strong> đại diện cho một bước nhảy vọt quan trọng trong lĩnh vực khóa điện tử và an ninh gia đình. Nó không chỉ là sự kết hợp của phần cứng hiện đại và phần mềm tinh vi, mà còn là sự dung hòa giữa <strong>bảo mật tuyệt đối và trải nghiệm người dùng liền mạch</strong>. Với những tính năng bảo mật tiên tiến như mã hóa đầu cuối, Secure Enclave, công nghệ sinh trắc học Face ID/Touch ID tích hợp sâu, cùng khả năng phát hiện mối đe dọa thông minh, lockOS 26 sẽ mang đến một lớp bảo vệ vững chắc chưa từng có cho ngôi nhà của bạn. Đồng thời, khả năng tích hợp sâu rộng vào hệ sinh thái HomeKit của Apple, các kịch bản tự động hóa thông minh, điều khiển bằng giọng nói qua Siri và quản lý từ xa sẽ biến việc bảo vệ ngôi nhà trở thành một phần tiện lợi và không thể thiếu trong cuộc sống hàng ngày. lockOS 26 sẽ không chỉ bảo vệ tài sản mà còn mang lại sự an tâm và tiện nghi tối đa, định nghĩa lại khái niệm về một ngôi nhà an toàn và thông minh thực sự.</p><p>\n\n</p><p>Mặc dù <strong>Apple lockOS 26</strong> vẫn chỉ là một khái niệm trong tương lai, nhưng những tiềm năng mà nó mang lại là vô cùng to lớn. Nó cho thấy xu hướng phát triển của công nghệ an ninh gia đình đang hướng tới sự tích hợp toàn diện, thông minh và lấy người dùng làm trung tâm. Đối với người tiêu dùng, điều này có nghĩa là sự lựa chọn khóa điện tử sẽ không chỉ dựa trên mẫu mã hay thương hiệu, mà còn dựa trên nền tảng phần mềm, khả năng bảo mật và mức độ tích hợp với hệ sinh thái nhà thông minh hiện có. Chúng ta có thể kỳ vọng rằng những giải pháp tương tự sẽ tiếp tục xuất hiện, mang lại nhiều lựa chọn hơn và thúc đẩy sự đổi mới trong ngành. Cuối cùng, một hệ điều hành như lockOS 26 sẽ không chỉ đơn thuần là mở hay khóa cửa, mà là chìa khóa mở ra một tương lai nơi an ninh gia đình được nâng tầm lên một cấp độ hoàn toàn mới, vừa an toàn tuyệt đối vừa tiện lợi một cách đáng kinh ngạc, đáp ứng mọi nhu cầu của cuộc sống hiện đại.</p><p>\n\n</p><p><br></p><p>\n</p><p><br></p>', NULL, NULL, NULL, 'PUBLISHED', 'c1bfe466-b895-4570-b8d1-97b24eb1654c_SHP-DS700_1.jpg', 52, '2025-11-05 03:27:23', '2025-11-05 03:27:19', '2025-12-13 14:45:43', NULL, '945215165331759_122097440031166791', NULL),
(10, 'Chính sách Bảo hành & Đổi trả', '<h2>Điều khoản chung:</h2><p>Tất cả các sản phẩm do KVKLOCK cung cấp và phân phối đều được bảo hành theo quy định.</p><p>Các sản phẩm còn trong thời hạn bảo hành (được căn cứ phiếu bảo hành và tem bảo hành).</p><p>Hư hỏng do lỗi kỹ thuật từ nhà sản xuất.</p><h2>Các trường hợp sau đây sẽ không được bảo hành theo quy định:</h2><p>Những trường hợp sau đây sẽ không được bảo hành:</p><p>Thiết bị không có phiếu bảo hành hoặc biên bản bàn giao. Phiếu bảo hành và biên bản bàn giao đã bị sửa đổi thông tin, bị chắp nối, rách nát.</p><p>Sản phẩm biến dạng, không còn nguyên hình dạng từ nhà sản xuất.</p><p>Các thiết bị không còn nguyên tem bảo hành của hãng sản xuất, nhà phân phối. Tem bảo hành đã bị sửa đổi hoặc không chính xác, bị rách, mờ…</p><p>Sử dụng điện áp sai quy định, quá công suất của thiết bị hoặc bị cháy nổ, rơi vỡ, móp, nứt, thủng, trầy xước…</p><p>Hư hỏng do thiên tai, động vật, côn trùng hoặc lỗi do người sử dụng.</p><p>Hết thời hạn bảo hành ghi trên phiếu và biên bản bàn giao thiết bị.</p><h2>Chính sách bảo hành chi tiết:</h2><p>Hiện tại,&nbsp;<a href=\"https://vinlock.com.vn/\"><strong>Hệ thống khóa cửa điện tử K</strong></a><strong>VKLOCK</strong>&nbsp;hỗ trợ 2 hình thức bảo hành cho Quý khách hàng như sau:</p><p>Vinlock sẽ tới tận nơi bảo hành cho quý khách.</p><p>Vinlock cung cấp cho khách hàng một khóa cửa tương tự (đã qua sử dụng) để khách hàng sử dụng tạm thời nếu phải mang sản phẩm về trung tâm bảo hành. Và cung cấp cho khách hàng 1 giấy tiếp nhận bảo hành/sửa chữa dịch vụ.</p><p>Nếu khóa cửa gửi đi bảo hành quá 15 ngày mà hãng bảo hành chưa trả lại khóa cho khách hàng, Vinlock có thể hỗ trợ khách thu lại khóa hỏng với mức giá hỗ trợ.</p><p><strong>Lưu ý</strong>: Chương trình chỉ áp dụng thu mua cho&nbsp;<a href=\"https://vinlock.com.vn/danh-muc-san-pham/khoa-van-tay.html/\"><strong>khóa vân tay</strong></a>, khóa điện tử,&nbsp;<a href=\"https://vinlock.com.vn/san-pham/chuong-cua-co-man-hinh\"><strong>chuông hình</strong></a>&nbsp;và các sản phẩm khác phải còn trong điều kiện bảo hành.</p><h2>CÁC TRƯỜNG HỢP KHÔNG ĐƯỢC BẢO HÀNH, ĐỔI TRẢ:</h2><p>Sản phẩm lỗi do người sử dụng</p><p>Không đủ điều kiện bảo hành theo quy định của hãng.</p><p>Máy không giữ nguyên 100% hình dạng ban đầu.</p><p>Màn hình bị trầy xước.</p><h2>Điều kiện đổi trả:</h2><p>Còn đầy đủ hộp sản phẩm (mất hộp thu phí 5%).</p><p>Trong trường hợp máy không lên nguồn hoặc không xác định được lỗi, phải chuyển Trung Tâm Bảo Hành của Hãng thẩm định trước khi ra quyết định nhập đổi, nhập trả.</p><p>Còn đầy đủ phiếu bảo hành và phụ kiện đi kèm (Nếu mất, Vinlock sẽ thu phí theo quy định và lớn nhất là 5% trên giá hoá đơn).</p><p>Quà khuyến mãi: thu phí theo giá hoàn lại do Vinlock công bố khi bán sản phẩm. Nếu không công bố giá trị khuyến mãi thì sẽ thu phí tối đa 5% giá trị cho mỗi món quà khuyến mãi</p><figure class=\"table\"><table><tbody><tr><td>SẢN PHẨM LỖI DO NHÀ SẢN XUẤT</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td>THÁNG ĐẦU TIÊN</td><td>&nbsp;</td><td>1 đổi 1 (cùng mẫu, cùng màu…). Trường hợp sản phẩm CÙNG LOẠI hết hàng, khách hàng có thể đổi sang sản phẩm khác cùng nhóm hàng, có giá trị lớn hơn 50% giá trị của sản phẩm bị lỗi. Phần tiền chênh lệch (nếu có) Vinlock sẽ hoàn lại cho quý khách.</td><td>&nbsp;</td><td>Vinlock hoàn lại tiền khóa với mức giá bằng 80% giá trên hoá đơn hoặc theo giá bán hiện tại của sản phẩm đổi trả (đã qua sử dụng) cùng model, cùng tháng bảo hành</td><td>&nbsp;</td><td>TỪ THÁNG THỨ 2 ĐẾN THÁNG THỨ 12</td><td>&nbsp;</td><td>Gửi máy bảo hành theo quy định của hãng.</td><td>&nbsp;</td><td>Hoặc:</td><td>&nbsp;</td><td>Vinlock hoàn lại tiền với mức phí thêm 5% so với tháng thứ 1 (80%).</td><td>VD: tháng thứ 2 hoàn lại với giá 75% giá trên hoá đơn, tháng thứ 3 là 70%.</td><td>&nbsp;</td></tr><tr><td>SẢN PHẨM KHÔNG BỊ LỖI NHƯNG KHÔNG PHÙ HỢP VỚI NHU CẦU KHÁCH HÀNG</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td>THÁNG ĐẦU TIÊN</td><td>&nbsp;</td><td>Hoàn lại tiền khóa với giá bằng 80% giá trên hoá đơn hoặc theo giá bán hiện tại của sản phẩm đổi trả cùng model, cùng tháng bảo hành. Công ty nhập lại sản phẩm cũ theo điều khoản “trả lại hàng” đồng thời xuất bán lại sản phẩm mới.</td><td>&nbsp;</td><td>Phần chênh lệch giá là khoản phí sử dụng khách hàng phải trả và công ty sẽ xuất hoá đơn giá trị gia tăng (GTGT) cho khoản phí này.</td><td>&nbsp;</td><td>TỪ THÁNG THỨ 2 ĐẾN THÁNG THỨ 12</td><td>&nbsp;</td><td>Hoàn lại tiền với mức phí thêm 5% so với tháng thứ 1 (80%). VD: tháng thứ 2 hoàn lại tiền với mức giá 75% giá trên hoá đơn, tháng thứ 3 là 70%.</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td>SẢN PHẨM LỖI DO NGƯỜI SỬ DỤNG</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td>=&gt; Không áp dụng bảo hành, đổi trả. Vinlock hỗ trợ chuyển bảo hành, khách hàng chịu chi phí sửa chữa khóa điện tử,&nbsp;<a href=\"https://vinlock.com.vn/danh-muc-san-pham/khoa-van-tay.html/\"><strong>khóa vân tay&nbsp;</strong></a>và các sản phẩm khác.</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr></tbody></table></figure><p><a href=\"https://vinlock.com.vn/\"><strong>Hệ thống khóa cửa điện tử VINLOCK</strong></a>&nbsp;luôn lắng nghe và thấu hiểu mọi phản hồi, góp ý từ quý khách hàng để hoàn thiện dịch vụ mỗi ngày, nhằm mang đến sự hài lòng và tiện nghi, thoải mái nhất cho khách hàng.</p><p>Đừng ngần ngại chia sẻ cùng chúng tôi!</p><p>Xin chân thành cảm ơn Quý khách hàng đã – đang và sẽ tin dùng sản phẩm &amp; dịch vụ của Vinlock!</p><p>&nbsp;</p><p>&nbsp;</p><p>&nbsp;</p>', NULL, NULL, NULL, 'PUBLISHED', 'e5cd800b-b7d4-4a7c-b0b0-2ab545f0d52c_Screenshot 2025-11-06 100002.png', 16, '2025-11-16 13:51:05', '2025-11-16 13:51:00', '2025-12-17 04:49:39', NULL, '945215165331759_122096948289166791', NULL),
(11, 'Chính sách vận chuyển ', '<h2>I. Giao hàng nhanh:&nbsp;Giao hàng tận nơi miễn phí từ 30 phút – 2 tiếng</h2><p>&nbsp;</p><figure class=\"table\"><table><tbody><tr><td>Chờ đợi xứng đáng</td><td>fsddddđffsd</td><td>sdfsdfsdf</td></tr><tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr></tbody></table></figure><p>&nbsp;</p><figure class=\"table\"><table><tbody><tr><td>adasdasdfasdf</td><td>sadfsd</td><td>sadfsdafsadf</td></tr><tr><td>sadfsadfsad</td><td>sadfsadfsadfsa</td><td>&nbsp;</td></tr><tr><td>sadfsadfsadf</td><td>&nbsp;</td><td>ấdfasdf</td></tr><tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr></tbody></table></figure><p>&nbsp;</p><blockquote><p>Giao hàng tận nơi, miễn phí trong vòng 30 phút – 2 tiếng</p></blockquote><p>Phạm vi áp dụng: Những khu vực tỉnh thành có Showroom/ đại lý ủy quyền của Vinlock</p><p>Vinlock nhận&nbsp;<strong>giao nhanh trong ngày</strong>&nbsp;trong phạm vi bán kính 20 km. Với khoảng cách lớn hơn, chúng tôi sẽ tư vấn cách thức giao hàng thuận tiện nhất cho khách hàng. Vui lòng liên hệ hotline 24/24: 091 999 3486 / 091 999 4686 để được tư vấn cụ thể.</p><p>Với các đơn hàng được xác nhận trong khoảng thời gian 7h30 –21h00:</p><p><i>Phạm vi bán kính dưới 5km:</i>&nbsp;giao hàng trong vòng 30 phút kể từ lúc xác nhận đơn hàng</p><p><i>Phạm vi bán kính từ 5km – 10km:</i>&nbsp;giao hàng trong vòng 01 tiếng kể từ lúc xác nhận đơn hàng</p><p><i>Phạm vi bán kính từ 10km – 20km:</i>&nbsp;giao hàng trong vòng 02 tiếng kể từ lúc xác nhận đơn hàng</p><p>Đơn hàng được xác nhận từ 21h00 – 7h30 sáng hôm sau : Giao trước 9h00 sáng hôm sau hoặc theo yêu cầu khác của khách hàng</p><p><strong>Đặc biệt:</strong>&nbsp;Quý khách hàng được lựa chọn sản phẩm tại nhà (3 mẫu): Nếu có sự phân vân trong việc lựa chọn sản phẩm, hãy để nhân viên giao hàng của chúng tôi mang hơn 2 sản phẩm theo yêu cầu của bạn đến tận nơi để bạn lựa chọn.</p><h2>II. Lắp đặt miễn phí</h2><p><i>Phạm vi áp dụng</i>:</p><p>Những khu vực tỉnh thành có Showroom hoặc đại lý ủy quyền của Vinlock.</p><p>Do yếu tố kỹ thuật, Vinlock chỉ hỗ trợ lắp đặt Khóa cửa điện tử,&nbsp;<a href=\"https://vinlock.com.vn/danh-muc-san-pham/khoa-van-tay.html/\"><strong>khóa cửa vân tay</strong></a>&nbsp;và Chuông cửa có hình, Máy chấm công, kiểm soát ra vào.</p><p><i>Thời gian lắp đặt:</i></p><p>Vinlock nhận&nbsp;<strong>lắp đặt trong ngày</strong>&nbsp;với khoảng cách từ các Showroom đến điểm giao là 50 km. Khoảng cách lớn hơn nhân viên của chúng tôi sẽ tư vấn cách thức lắp đặt thuận tiện nhất cho khách hàng.</p><p>Thời gian lắp đặt từ 7h00 –21h00.</p><p><strong>MIỄN PHÍ</strong>&nbsp;lắp đặt cho sản phẩm Khóa cửa điện tử có khoảng cách dưới 20km tính từ Showroom hoặc đại lý ủy quyền của Vinlock. Trên 20km: chúng tôi có thể tính phí tùy thuộc vào từng khu vực.</p><p><strong>Đặc biệt:</strong>&nbsp;Quý khách hàng được&nbsp;<strong>lựa chọn sản phẩm tại nhà</strong>&nbsp;(3 mẫu): Nếu có sự phân vân trong việc lựa chọn sản phẩm, hãy để nhân viên giao hàng của chúng tôi mang hơn 2 sản phẩm theo yêu cầu của bạn đến tận nơi để bạn lựa chọn.</p><p>Do khối lượng và thể tích hàng hóa lớn, chúng tôi chỉ có thể mang tối đa 3 mẫu để bạn lựa chọn.</p><p><strong>Lưu ý:</strong></p><p>Quý khách chỉ thanh toán khi thật sự hài lòng với sản phẩm và chất lượng dịch vụ của chúng tôi. Chúng tôi sẽ không tính bất kỳ khoản phí nào cho đến khi Quý khách hoàn toàn đồng ý.</p><p>Khách hàng có thể thanh toán ngay bằng các thẻ quốc tế, nội địa mà không cần phải ra ngân hàng rút tiền mặt trước.</p><p>Hãy gọi cho chúng tôi bất cứ lúc nào Quý khách cần được phục vụ với chất lượng 5 sao hoàn hảo.</p><h2>III. Quy trình lắp đặt tại nhà</h2><p>Gọi điện tư vấn và đặt lịch lắp đặt sản</p><p>Đến nhà tiếp nhận thông tin nơi lắp đặt và hướng dẫn thêm về sản phẩm</p><p>Lắp đặt sản phẩm</p><p>Thanh toán</p><h2>Một số trường hợp đặc biệt:</h2><p>Giá trị đơn hàng quá lớn; thời gian giao hàng vào buổi tối, địa chỉ giao hàng không rõ ràng, nằm trong ngõ ngách, hoặc ở những nơi nguy hiểm, những vùng đồi núi hiểm trở, phương tiện giao thông đi lại khó khăn, Chúng tôi sẽ chủ động liên lạc với quý khách để thống nhất lại thời gian và cách thức giao hàng cụ thể.</p><p>Trong trường hợp giao hàng chậm trễ mà không báo trước, quý khách có thể từ chối nhận hàng và chúng tôi sẽ hoàn trả toàn bộ số tiền mà quý khách trả trước (nếu có) trong vòng 7 ngày.</p><p><a href=\"https://vinlock.com.vn/\"><strong>Hệ thống khóa cửa điện tử Vinlock</strong></a>&nbsp;<strong>cam kết</strong>&nbsp;tất cả hàng hóa gửi đến quý khách đều là&nbsp;<strong>hàng chính hãng mới 100%</strong>&nbsp;(có đầy đủ hóa đơn, được bảo hành chính thức). Những rủi ro phát sinh trong quá trình vận chuyển (va đập, ẩm ướt, tai nạn…) có thể ảnh hưởng đến chất lượng hàng hóa, vì thế, để đảm bảo quyền lợi, Quý Khách vui lòng&nbsp;<strong>kiểm tra hàng hóa thật kỹ</strong>&nbsp;trước khi ký nhận. Vinlock sẽ không chịu trách nhiệm với những lỗi của hàng hoá sau khi Quý khách đã ký nhận hàng.</p><p>&nbsp;</p>', NULL, NULL, NULL, 'PUBLISHED', '87df6962-b590-456f-95f4-ab2205f1728d_577770633_821522700614408_6417169123923730341_n.jpg', 46, '2025-11-16 13:51:41', '2025-11-16 13:51:41', '2025-12-14 16:01:30', NULL, '945215165331759_122096554647166791', NULL);

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
  `vnp_transaction_no` varchar(255) DEFAULT NULL,
  `tracking_number` varchar(255) DEFAULT NULL,
  `carrier` varchar(255) DEFAULT NULL,
  `district_id` int DEFAULT NULL,
  `ward_code` varchar(50) DEFAULT NULL,
  `assigned_staff_id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Đang đổ dữ liệu cho bảng `orders`
--

INSERT INTO `orders` (`id`, `user_id`, `fullname`, `email`, `phone_number`, `address`, `note`, `order_date`, `status`, `total_money`, `shipping_method`, `shipping_date`, `payment_method`, `active`, `voucher_id`, `discount_amount`, `payment_intent_id`, `vnp_txn_ref`, `vnp_transaction_no`, `tracking_number`, `carrier`, `district_id`, `ward_code`, `assigned_staff_id`) VALUES
(92, 18, 'Truong Quang Lap', 'secroramot123@gmail.com', '0854768836', 'Mình Loc', 'àdasfadsfdsafsadfasdf', '2025-06-13 00:00:00', 'canceled', 29030000, 'Tiêu chuẩn', '2025-06-16', 'Thanh toán thẻ thành công', 1, NULL, 0, 'pi_3RZW4FRoKh7pvaZe1sbaN2MH', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(94, 18, 'Lap Truong Quang', 'lapduynh72@gmail.com', '0854768836', 'Mình Loc, Xã Minh Lộc, Huyện Hậu Lộc, Tỉnh Thanh Hóa', '', '2025-11-06 02:15:09', 'delivered', 3450000, 'Tiêu chuẩn', '2025-11-09', 'Cash', 1, 11, 380000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(95, 18, 'Lap Truong Quang', 'lapduynh72@gmail.com', '0854768836', 'Mình Loc, Xã Cổ Bi, Huyện Gia Lâm, Thành phố Hà Nội', '', '2025-11-06 14:45:09', 'delivered', 7680000, 'Tiêu chuẩn', '2025-11-09', 'VNPAY', 1, 11, 850000, NULL, '87117391', NULL, NULL, NULL, NULL, NULL, NULL),
(96, 18, 'Truong Quang Lap', 'secroramot123@gmail.com', '0854768836', 'Minh Thinh, Xã Minh Lộc, Huyện Hậu Lộc, Tỉnh Thanh Hóa', '', '2025-11-18 11:31:23', 'delivered', 8530000, 'Tiêu chuẩn', '2025-11-21', 'VNPAY', 1, NULL, 0, NULL, '18008204', NULL, NULL, NULL, NULL, NULL, NULL),
(97, 18, 'Truong Quang Lap', 'secroramot123@gmail.com', '0854768836', 'Mình Loc, Xã Bình Trưng, Huyện Châu Thành, Tỉnh Tiền Giang', '', '2025-12-12 03:56:47', 'delivered', 8530000, 'Tiêu chuẩn', '2025-12-15', 'VNPAY', 1, NULL, 0, NULL, '18902943', NULL, NULL, NULL, NULL, NULL, NULL),
(98, 18, 'Truong Quang Lap', 'lapduynh72@gmail.com', '0854768836', 'Minh Thinh, Xã Đồng Tháp, Huyện Đan Phượng, Thành phố Hà Nội', '', '2025-12-12 09:17:16', 'delivered', 8540000, 'Nhanh', '2025-12-15', 'Cash', 1, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(99, 18, 'Lap Truong Quang', 'lapduynh72@gmail.com', '0854768836', 'Mình Loc, Xã Dương Quang, Huyện Gia Lâm, Thành phố Hà Nội', '', '2025-12-12 09:28:53', 'processing', 23334432, 'Tiêu chuẩn', '2025-12-15', 'Cash', 1, NULL, 0, NULL, NULL, NULL, NULL, NULL, 18, '568', NULL),
(100, 18, 'Truong Quang Lap', 'secroramot123@gmail.com', '0854768836', 'Mình Loc, Xã Bắc Hưng, Huyện Tiên Lãng, Thành phố Hải Phòng', '', '2025-12-12 09:31:17', 'processing', 8530000, 'Tiêu chuẩn', '2025-12-15', 'Cash', 1, NULL, 0, NULL, NULL, NULL, NULL, NULL, 315, '11803', NULL),
(101, 18, 'Truong Quang Lap', 'secroramot123@gmail.com', '0854768836', '112 Mình Loc, Phường Đại Mỗ, Quận Nam Từ Liêm, Thành phố Hà Nội', '', '2025-12-12 09:47:13', 'processing', 5520000, 'Tiêu chuẩn', '2025-12-15', 'Cash', 1, NULL, 0, NULL, NULL, NULL, NULL, NULL, 19, '634', NULL),
(105, 18, 'Lap Truong Quang', 'lapduynh72@gmail.com', '0854768836', 'Mình Loc, Xã Đại Mạch, Huyện Đông Anh, Thành phố Hà Nội', '', '2025-12-12 10:21:14', 'delivered', 23334432, 'Tiêu chuẩn', '2025-12-15', 'Cash', 1, NULL, 0, NULL, NULL, NULL, NULL, NULL, 17, '499', NULL),
(106, 18, 'Truong Quang Lap', 'secroramot123@gmail.com', '0854768836', 'Mình Loc, Xã Cổ Bi, Huyện Gia Lâm, Hà Nội', '', '2025-12-12 10:45:12', 'delivered', 23334432, 'Tiêu chuẩn', '2025-12-15', 'Cash', 1, NULL, 0, NULL, NULL, NULL, NULL, NULL, 1703, '1A1204', NULL),
(107, 18, 'Truong Quang Lap', 'secroramot123@gmail.com', '0854768836', 'Mình Loc, Xã Cát Quế, Huyện Hoài Đức, Hà Nội', '', '2025-12-12 10:45:36', 'shipped', 8530000, 'Tiêu chuẩn', '2025-12-15', 'Cash', 1, NULL, 0, NULL, NULL, NULL, 'LKH4A8', 'GHN', 1805, '1B2304', NULL),
(108, 18, 'Truong Quang Lap', 'secroramot123@gmail.com', '0854768836', 'Mình Loc, Xã Dun, Huyện Chư Sê, Gia Lai', '', '2025-12-12 11:13:52', 'payment_failed', 3320000, 'Tiêu chuẩn', '2025-12-15', 'VNPAY', 1, NULL, 0, NULL, '18845574', NULL, 'LKHKUG', 'GHN', 1796, '380907', NULL),
(109, 18, 'Truong Quang Lap', 'secroramot123@gmail.com', '0854768836', 'Mình Loc, Xã Giáp Sơn, Huyện Lục Ngạn, Bắc Giang', '', '2025-12-12 11:19:28', 'delivered', 8530000, 'Tiêu chuẩn', '2025-12-15', 'Thanh toán thẻ thành công', 1, NULL, 0, 'pi_3SdUOWRoKh7pvaZe08SqVoO6', NULL, NULL, 'LKHKVF', 'GHN', 1966, '180307', NULL),
(110, 18, 'Truong Quang Lap', 'secroramot123@gmail.com', '0854768836', 'Mình Loc, Xã An Lạc, Huyện Sơn Động, Bắc Giang', '', '2025-12-12 11:27:09', 'delivered', 8530000, 'Tiêu chuẩn', '2025-12-15', 'Cash', 1, NULL, 0, NULL, NULL, NULL, 'LKHKPB', 'GHN', 1761, '180405', NULL),
(111, 18, 'Truong Quang Lap', 'secroramot123@gmail.com', '0854768836', 'Mình Loc, Xã Đa Lộc, Huyện Hậu Lộc, Thanh Hóa', '', '2025-12-12 11:57:10', 'delivered', 3830000, 'Tiêu chuẩn', '2025-12-15', 'Cash', 1, NULL, 0, NULL, NULL, NULL, 'LKHKM3', 'GHN', 1942, '282404', NULL),
(112, 18, 'Truong Quang Lap', 'secroramot123@gmail.com', '0854768836', 'Minh Thinh, Phường Mỹ Đình 1, Quận Nam Từ Liêm, Hà Nội', '', '2025-12-13 02:28:36', 'delivered', 5490000, 'Nhanh', '2025-12-16', 'VNPAY', 1, NULL, 0, NULL, '53301153', '15338359', 'LKH87F', 'GHN', 3440, '13004', NULL),
(113, 18, 'Lap', 'lapduynh72@gmail.com', '0543345345', 'adasdadsad, Xã Đa Lộc, Huyện Hậu Lộc, Thanh Hóa', '', '2025-12-13 02:45:00', 'delivered', 3480000, 'Nhanh', '2025-12-16', 'Cash', 1, NULL, 0, NULL, NULL, NULL, 'LKH89P', 'GHN', 1942, '282404', NULL),
(114, 20, 'LOL  ESPORT', 'laptq.b21cn073@stu.ptit.edu.vn', '0358281003', 'ádasdasdas 123, Phường Nhật Tân, Quận Tây Hồ, Hà Nội', '', '2025-12-13 05:04:53', 'cancelled', 50408864, 'Nhanh', '2025-12-16', 'Cash', 1, NULL, 0, NULL, NULL, NULL, NULL, NULL, 1492, '1A0502', NULL),
(115, 20, 'Lap Truong Quang', 'lapduynh72@gmail.com', '0854768836', 'Mình Loc, Xã Hưng Thành, Huyện Vĩnh Lợi, Bạc Liêu', '', '2025-12-13 05:13:21', 'processing', 48827978, 'Nhanh', '2025-12-16', 'Cash', 1, 11, 5420886, NULL, NULL, NULL, 'LKHRQN', 'GHN', 2050, '600205', NULL),
(116, 20, 'Lap Truong Quang', 'lapduynh72@gmail.com', '0854768836', 'Mình Loc, Xã Hoà Mục, Huyện Chợ Mới, Bắc Kạn', '', '2025-12-13 05:20:13', 'delivered', 29000000, 'Nhanh', '2025-12-16', 'Thanh toán thẻ thành công', 1, NULL, 0, 'pi_3SdlFpRoKh7pvaZe16KUhGjQ', NULL, NULL, NULL, NULL, 1914, '11074', NULL),
(117, 20, 'Lap Truong Quang', 'lapduynh72@gmail.com', '0854768836', 'Mình Loc, Phường Phú Đô, Quận Nam Từ Liêm, Hà Nội', '', '2025-12-13 05:30:19', 'delivered', 46608864, 'Nhanh', '2025-12-16', 'Cash', 1, NULL, 0, NULL, NULL, NULL, 'LKHRV4', 'GHN', 3440, '13006', NULL),
(118, 18, 'Truong Quang Lap', 'secroramot123@gmail.com', '0854768836', 'Minh Thinh, Xã Mai Lạp, Huyện Chợ Mới, Bắc Kạn', '', '2025-12-13 08:12:29', 'processing', 8500000, 'Nhanh', '2025-12-16', 'Cash', 1, NULL, 0, NULL, NULL, NULL, NULL, NULL, 1914, '11075', NULL),
(119, 18, 'Truong Quang Lap', 'secroramot123@gmail.com', '0854768836', 'Minh Thinh, Xã Lạc Vệ, Huyện Tiên Du, Bắc Ninh', '', '2025-12-13 08:16:36', 'processing', 23304432, 'Nhanh', '2025-12-16', 'Cash', 1, NULL, 0, NULL, NULL, NULL, 'LKHETL', 'GHN', 1729, '190406', NULL),
(120, 20, 'Lap Truong Quang', 'lapduynh72@gmail.com', '0854768836', 'Mình Loc, Phường Mỹ Đình 1, Quận Nam Từ Liêm, Hà Nội', '', '2025-12-13 13:16:11', 'delivered', 46668864, 'Hỏa tốc', '2025-12-16', 'Cash', 1, NULL, 0, NULL, NULL, NULL, NULL, NULL, 3440, '13004', 19),
(121, 20, 'Lap Truong Quang', 'lapduynh72@gmail.com', '0854768836', 'Mình Loc, Phường Kiến Hưng, Quận Hà Đông, Hà Nội', '', '2025-12-13 14:01:05', 'delivered', 23364432, 'Hỏa tốc', '2025-12-16', 'Cash', 1, NULL, 0, NULL, NULL, NULL, NULL, NULL, 1542, '1B1505', 19),
(122, 20, 'Truong Quang Lap', 'secroramot123@gmail.com', '0854768836', 'Mình Loc, Xã Minh Long, Huyện Chơn Thành, Bình Phước', '', '2025-12-14 05:47:21', 'shipped', 50408864, 'Nhanh', '2025-12-17', 'VNPAY', 1, NULL, 0, NULL, '50186150', '15340097', 'LKXDAQ', 'GHN', 1772, '430304', NULL);

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
(127, 94, 17, 3800000, 1, 3800000, NULL),
(128, 95, 3, 8500000, 1, 8500000, NULL),
(129, 96, 3, 8500000, 1, 8500000, NULL),
(130, 97, 3, 8500000, 1, 8500000, NULL),
(131, 98, 3, 8500000, 1, 8500000, NULL),
(132, 99, 5788, 23304432, 1, 23304432, NULL),
(133, 100, 3, 8500000, 1, 8500000, NULL),
(134, 101, 2, 5490000, 1, 5490000, NULL),
(138, 105, 5788, 23304432, 1, 23304432, NULL),
(139, 107, 3, 8500000, 1, 8500000, NULL),
(140, 108, 5, 3290000, 1, 3290000, NULL),
(141, 109, 3, 8500000, 1, 8500000, NULL),
(142, 110, 3, 8500000, 1, 8500000, NULL),
(143, 111, 17, 3800000, 1, 3800000, NULL),
(144, 112, 2, 5490000, 1, 5490000, NULL),
(145, 113, 6, 3480000, 1, 3480000, NULL),
(146, 114, 17, 3800000, 1, 3800000, 0),
(147, 114, 5788, 23304432, 2, 46608864, 0),
(148, 115, 5788, 23304432, 2, 46608864, 0),
(149, 115, 17, 3800000, 2, 7600000, 0),
(150, 116, 5784, 29000000, 1, 29000000, 0),
(151, 117, 5788, 23304432, 2, 46608864, 0),
(152, 118, 3, 8500000, 1, 8500000, NULL),
(153, 119, 5788, 23304432, 1, 23304432, NULL),
(154, 120, 5788, 23304432, 2, 46608864, 0),
(155, 121, 5788, 23304432, 1, 23304432, NULL),
(156, 122, 5788, 23304432, 2, 46608864, 0),
(157, 122, 17, 3800000, 1, 3800000, 0);

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
(1, 'Khóa vân tay GATEMAN FINGUS (WF-20)', 6500000, 'WF20_1 3-4.jpg', '<p></p><h2>Khóa Vân Tay GATEMAN FINGUS (WF-20) – An Toàn Tối Ưu, Tiện Nghi Vượt Trội</h2><p>Trong kỷ nguyên công nghệ số, bảo vệ không gian sống và làm việc không chỉ là nhu cầu mà còn là nghệ thuật. Locker Korea tự hào giới thiệu siêu phẩm khóa vân tay GATEMAN FINGUS (WF-20) – một biểu tượng của sự sang trọng, hiện đại và bảo mật tuyệt đối đến từ thương hiệu khóa điện tử hàng đầu GATEMAN. FINGUS (WF-20) không chỉ là một thiết bị an ninh mà còn là một phần không thể thiếu, nâng tầm đẳng cấp cho mọi không gian. Với sự kết hợp hoàn hảo giữa công nghệ nhận diện vân tay tiên tiến và khả năng mở khóa bằng thẻ từ tiện lợi, sản phẩm này mang đến trải nghiệm an toàn, nhanh chóng và tinh tế cho mọi thành viên trong gia đình hoặc môi trường công sở. Hãy khám phá một giải pháp an ninh đột phá, nơi sự an tâm và tiện lợi giao thoa hoàn hảo.</p><h3>Đặc Điểm Nổi Bật</h3><h4>1. Công Nghệ Vân Tay FPC Thụy Điển – Bảo Mật Không Thể Xâm Phạm</h4><p>GATEMAN FINGUS (WF-20) được trang bị cảm biến vân tay FPC tiên tiến nhất từ Thụy Điển, một công nghệ sinh trắc học đã được chứng minh về độ chính xác và bảo mật. Khác với các cảm biến quang học truyền thống, FPC quét vân tay dựa trên cảm biến áp suất và nhiệt độ, cho phép nhận diện sâu các đặc điểm vân tay, từ đó loại bỏ hoàn toàn khả năng làm giả bằng silicon, keo dán hay ảnh chụp. Quá trình nhận diện diễn ra chỉ trong tích tắc, dưới 0.5 giây, đảm bảo việc mở cửa nhanh chóng và thuận tiện mà vẫn giữ vững tường thành bảo mật vững chắc nhất cho ngôi nhà hay văn phòng của bạn. Đây là sự lựa chọn tối ưu cho những ai đặt tiêu chí an toàn lên hàng đầu.</p><h4>2. Mở Khóa Bằng Thẻ Từ Tiện Lợi – Giải Pháp Cho Mọi Thành Viên</h4><p>Bên cạnh công nghệ vân tay, GATEMAN FINGUS (WF-20) còn tích hợp khả năng mở khóa bằng thẻ từ thông minh. Tính năng này đặc biệt hữu ích cho những người lớn tuổi, trẻ nhỏ hoặc những ai gặp khó khăn với việc nhận diện vân tay. Với khả năng lưu trữ lên đến 40 thẻ từ RFID, bạn có thể dễ dàng cấp phát và quản lý quyền truy cập cho từng thành viên trong gia đình hoặc nhân viên trong văn phòng một cách linh hoạt. Thẻ từ được mã hóa riêng biệt, cực kỳ nhỏ gọn và dễ dàng mang theo, mang lại sự tiện lợi tối đa mà không hề ảnh hưởng đến yếu tố an ninh. Đây là một giải pháp hoàn hảo để đảm bảo mọi người đều có thể vào nhà một cách dễ dàng và an toàn.</p><h4>3. Thiết Kế Sang Trọng, Đẳng Cấp – Nâng Tầm Kiến Trúc</h4><p>GATEMAN FINGUS (WF-20) không chỉ là một thiết bị an ninh mà còn là một tác phẩm nghệ thuật góp phần tô điểm cho không gian sống của bạn. Với thiết kế hiện đại, tinh tế và tối giản, sản phẩm này dễ dàng hòa nhập và làm nổi bật vẻ đẹp của mọi loại cửa, từ phong cách cổ điển đến hiện đại. Vỏ ngoài được chế tác từ hợp kim kẽm nguyên khối cao cấp, kết hợp với các đường nét bo tròn mềm mại và lớp phủ bề mặt chống trầy xước, chống bám vân tay, mang lại vẻ ngoài luôn sáng bóng và bền bỉ theo thời gian. Màu sắc trung tính, sang trọng giúp khóa vân tay FINGUS (WF-20) trở thành điểm nhấn tinh tế, thể hiện gu thẩm mỹ và đẳng cấp của gia chủ.</p><h4>4. Chức Năng Bảo Mật Kép Nâng Cao – An Toàn Tuyệt Đối</h4><p>Để đảm bảo an ninh ở mức độ cao nhất, GATEMAN FINGUS (WF-20) tích hợp nhiều tính năng bảo mật kép vượt trội. Chế độ &quot;mã số ảo&quot; cho phép bạn nhập thêm các số ngẫu nhiên trước hoặc sau mật khẩu chính, ngăn chặn kẻ gian đọc trộm mật khẩu qua dấu vân tay trên màn hình. Tính năng &quot;khóa trái từ bên trong&quot; (Double Lock) vô hiệu hóa mọi thao tác mở cửa từ bên ngoài, mang lại sự riêng tư và an toàn tuyệt đối khi bạn ở trong nhà. Ngoài ra, chức năng báo động chống phá khóa, đột nhập trái phép sẽ được kích hoạt ngay lập tức nếu có bất kỳ hành vi cố ý phá hoại nào, gửi cảnh báo đến bạn và những người xung quanh.</p><h4>5. Cảnh Báo Thông Minh Đa Lớp – Luôn Luôn An Tâm</h4><p>Sự an tâm của người dùng luôn là ưu tiên hàng đầu của GATEMAN. FINGUS (WF-20) được trang bị hệ thống cảnh báo thông minh đa lớp, mang đến sự bảo vệ toàn diện. Khóa sẽ tự động phát ra âm thanh cảnh báo lớn nếu phát hiện dấu hiệu cạy phá, đột nhập bất hợp pháp hoặc cố gắng mở cửa bằng phương pháp không hợp lệ. Đặc biệt, cảm biến nhiệt tích hợp sẽ kích hoạt báo động cháy nổ khi nhiệt độ bên trong vượt quá ngưỡng cho phép, đồng thời tự động mở khóa để tạo điều kiện thoát hiểm an toàn. Hệ thống còn cảnh báo khi pin yếu, giúp bạn thay pin kịp thời, tránh tình trạng gián đoạn hoạt động. Với FINGUS (WF-20), bạn luôn được thông báo và bảo vệ.</p><h4>6. Dễ Dàng Lắp Đặt &amp; Sử Dụng – Phù Hợp Mọi Lứa Tuổi</h4><p>GATEMAN FINGUS (WF-20) được thiết kế với tiêu chí thân thiện với người dùng, đảm bảo mọi thao tác cài đặt và sử dụng đều diễn ra một cách đơn giản, trực quan. Quy trình lắp đặt không quá phức tạp, có thể thực hiện bởi đội ngũ kỹ thuật viên chuyên nghiệp của Locker Korea trong thời gian ngắn. Giao diện người dùng rõ ràng, hệ thống hướng dẫn bằng giọng nói (tùy chọn) giúp người dùng dễ dàng thiết lập và quản lý vân tay, thẻ từ mà không cần đến sự hỗ trợ kỹ thuật phức tạp. Thiết kế tay nắm cửa dạng đẩy/kéo tiện lợi giúp việc mở cửa trở nên nhẹ nhàng, phù hợp cho cả trẻ nhỏ và người lớn tuổi, mang lại sự tiện nghi tối đa trong cuộc sống hàng ngày.</p><h4>7. Độ Bền Vượt Thời Gian – Cam Kết Chất Lượng</h4><p>GATEMAN là thương hiệu nổi tiếng với độ bền vượt trội, và FINGUS (WF-20) không phải là ngoại lệ. Sản phẩm được sản xuất theo quy trình nghiêm ngặt, trải qua hàng loạt kiểm tra chất lượng khắt khe để đảm bảo khả năng hoạt động ổn định và bền bỉ trong mọi điều kiện môi trường. Khóa có khả năng chịu lực tác động mạnh, chống ăn mòn và chống sốc điện hiệu quả. Toàn bộ linh kiện điện tử bên trong được bảo vệ bởi lớp vỏ chắc chắn và công nghệ chống ẩm, chống bụi, đảm bảo tuổi thọ lâu dài. Với GATEMAN FINGUS (WF-20), bạn không chỉ mua một sản phẩm mà còn đầu tư vào sự an tâm và độ bền bỉ đã được kiểm chứng.</p><h3>Công Nghệ &amp; Chất Liệu</h3><p>GATEMAN FINGUS (WF-20) là sự kết hợp hoàn hảo giữa những công nghệ tiên tiến nhất và các vật liệu cao cấp, tạo nên một sản phẩm khóa điện tử đỉnh cao về hiệu suất và độ bền. Trái tim của hệ thống bảo mật là <strong>cảm biến vân tay FPC (Fingerprint Cards AB) từ Thụy Điển</strong>, công nghệ sinh trắc học hàng đầu thế giới. Cảm biến này sử dụng công nghệ nhận diện bán dẫn điện dung, quét chi tiết các đặc điểm độc đáo của vân tay ở lớp hạ bì, giúp phân biệt vân tay thật với các vật liệu làm giả một cách chính xác tuyệt đối, giảm thiểu tối đa tỷ lệ từ chối sai và chấp nhận sai. Mọi dữ liệu vân tay và thẻ từ đều được mã hóa bằng <strong>thuật toán bảo mật AES-128 bit</strong>, đảm bảo thông tin cá nhân của bạn được bảo vệ an toàn khỏi các mối đe dọa từ bên ngoài.</p><p>Về mặt vật liệu, FINGUS (WF-20) được chế tạo từ <strong>hợp kim kẽm đúc nguyên khối</strong> cao cấp, mang lại độ cứng cáp và khả năng chống va đập vượt trội. Bề mặt khóa được xử lý bằng công nghệ <strong>phủ Nano PVD (Physical Vapor Deposition)</strong> tiên tiến, không chỉ tạo nên vẻ ngoài sang trọng, bền màu mà còn chống trầy xước, chống ăn mòn hiệu quả trước tác động của thời tiết và hóa chất. Phần tay nắm được thiết kế với <strong>lõi thép cường lực</strong> bên trong, đảm bảo độ chắc chắn và chịu lực cao. Các chi tiết bên trong sử dụng nhựa ABS chống cháy chất lượng cao, tăng cường khả năng chịu nhiệt và đảm bảo an toàn cho người sử dụng trong trường hợp hỏa hoạn. Hệ thống mạch điện được thiết kế thông minh, sử dụng <strong>chip xử lý tốc độ cao</strong> và được bọc chống ẩm, chống bụi, đảm bảo hoạt động ổn định và bền bỉ qua thời gian.</p><h3>Ứng Dụng Thực Tế</h3><p>Khóa vân tay GATEMAN FINGUS (WF-20) với sự kết hợp hoàn hảo giữa công nghệ hiện đại và thiết kế tinh tế, là lựa chọn lý tưởng cho nhiều loại hình không gian và đối tượng người dùng khác nhau. Đây là giải pháp an ninh vượt trội cho <strong>các căn hộ chung cư cao cấp, biệt thự sang trọng</strong>, nơi yêu cầu cao về bảo mật và tính thẩm mỹ. Gia đình có trẻ nhỏ và người lớn tuổi sẽ đặc biệt yêu thích FINGUS (WF-20) bởi sự dễ dàng trong việc mở khóa bằng vân tay hoặc thẻ từ, không còn loay hoay với chìa khóa cơ truyền thống, giúp mọi thành viên ra vào nhà một cách thuận tiện và an toàn tuyệt đối.</p><p>Ngoài ra, GATEMAN FINGUS (WF-20) cũng là lựa chọn hoàn hảo cho <strong>các văn phòng làm việc, phòng ban cần kiểm soát truy cập</strong>, hay các cửa hàng, studio nhỏ. Khả năng quản lý nhiều vân tay và thẻ từ giúp chủ doanh nghiệp dễ dàng cấp quyền truy cập cho nhân viên, đồng thời dễ dàng loại bỏ quyền truy cập khi cần thiết. Đối với những người bận rộn, thường xuyên di chuyển, việc không cần mang theo chìa khóa vật lý sẽ mang lại sự tự do và tiện lợi tối đa. FINGUS (WF-20) không chỉ bảo vệ tài sản mà còn mang đến sự an tâm, nâng cao chất lượng cuộc sống và làm việc, biến cánh cửa của bạn trở thành một cổng an ninh thông minh, linh hoạt và đáng tin cậy.</p><h3>Kết Luận</h3><blockquote>Đầu tư vào GATEMAN FINGUS (WF-20) là đầu tư vào sự an tâm, tiện nghi và đẳng cấp. Hãy để Locker Korea đồng hành cùng bạn trên hành trình kiến tạo một không gian sống và làm việc hiện đại, an toàn hơn bao giờ hết.</blockquote><p>Với khóa vân tay GATEMAN FINGUS (WF-20), bạn không chỉ sở hữu một thiết bị an ninh thông thường mà còn là một giải pháp toàn diện cho cuộc sống hiện đại. Sự kết hợp giữa công nghệ vân tay FPC Thụy Điển hàng đầu, tính năng mở khóa bằng thẻ từ linh hoạt, thiết kế sang trọng và khả năng bảo mật đa lớp đã tạo nên một sản phẩm hoàn hảo. FINGUS (WF-20) mang lại sự yên bình tuyệt đối cho tâm trí bạn, giúp bạn tận hưởng cuộc sống mà không phải lo lắng về an ninh. Hãy nói lời tạm biệt với những chiếc chìa khóa cồng kềnh và chào đón kỷ nguyên của sự tiện lợi, an toàn tối ưu. Lựa chọn GATEMAN FINGUS (WF-20) từ Locker Korea chính là lựa chọn sự tinh hoa của công nghệ bảo mật, nâng tầm giá trị cho không gian sống và làm việc của bạn.</p>', '2024-02-16 16:46:58', '2025-12-12 05:20:46', 10, 30, 51),
(2, 'Khóa vân tay Samsung SHP-DH538', 5490000, 'DH538_co 3-4.jpg', 'Khóa vân tay Samsung SHP-DH538 - Mở bằng vân tay, mã số, chìa cơ dự phòng. Chống nước, thiết kế hiện đại.', '2024-02-17 07:35:46', '2025-12-13 02:28:36', 2, 20, 1),
(3, 'Khóa vân tay SamSung SHS P718', 8500000, '03fde30d-fbb6-4306-bae0-4ebfb4ece53a_700_mat ngoaiw.png', '<p></p><h2 class=\"ql-align-center\"><span style=\"color: rgb(0, 64, 128);\">Khóa Cửa Vân Tay Samsung SHS P718 – Nâng Tầm An Ninh, Định Hình Phong Cách Sống</span></h2><p class=\"ql-align-center\"><span style=\"color: rgb(85, 85, 85);\">Tại Locker Korea, chúng tôi tự hào giới thiệu siêu phẩm </span><strong style=\"color: rgb(0, 64, 128);\">khóa vân tay Samsung SHS P718</strong><span style=\"color: rgb(85, 85, 85);\"> – biểu tượng của sự kết hợp hoàn hảo giữa công nghệ bảo mật hàng đầu, thiết kế tinh tế và trải nghiệm người dùng vượt trội. Đây không chỉ là một thiết bị an ninh mà còn là một tuyên ngôn về đẳng cấp và sự tiện nghi cho mọi không gian sống hiện đại. Samsung SHS P718 cam kết mang đến sự an tâm tuyệt đối và phong cách sống thời thượng cho gia đình bạn.</span></p><h3><span style=\"color: rgb(0, 64, 128);\">Đặc Điểm Nổi Bật Vượt Trội</span></h3><p><span style=\"color: rgb(51, 51, 51);\">Samsung SHS P718 được thiết kế để đáp ứng mọi kỳ vọng của bạn về một hệ thống an ninh hiện đại, với những ưu điểm không thể bỏ qua:</span></p><ul><li><strong style=\"color: rgb(51, 51, 51);\">Công Nghệ Vân Tay Siêu Nhạy và An Toàn:</strong><span style=\"color: rgb(51, 51, 51);\"> Tích hợp cảm biến vân tay quang học/FPC tiên tiến, nhận diện chỉ trong tích tắc, đảm bảo độ chính xác và bảo mật tối đa, loại bỏ hoàn toàn nguy cơ sao chép hoặc làm giả vân tay.</span></li><li><strong style=\"color: rgb(51, 51, 51);\">Thiết Kế Tay Cầm Push-Pull Đột Phá:</strong><span style=\"color: rgb(51, 51, 51);\"> Cơ chế mở/đóng cửa bằng cách đẩy hoặc kéo nhẹ nhàng, mang lại trải nghiệm sử dụng vô cùng tiện lợi và thoải mái, đặc biệt khi bạn đang mang vác đồ đạc.</span></li><li><strong style=\"color: rgb(51, 51, 51);\">Đa Dạng Phương Thức Mở Khóa Linh Hoạt:</strong><span style=\"color: rgb(51, 51, 51);\"> Cung cấp tới 4 tùy chọn mở khóa: vân tay, mã số, thẻ từ và chìa khóa cơ dự phòng, cho phép bạn và gia đình lựa chọn phương thức phù hợp nhất trong mọi tình huống.</span></li><li><strong style=\"color: rgb(51, 51, 51);\">Hệ Thống Bảo Mật Đa Lớp Thông Minh:</strong><span style=\"color: rgb(51, 51, 51);\"> Từ mã số ảo chống nhìn trộm, tính năng khóa kép từ bên trong, đến cảnh báo xâm nhập và cháy nổ, P718 mang đến một lớp bảo vệ vững chắc cho ngôi nhà của bạn.</span></li><li><strong style=\"color: rgb(51, 51, 51);\">Chất Liệu Cao Cấp, Bền Bỉ Theo Thời Gian:</strong><span style=\"color: rgb(51, 51, 51);\"> Được chế tạo từ hợp kim kẽm siêu bền và bề mặt kính cường lực chống trầy xước, khóa không chỉ sang trọng mà còn có khả năng chống chịu va đập, ăn mòn hiệu quả.</span></li><li><strong style=\"color: rgb(51, 51, 51);\">Cảnh Báo An Ninh Tức Thời:</strong><span style=\"color: rgb(51, 51, 51);\"> Tích hợp các cảm biến thông minh để phát hiện các mối đe dọa như cháy nổ, phá hoại hoặc xâm nhập trái phép, đồng thời phát ra âm thanh cảnh báo lớn và gửi thông báo (nếu có module kết nối nhà thông minh).</span></li></ul><h3><span style=\"color: rgb(0, 64, 128);\">Công Nghệ &amp; Chất Liệu Vượt Trội</span></h3><p><span style=\"color: rgb(51, 51, 51);\">Sự ưu việt của Samsung SHS P718 không chỉ nằm ở vẻ ngoài mà còn ẩn chứa trong từng chi tiết công nghệ và chất liệu cấu thành:</span></p><h4><span style=\"color: rgb(0, 86, 179);\">Công Nghệ Nhận Diện Vân Tay FPC Tiên Tiến</span></h4><p><span style=\"color: rgb(51, 51, 51);\">Trái tim của Samsung SHS P718 là công nghệ nhận diện vân tay FPC (Fingerprint Cards) hoặc quang học thế hệ mới, cho phép quét và xác thực vân tay với độ chính xác cao tuyệt đối, chỉ trong </span><strong style=\"color: rgb(51, 51, 51);\">0.5 giây</strong><span style=\"color: rgb(51, 51, 51);\">. Khả năng chống làm giả vân tay hiệu quả, kết hợp với bộ nhớ lớn (có thể lưu trữ tới 100 vân tay), giúp việc quản lý ra vào trở nên dễ dàng và an toàn hơn bao giờ hết. Bạn sẽ không còn phải lo lắng về việc mất chìa khóa hay lộ mã số.</span></p><h4><span style=\"color: rgb(0, 86, 179);\">Cơ Chế Tay Cầm Push-Pull Đột Phá</span></h4><p><span style=\"color: rgb(51, 51, 51);\">Thiết kế tay cầm Push-Pull là điểm nhấn độc đáo, giúp việc mở cửa trở nên </span><strong style=\"color: rgb(0, 64, 128);\">thuận tiện và trực quan</strong><span style=\"color: rgb(51, 51, 51);\">. Thay vì phải xoay hoặc vặn tay nắm, bạn chỉ cần đẩy nhẹ từ bên ngoài để vào hoặc kéo nhẹ từ bên trong để ra. Cơ chế này đặc biệt hữu ích cho người già, trẻ nhỏ hoặc khi bạn đang bận tay xách đồ, mang lại sự mượt mà và thoải mái tối đa trong mọi thao tác.</span></p><h4><span style=\"color: rgb(0, 86, 179);\">Bộ Vi Xử Lý Thông Minh và Mã Số Ảo Chống Lộ</span></h4><p><span style=\"color: rgb(51, 51, 51);\">P718 được trang bị bộ vi xử lý thông minh, cho phép người dùng thiết lập </span><strong style=\"color: rgb(0, 64, 128);\">mã số ảo</strong><span style=\"color: rgb(51, 51, 51);\"> – một tính năng bảo mật tuyệt vời giúp ngăn chặn việc lộ mã số ngay cả khi có người đứng cạnh quan sát. Bạn có thể nhập một dãy số bất kỳ trước hoặc sau mã số chính mà vẫn mở được khóa. Thêm vào đó, chức năng mã số chủ (Master Code) cho phép quản lý toàn bộ cài đặt khóa, tăng cường quyền kiểm soát an ninh tối đa.</span></p><h4><span style=\"color: rgb(0, 86, 179);\">Kết Cấu Bền Vững Từ Hợp Kim Cao Cấp</span></h4><p><span style=\"color: rgb(51, 51, 51);\">Vỏ khóa được chế tác từ </span><strong style=\"color: rgb(0, 64, 128);\">hợp kim kẽm nguyên khối</strong><span style=\"color: rgb(51, 51, 51);\">, trải qua quy trình xử lý bề mặt tinh xảo, chống ăn mòn và oxy hóa hiệu quả. Bề mặt bàn phím cảm ứng được bảo vệ bằng kính cường lực Gorilla Glass, chống trầy xước, va đập và chịu lực tốt, đảm bảo độ bền vượt trội theo thời gian. Sự kết hợp giữa vật liệu cao cấp và kỹ thuật chế tạo tiên tiến mang lại cho P718 khả năng hoạt động ổn định và bền bỉ trong mọi điều kiện môi trường.</span></p><h4><span style=\"color: rgb(0, 86, 179);\">Cảm Biến Cháy và Chống Sốc Điện</span></h4><p><span style=\"color: rgb(51, 51, 51);\">An toàn luôn là ưu tiên hàng đầu. Samsung SHS P718 được tích hợp </span><strong style=\"color: rgb(0, 64, 128);\">cảm biến nhiệt độ</strong><span style=\"color: rgb(51, 51, 51);\"> bên trong, sẽ tự động mở khóa khi phát hiện nhiệt độ trong nhà tăng cao bất thường (trên 60°C), giúp người trong nhà thoát hiểm kịp thời trong trường hợp hỏa hoạn. Đồng thời, khóa còn có tính năng </span><strong style=\"color: rgb(0, 64, 128);\">chống sốc điện tử</strong><span style=\"color: rgb(51, 51, 51);\">, vô hiệu hóa mọi nỗ lực mở khóa bằng các thiết bị điện áp cao, đảm bảo an toàn tuyệt đối cho hệ thống và người dùng.</span></p><h3><span style=\"color: rgb(0, 64, 128);\">Ứng Dụng Đa Dạng &amp; Linh Hoạt</span></h3><p><span style=\"color: rgb(51, 51, 51);\">Với thiết kế sang trọng và tính năng ưu việt, Samsung SHS P718 là lựa chọn lý tưởng cho nhiều không gian khác nhau:</span></p><ul><li><strong style=\"color: rgb(51, 51, 51);\">Không Gian Sống Hiện Đại:</strong><span style=\"color: rgb(51, 51, 51);\"> Phù hợp cho căn hộ chung cư cao cấp, biệt thự, nhà phố, mang lại sự tiện nghi và an tâm cho mọi thành viên trong gia đình.</span></li><li><strong style=\"color: rgb(51, 51, 51);\">Văn Phòng &amp; Công Sở:</strong><span style=\"color: rgb(51, 51, 51);\"> Dễ dàng quản lý quyền ra vào cho nhân viên, đối tác, đồng thời tăng cường bảo mật cho các khu vực quan trọng.</span></li><li><strong style=\"color: rgb(51, 51, 51);\">Phù Hợp Mọi Thành Viên Gia Đình:</strong><span style=\"color: rgb(51, 51, 51);\"> Với nhiều phương thức mở khóa và thao tác đơn giản, P718 dễ dàng sử dụng cho cả người lớn tuổi (không cần nhớ mật khẩu, chỉ cần vân tay/thẻ từ) và trẻ nhỏ (không cần loay hoay với chìa khóa).</span></li></ul><blockquote><em style=\"color: rgb(85, 85, 85); background-color: rgb(248, 248, 248);\">&quot;Samsung SHS P718 không chỉ là một chiếc khóa cửa, mà là một giải pháp an ninh toàn diện, mang đến sự an tâm tuyệt đối và nâng tầm giá trị cho không gian sống của bạn.&quot;</em></blockquote><h3><span style=\"color: rgb(0, 64, 128);\">Kết Luận: Tại Sao Samsung SHS P718 Là Lựa Chọn Hoàn Hảo?</span></h3><p><span style=\"color: rgb(51, 51, 51);\">Trong thế giới ngày càng phát triển, nhu cầu về một ngôi nhà không chỉ đẹp mà còn an toàn và thông minh trở nên cấp thiết hơn bao giờ hết. </span><strong style=\"color: rgb(0, 64, 128);\">Khóa vân tay Samsung SHS P718</strong><span style=\"color: rgb(51, 51, 51);\"> chính là câu trả lời hoàn hảo cho mọi mong đợi đó.</span></p><p><span style=\"color: rgb(51, 51, 51);\">Khi lựa chọn P718, bạn không chỉ đầu tư vào một sản phẩm công nghệ cao mà còn đầu tư vào </span><strong style=\"color: rgb(0, 64, 128);\">sự yên bình, tiện lợi và đẳng cấp</strong><span style=\"color: rgb(51, 51, 51);\">. Từ khả năng bảo mật vượt trội với vân tay siêu nhạy, đến thiết kế Push-Pull độc đáo mang lại trải nghiệm mở cửa mượt mà, P718 đã và đang định nghĩa lại chuẩn mực về khóa cửa điện tử.</span></p><p><span style=\"color: rgb(51, 51, 51);\">Với chất liệu bền bỉ, công nghệ thông minh và các tính năng cảnh báo an ninh tiên tiến, Samsung SHS P718 mang đến sự bảo vệ tối ưu cho tài sản và những người thân yêu của bạn. Nó phù hợp với mọi thành viên trong gia đình, từ người lớn tuổi đến trẻ nhỏ, biến mỗi lần ra vào nhà thành một trải nghiệm dễ dàng và an toàn.</span></p><p><span style=\"color: rgb(51, 51, 51);\">Hãy để </span><strong style=\"color: rgb(0, 64, 128);\">Locker Korea</strong><span style=\"color: rgb(51, 51, 51);\"> đồng hành cùng bạn trên hành trình kiến tạo không gian sống an toàn, tiện nghi và sang trọng. Liên hệ ngay hôm nay để được tư vấn chi tiết về khóa vân tay Samsung SHS P718 và nhận những ưu đãi tốt nhất!</span></p><p>```</p>', '2024-02-17 07:35:46', '2025-12-13 08:12:30', 2, 60, 3332),
(4, 'Khóa SAMSUNG SHS-2920', 4200000, 'SHS-2920_1.jpg', 'Khóa SAMSUNG SHS-2920 - Khóa điện tử mã số, thiết kế đơn giản, phù hợp mọi loại cửa.', '2024-02-17 07:35:46', '2024-02-17 07:35:46', 2, NULL, 0),
(5, 'Khóa điện tử SAMSUNG SHP-DS700', 3290000, 'SHP-DS700_1.jpg', 'Khóa điện tử Samsung SHP-DS700 cao cấp, mở khóa bằng thẻ từ và mã số.', '2024-02-17 07:35:46', '2025-12-12 11:14:28', 2, 60, 47),
(6, 'Khóa điện tử SAMSUNG SHS 1321', 3480000, '1321-1-3-4.jpg', 'Khóa điện tử Samsung SHS 1321 với thiết kế thanh lịch, bảo mật cao.', '2024-02-17 07:35:46', '2025-12-13 02:45:00', 2, 5, 332),
(7, 'Khóa vân tay SAMSUNG SHP-DP930', 12000000, 'SAMSUNG DP920.jpg', 'Khóa vân tay Samsung SHP-DP930 premium, màn hình cảm ứng, kết nối WiFi.', '2024-02-17 07:35:46', '2024-02-17 07:35:46', 2, NULL, 50),
(8, 'Khóa vân tay Samsung SHS-H700', 9500000, '700_mat ngoaiw.png', 'Khóa vân tay Samsung SHS-H700 cao cấp, thiết kế sang trọng, hỗ trợ vân tay 360 độ.', '2024-02-17 07:35:46', '2025-06-13 06:20:04', 2, 80, 2),
(9, 'Chuông cửa hình SAMSUNG SHT-3517NT', 4200000, 'sht-3517nt-1.jpg', 'Chuông cửa video Samsung SHT-3517NT với màn hình 7 inch, camera HD, tính năng hai chiều.', '2024-02-17 07:35:46', '2025-06-13 08:11:55', 11, 20, 0),
(11, 'Khóa điện tử GATEMAN WG-200', 4190000, 'wg-200 3-4.jpg', 'Khóa điện tử GATEMAN WG-200 - Mở bằng mã số và thẻ từ. Kiểu dáng thanh lịch, vật liệu siêu bền.', '2024-02-17 07:35:46', '2024-02-17 07:35:46', 1, NULL, 0),
(12, 'Khóa vân tay GATEMAN WF200', 6990000, 'wf-200_34.jpg', 'Khóa vân tay GATEMAN WF200 - Mở bằng vân tay, mật mã. Bàn phím cảm ứng chất liệu đặc biệt, bền, sang trọng.', '2024-02-17 07:35:46', '2024-02-17 07:35:46', 1, NULL, 0),
(13, 'Khóa vân tay GATEMAN Z10-IH', 5600000, 'Z10_3 3-4.jpg', 'Khóa vân tay GATEMAN Z10-IH với công nghệ mới nhất, mở khóa nhanh 0.3 giây.', '2024-02-17 07:35:46', '2025-06-13 06:19:12', 4, 4, 465),
(14, 'GATEMAN F300-FH', 7950000, '297e3625-a9b5-475f-8313-059ec3c53f67_gateman-f300fh_2048x2048-1.jpg', '<h2><strong>Thông số kỹ thuật:</strong></h2><p>-&nbsp;Khóa cửa vân tay loại: Không có tay nắm.</p><p>- Mở khóa bằng vân tay hoặc mật mã</p><p>+ Chế độ thông thường: Cài đặt 20 vân tay, 03 mã số ( 01 mã số chủ, 01 mã số thành viên, 01 mã số khách sử dụng 1 lân.</p><p><br>&nbsp;</p><p><br>&nbsp;</p><p>+ Chế độ nâng cao: Cài đặt 20 vân tay, 32 mã số( 01 mã số chủ, 30 mã số thành viên, 01 mã số khách sử dụng một lần). Chức năng xóa từng vân tay, từng mã số thành viên.<br>- Mở khóa từ xa: Kết nối với điều khiển từ xa/ hoặc điện thoại smart phone (mua thêm)</p><p>- Bàn phím: Cảm ứng chống xước, chống va đập</p><p>- Vật liệu: Bằng hợp kim</p><p>- Mầu: Đen</p><p>- Tuổi thọ pin: 10 tháng (10 lần/ngày)</p><p>- Xuất xứ: Korea</p><p>- Bảo hành: 12 tháng</p><h2><strong>Thiết kế:</strong></h2><p>GATEMAN WF20 có kiểu dáng không tay cầm hiện đại với đầu đọc vân tay được đặt tại vị trí thuận lợi cho người sử dụng sản phẩm. màu chủ đạo cho khóa là Màn hình cảm ứng của khóa được sử dụng chất liệu cao cấp có khả năng chống chịu được các tác động của ngoại lực, tĩnh điện và nhiệt độ cao. Bộ phận chốt khóa được sử dụng hợp kim thép siêu bền khó có thể cưa cắt.</p><p><br>&nbsp;</p><p><a href=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjqBmpi1f6nIN976j6ZLmJ3pc267RbDw5oP2tz9Rr5oY_t0OsqkpyzKgB2y1vsmN3cAYVQlxuGJqOFuih6zvsEGN9Yhb6jLMhjdSnEnmrnU9WlUVJo65wnzI3t2fdyrFIbhCEs2W9J3MR6J/s1600/WF20_2.jpg\"><img src=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjqBmpi1f6nIN976j6ZLmJ3pc267RbDw5oP2tz9Rr5oY_t0OsqkpyzKgB2y1vsmN3cAYVQlxuGJqOFuih6zvsEGN9Yhb6jLMhjdSnEnmrnU9WlUVJo65wnzI3t2fdyrFIbhCEs2W9J3MR6J/s640/WF20_2.jpg\" width=\"504\" height=\"640\"></a></p><p>&nbsp;Cống nhìn trộm mật mã bằng cách thêm mã số ảo<br>&nbsp;</p><p><a href=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEh0mPTwF5nJVsG_wFUEVCryhEiqXa4LVjZbV5wiS-asJ2OsND3kRu2Z_R_swx8y0Qv_bHWdukjeXviYhKXDsb30eke_7EtJV1yoAEsxroEb_ronVebSB3uNAE017WuYiRLN9_iCkbVbERX0/s1600/WF20_3.jpg\"><img src=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEh0mPTwF5nJVsG_wFUEVCryhEiqXa4LVjZbV5wiS-asJ2OsND3kRu2Z_R_swx8y0Qv_bHWdukjeXviYhKXDsb30eke_7EtJV1yoAEsxroEb_ronVebSB3uNAE017WuYiRLN9_iCkbVbERX0/s640/WF20_3.jpg\" width=\"470\" height=\"640\"></a></p><p>&nbsp;Về đêm, tắt tiếng kêu bíp bíp bằng cách chạm vào khóa trong 3 giây.<br>&nbsp;</p><p><a href=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEiP6PofMocgPGUdD0I1hYNDMDm2IV6iQvAZCj6CXex_TZbodLkhJ8SBlKeItaYqrhVKFOmNpmVsIOyCFwhfOsgTm9Pdp5YrDfW3cH6KM9zPG7gPVZEel-SGqaDoe3_nocu-4tZvugXqgQF3/s1600/WF20_4.jpg\"><img src=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEiP6PofMocgPGUdD0I1hYNDMDm2IV6iQvAZCj6CXex_TZbodLkhJ8SBlKeItaYqrhVKFOmNpmVsIOyCFwhfOsgTm9Pdp5YrDfW3cH6KM9zPG7gPVZEel-SGqaDoe3_nocu-4tZvugXqgQF3/s640/WF20_4.jpg\" width=\"556\" height=\"640\"></a></p><p>&nbsp;Mở bằng vân tay hoặc mật mã. Nếu sai 5 lần, khoa sẽ dừng hoạt động trong 3 phút để chống hack.<br>&nbsp;</p><p><a href=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEh6LSYxDoVTrcEa0Bv9V5xel51FVIWL_l9VcdHQ19bQKBCLYwzXVDa3jB1EODaM99KgeI2TqGIIMptqwnD7ZHZYvcY3a3S7f3KehdyKMnJOf41f9WwvY7x9qBsYpIO4izm7t2eCnjStt2cE/s1600/WF20_5.jpg\"><img src=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEh6LSYxDoVTrcEa0Bv9V5xel51FVIWL_l9VcdHQ19bQKBCLYwzXVDa3jB1EODaM99KgeI2TqGIIMptqwnD7ZHZYvcY3a3S7f3KehdyKMnJOf41f9WwvY7x9qBsYpIO4izm7t2eCnjStt2cE/s640/WF20_5.jpg\" width=\"572\" height=\"640\"></a></p><p>&nbsp;Chống sốc điện và cảnh báo nhiệt độ cao<br>&nbsp;</p><p><a href=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEh7rhlEhaE-4sqPrxLmoIO29QCXNzIA6Kyn6Si1tCB2NE6dFxrtgt8kQwxH64tmfYOO8wRzZTKeLax1RH8lZ5p0CnblSc3dWw7nKAGnfKnsQkAAl1xs7-Fqsn_iIOslCFldxUI-3Nz0qs8o/s1600/WF20_6.jpg\"><img src=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEh7rhlEhaE-4sqPrxLmoIO29QCXNzIA6Kyn6Si1tCB2NE6dFxrtgt8kQwxH64tmfYOO8wRzZTKeLax1RH8lZ5p0CnblSc3dWw7nKAGnfKnsQkAAl1xs7-Fqsn_iIOslCFldxUI-3Nz0qs8o/s640/WF20_6.jpg\" width=\"628\" height=\"640\"></a></p><p>&nbsp;Báo động khi có sự đột nhập/ phá khóa:<br>&nbsp;</p><p><a href=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgbvJQHT8A0JTal1Mp9YokzjMjonFJ1DFmQ4NZItOzs-aCypwwcht-QXihBB-xbVjp1MUcQiLoMeUuCWTxtsqWss4A3toa65AKGSh4NHrOhHwa3EvWqPFakBkzcVqpZ0SvjlzPZAdMGSkBM/s1600/WF20_7.jpg\"><img src=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgbvJQHT8A0JTal1Mp9YokzjMjonFJ1DFmQ4NZItOzs-aCypwwcht-QXihBB-xbVjp1MUcQiLoMeUuCWTxtsqWss4A3toa65AKGSh4NHrOhHwa3EvWqPFakBkzcVqpZ0SvjlzPZAdMGSkBM/s640/WF20_7.jpg\" width=\"490\" height=\"640\"></a></p><p>Nguồn khẩn cấp bên ngoài trogn trường hợp hết pin (Pin vuông 9V, mua ngoài)<br>Chống nước trong điều kiện sử dụng thông thường.<br>&nbsp;</p><p><a href=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEh6oR11wTy2CB28DaZzlToht794AzmklfTnYp8dGRvTMW67DnLrSWbxauhHPJt_oOlPxbvu_CIrgjgz6lV_QLS7wXhxb_sZU3wvxVN80LJ4gpoPlUGjBgMTk85Zl0uKxp-LFxGGrYglgbKk/s1600/WF20_8.jpg\"><img src=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEh6oR11wTy2CB28DaZzlToht794AzmklfTnYp8dGRvTMW67DnLrSWbxauhHPJt_oOlPxbvu_CIrgjgz6lV_QLS7wXhxb_sZU3wvxVN80LJ4gpoPlUGjBgMTk85Zl0uKxp-LFxGGrYglgbKk/s640/WF20_8.jpg\" width=\"496\" height=\"640\"></a></p><p><strong>&nbsp;Giá: 4.600.000 đồng</strong><br>&nbsp;</p><p><a href=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEioCykIJT9InIhGIGZL91qXpvbtHyJTiDsiphBg2xSUkycU5zkjh5WOSKqwUYfd-h7xfA67889sGaaH7QU3-ECCbTGqCf2i1G6I5XAtSkwPuf6EHIAmgO_qhSUAixAq5Lm5aa_tNYf_LI05/s1600/Xuan-Chuong+My.jpg\"><img src=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEioCykIJT9InIhGIGZL91qXpvbtHyJTiDsiphBg2xSUkycU5zkjh5WOSKqwUYfd-h7xfA67889sGaaH7QU3-ECCbTGqCf2i1G6I5XAtSkwPuf6EHIAmgO_qhSUAixAq5Lm5aa_tNYf_LI05/s640/Xuan-Chuong+My.jpg\" width=\"480\" height=\"640\"></a></p><p><br>&nbsp;</p><p><a href=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgyXcjZPjugXY9lfKlhLJf1RbHiJfmLmq0ix3yjQJ8vo7f8G_EBJGBbUDBf_eJz0mOlJ88b6KnK4UtOgiKSbt5DN0-9QhKDIVtBK6t69_qVr0YiDMjAy_ilThqzSuh6MyPwhr0yZyGfJygP/s1600/Xuan-Chuong+My3.jpg\"><img src=\"https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgyXcjZPjugXY9lfKlhLJf1RbHiJfmLmq0ix3yjQJ8vo7f8G_EBJGBbUDBf_eJz0mOlJ88b6KnK4UtOgiKSbt5DN0-9QhKDIVtBK6t69_qVr0YiDMjAy_ilThqzSuh6MyPwhr0yZyGfJygP/s640/Xuan-Chuong+My3.jpg\" width=\"640\" height=\"480\"></a></p><p><br>&nbsp;</p>', '2024-02-17 07:35:46', '2025-12-20 03:55:26', 1, 60, 40),
(15, 'Khóa vân tay GATEMAN F50-FH', 5250000, 'Gateman F50-FH.jpg', 'Khóa vân tay GATEMAN F50-FH thiết kế cổ điển hiện đại, chống nước IP54, tuổi thọ pin lên đến 12 tháng.', '2024-02-17 07:35:46', '2024-02-17 07:35:46', 1, NULL, 0),
(16, 'Khóa vân tay H-Gang TR812', 3350000, 'TR812_3-4.png', 'Khóa vân tay H-Gang TR812 thông minh cao cấp từ Hàn Quốc. Công nghệ hiện đại, bảo mật cao, thiết kế sang trọng.', '2024-02-17 07:35:46', '2025-06-13 07:07:51', 3, 28, 234),
(17, 'Khóa cửa kính H-Gang Sync TG330', 3800000, 'TG330_1.jpg', 'Khóa cửa kính H-Gang Sync TG330 với thiết kế tinh tế cho cửa kính cường lực.', '2024-02-17 07:35:46', '2025-12-14 05:47:22', 10, 73, 25),
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
(5784, 'Samsung Galaxy S25 Ultra', 29000000, '1cc31cbd-cd97-4a6d-9141-c6baa2fb61bc_loại bỏ viền trắng.png', 'ádffafas', '2025-06-13 08:28:22', '2025-12-14 16:24:00', 4, 43, 1338),
(5785, 'Mercedes GLE 350', 6990000000, '2e73c40c-e904-427f-9db9-e28d2c6578a3_Untitled.png', 'ádasdasd', '2025-06-13 08:29:52', '2025-12-14 16:23:33', 5, 55, 4),
(5788, 'Khoá điện tử GATESUNG HI-999112333', 23304432, '37df6011-9b2a-40d0-9036-bf4e40427836_SHS-P718_3-4.png', '<h2>Khoá Điện Tử GATESUNG HI-999112333: Định Nghĩa Lại An Ninh Gia Đình Hiện Đại</h2><p>Chào mừng bạn đến với thế giới của sự an toàn tuyệt đối và tiện nghi vượt trội cùng <strong>Khoá điện tử GATESUNG HI-999112333</strong> – một tuyệt tác công nghệ đến từ thương hiệu GATESUNG danh tiếng, được phân phối chính hãng bởi Locker Korea. Trong kỷ nguyên số hóa, an ninh không chỉ gói gọn trong việc bảo vệ tài sản, mà còn là sự an tâm cho mỗi thành viên trong gia đình. GATESUNG HI-999112333 không chỉ là một chiếc khóa đơn thuần; nó là một hệ thống bảo vệ thông minh, tích hợp hoàn hảo giữa <strong>công nghệ mã PIN tiên tiến</strong> và <strong>khả năng kết nối WiFi mạnh mẽ</strong>, mang đến cho bạn quyền kiểm soát tối ưu và sự an toàn không giới hạn. Sản phẩm này cam kết nâng tầm không gian sống của bạn, biến ngôi nhà trở thành một pháo đài vững chắc nhưng vẫn đầy tinh tế, sang trọng và tiện lợi cho mọi thành viên.</p><h3>Đặc Điểm Nổi Bật Vượt Trội Của GATESUNG HI-999112333</h3><p>GATESUNG HI-999112333 được thiết kế để vượt xa mọi kỳ vọng về một chiếc khóa điện tử thông thường, với những tính năng ưu việt sau:</p><ul><li><strong>Bảo Mật Đa Lớp Vượt Trội Với Mã PIN Thông Minh:</strong> Tính năng mở khóa bằng mã PIN trên GATESUNG HI-999112333 được nâng cấp để đảm bảo an toàn tối đa. Hệ thống cho phép bạn tạo nhiều mã PIN khác nhau cho từng thành viên hoặc khách truy cập, đồng thời tích hợp chức năng mã số ảo (Virtual PIN) để chống nhìn trộm hiệu quả. Bạn có thể nhập một dãy số ngẫu nhiên trước hoặc sau mã PIN chính xác của mình, làm cho việc đoán mã trở nên bất khả thi. Hơn nữa, khóa được trang bị cảm biến nhận diện sự xâm nhập bất thường và hệ thống báo động chống cạy phá, tự động kích hoạt còi hú cảnh báo khi có ý định phá hoại, mang lại sự an tâm tuyệt đối cho gia đình bạn ngay cả khi bạn vắng nhà.</li><li><strong>Kết Nối WiFi Toàn Diện – Quản Lý Mọi Lúc Mọi Nơi:</strong> Điểm sáng của GATESUNG HI-999112333 chính là khả năng kết nối WiFi trực tiếp mà không cần qua Gateway trung gian. Điều này cho phép bạn kiểm soát hoàn toàn cửa ra vào ngôi nhà chỉ với chiếc điện thoại thông minh của mình, dù bạn đang ở bất kỳ đâu. Bạn có thể mở khóa cửa từ xa cho khách đến chơi, người thân hoặc nhân viên dịch vụ một cách tiện lợi. Đồng thời, mọi hoạt động ra vào đều được ghi lại chi tiết và gửi thông báo tức thì về điện thoại, giúp bạn nắm bắt tình hình an ninh ngôi nhà 24/7. Khả năng quản lý từ xa này đặc biệt hữu ích cho những người bận rộn hoặc chủ sở hữu căn hộ cho thuê.</li><li><strong>Thiết Kế Sang Trọng, Nâng Tầm Không Gian Sống:</strong> GATESUNG HI-999112333 không chỉ là một thiết bị an ninh, mà còn là một tác phẩm nghệ thuật tô điểm cho cánh cửa ngôi nhà bạn. Với ngôn ngữ thiết kế tối giản, tinh tế cùng các đường nét hiện đại, sản phẩm này dễ dàng hòa nhập vào mọi phong cách kiến trúc, từ cổ điển đến hiện đại, mang lại vẻ đẹp đẳng cấp và sang trọng. Mặt khóa được hoàn thiện từ kính cường lực cao cấp, chống trầy xước, cùng với thân khóa làm từ hợp kim kẽm nguyên khối, tạo nên một tổng thể vững chãi và cực kỳ bắt mắt. Thiết kế tay cầm công thái học cũng đảm bảo cảm giác cầm nắm thoải mái và chắc chắn mỗi khi sử dụng.</li><li><strong>Độ Bền Vượt Trội Với Chất Liệu Cao Cấp:</strong> Sự bền bỉ là yếu tố cốt lõi của GATESUNG HI-999112333. Toàn bộ phần vỏ khóa và các chi tiết cơ khí bên trong đều được chế tác từ những vật liệu hàng đầu như hợp kim kẽm đúc nguyên khối, thép không gỉ SUS 304 và kính cường lực chống va đập. Các vật liệu này không chỉ mang lại khả năng chống chịu lực cực tốt mà còn kháng ăn mòn, oxy hóa hiệu quả, giúp khóa duy trì vẻ đẹp và hiệu suất hoạt động ổn định qua thời gian, bất chấp điều kiện thời tiết khắc nghiệt. Sản phẩm đã trải qua hàng ngàn thử nghiệm đóng mở và kiểm tra độ bền trong môi trường thực tế, đảm bảo tuổi thọ lâu dài.</li><li><strong>Trải Nghiệm Mở Khóa Nhanh Chóng và Thuận Tiện:</strong> GATESUNG HI-999112333 được thiết kế với tiêu chí “người dùng là trung tâm”. Bàn phím số cảm ứng có đèn nền hiển thị rõ ràng, giúp bạn dễ dàng nhập mã PIN ngay cả trong điều kiện thiếu sáng. Tốc độ nhận diện và xử lý mã PIN cực nhanh, chỉ mất chưa đầy một giây để xác nhận và mở khóa cửa, loại bỏ hoàn toàn sự chờ đợi hay bất tiện khi phải tìm chìa khóa. Giao diện người dùng trực quan, âm thanh hướng dẫn rõ ràng giúp cả người lớn tuổi và trẻ nhỏ cũng có thể sử dụng khóa một cách dễ dàng và an toàn, mang lại sự thuận tiện tối đa trong cuộc sống hàng ngày.</li><li><strong>Quản Lý Người Dùng Linh Hoạt và Tối Ưu:</strong> Thông qua ứng dụng di động chuyên biệt được kết nối với khóa qua WiFi, bạn có thể dễ dàng thêm, xóa hoặc chỉnh sửa thông tin người dùng. Đặc biệt, bạn có thể tạo mã PIN sử dụng một lần hoặc mã PIN có thời hạn sử dụng cụ thể, rất phù hợp cho khách đến chơi, người giúp việc hoặc các dịch vụ giao hàng. Tính năng này giúp bạn kiểm soát chặt chẽ quyền truy cập vào ngôi nhà mà không cần phải lo lắng về việc giao chìa khóa vật lý hay thay đổi khóa mỗi khi có người ra vào. Mọi thao tác quản lý đều đơn giản và nhanh chóng chỉ với vài chạm trên màn hình điện thoại.</li></ul><h3>Công Nghệ &amp; Chất Liệu Tiên Tiến – Nền Tảng Của Sự Vững Chắc</h3><p>GATESUNG HI-999112333 là sự kết hợp hoàn hảo giữa kỹ thuật chế tác đỉnh cao và công nghệ điện tử hiện đại, tạo nên một sản phẩm khóa điện tử dẫn đầu xu hướng.</p><blockquote><p><strong>Công nghệ:</strong> Trái tim của GATESUNG HI-999112333 là <strong>chip xử lý thông minh ARM Cortex-M</strong> thế hệ mới, đảm bảo tốc độ xử lý nhanh chóng, độ chính xác cao và tiết kiệm năng lượng vượt trội. Module WiFi tích hợp sử dụng chuẩn 802.11 b/g/n với mã hóa WPA2-PSK, đảm bảo kết nối ổn định và an toàn tuyệt đối, chống lại các nguy cơ tấn công mạng. Hệ thống mã hóa dữ liệu đầu cuối (end-to-end encryption) được áp dụng để bảo vệ thông tin cá nhân và dữ liệu truy cập của người dùng khi truyền tải qua mạng. Bên cạnh đó, khóa còn được trang bị <strong>cảm biến đa điểm chống cạy phá</strong>, cảm biến nhiệt độ cảnh báo cháy nổ (nếu nhiệt độ trong nhà vượt ngưỡng cho phép, khóa sẽ tự động mở để tạo lối thoát hiểm và phát cảnh báo), cùng với hệ thống cảnh báo pin yếu thông minh, giúp bạn chủ động thay pin kịp thời, tránh tình trạng khóa hết pin đột ngột. Nguồn điện sử dụng 4 viên pin AA với tuổi thọ lên đến 12 tháng, và cổng cấp nguồn khẩn cấp qua micro USB/Type-C đảm bảo bạn không bao giờ bị kẹt ngoài cửa.</p></blockquote><blockquote><p><strong>Chất liệu:</strong> GATESUNG HI-999112333 được cấu thành từ những vật liệu chọn lọc, đảm bảo độ bền bỉ và tính thẩm mỹ cao nhất. Phần thân khóa chính được đúc nguyên khối từ <strong>hợp kim kẽm cao cấp</strong>, trải qua quy trình xử lý bề mặt anodizing hiện đại, không chỉ tăng cường độ cứng cáp, chống ăn mòn mà còn tạo nên lớp hoàn thiện mịn màng, chống bám vân tay và dễ dàng vệ sinh. Mặt trước khóa sử dụng <strong>kính cường lực Gorilla Glass</strong> (hoặc tương đương) chống va đập, chống trầy xước hiệu quả, duy trì vẻ sáng bóng theo thời gian. Lõi khóa bên trong được làm từ <strong>thép không gỉ SUS 304</strong>, chịu lực tốt, chống cắt phá và chống khoan, đạt tiêu chuẩn an ninh quốc tế. Các chi tiết nhựa bên trong (nếu có) đều là nhựa ABS chống cháy, thân thiện với môi trường và an toàn cho sức khỏe. Tất cả các thành phần đều được kiểm định nghiêm ngặt, đảm bảo tuân thủ các tiêu chuẩn chất lượng và an toàn cao nhất.</p></blockquote><h3>Ứng Dụng Đa Dạng – Nâng Tầm Mọi Không Gian</h3><p>Với những tính năng ưu việt và công nghệ hiện đại, Khoá điện tử GATESUNG HI-999112333 là lựa chọn lý tưởng cho nhiều đối tượng và loại hình bất động sản khác nhau:</p><ul><li><strong>Gia đình hiện đại:</strong> Là giải pháp hoàn hảo cho những gia đình mong muốn sự tiện lợi và an toàn tối đa. Không còn nỗi lo quên chìa khóa hay làm mất chìa khóa của con trẻ. Cha mẹ có thể dễ dàng theo dõi thời gian ra vào của các con, hoặc mở cửa cho người thân đến chơi ngay cả khi không có mặt ở nhà. Sự an tâm tuyệt đối khi biết rằng ngôi nhà luôn được bảo vệ an toàn.</li><li><strong>Căn hộ, chung cư cao cấp:</strong> Nâng tầm giá trị cho căn hộ của bạn với một thiết bị an ninh thông minh, sang trọng. Khả năng quản lý từ xa qua WiFi giúp chủ nhà dễ dàng điều phối việc ra vào cho khách thuê ngắn hạn (Airbnb), nhân viên vệ sinh hoặc các dịch vụ khác mà không cần phải có mặt trực tiếp. Lịch sử truy cập chi tiết cũng là công cụ quản lý hữu ích.</li><li><strong>Văn phòng, phòng làm việc riêng:</strong> Cung cấp giải pháp kiểm soát ra vào hiệu quả, không cần thẻ từ hay chìa khóa vật lý rườm rà. Bạn có thể cấp mã PIN riêng cho từng nhân viên, dễ dàng vô hiệu hóa hoặc thay đổi mã khi cần. Điều này không chỉ tăng cường bảo mật mà còn tạo nên sự chuyên nghiệp, hiện đại cho không gian làm việc.</li><li><strong>Chủ nhà thường xuyên vắng mặt hoặc đi công tác:</strong> Với GATESUNG HI-999112333, bạn có thể hoàn toàn yên tâm khi đi xa. Mọi thông báo về trạng thái cửa, các lần mở khóa đều được gửi về điện thoại theo thời gian thực. Khả năng mở khóa từ xa giúp giải quyết các tình huống phát sinh như người thân cần vào nhà đột xuất mà không có chìa khóa.</li></ul><h3>Kết Luận: Lựa Chọn Thông Minh Cho Cuộc Sống Đẳng Cấp</h3><p><strong>Khoá điện tử GATESUNG HI-999112333</strong> không chỉ là một khoản đầu tư vào an ninh, mà còn là sự đầu tư vào chất lượng cuộc sống và sự an tâm tuyệt đối. Với sự kết hợp hoàn hảo giữa <strong>công nghệ mã PIN tiên tiến</strong>, <strong>khả năng kết nối WiFi thông minh</strong>, thiết kế đẳng cấp và chất liệu bền bỉ, sản phẩm này xứng đáng là người bảo vệ đáng tin cậy cho mọi ngôi nhà hiện đại. Từ việc quản lý truy cập linh hoạt, bảo mật đa lớp vượt trội cho đến sự tiện lợi trong sử dụng hàng ngày và khả năng kiểm soát từ xa, GATESUNG HI-9991112333 mang đến một trải nghiệm an ninh hoàn toàn mới, loại bỏ mọi lo âu về chìa khóa truyền thống. Hãy để GATESUNG HI-999112333 biến ngôi nhà của bạn thành một không gian sống an toàn, tiện nghi và sang trọng hơn bao giờ hết. Chọn GATESUNG HI-999112333 tại Locker Korea, bạn đang chọn sự an tâm và đẳng cấp vượt trội.</p>', '2025-11-05 02:44:38', '2025-12-14 16:05:29', 2, 11, 3322),
(5789, 'Xiaomi Locker 69', 2122333, '02fb966d-6bf7-43a9-b263-8ebc475bea71_channels4_profile.jpg', '<p>dsfsdfsdfsdádasdasdas</p>', '2025-12-14 16:14:13', '2025-12-14 16:24:49', 12, 3, 11);

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
(22, 1, 1, '2025-12-12 07:29:32', '2025-12-12 07:29:32'),
(23, 1, 3, '2025-12-12 07:29:32', '2025-12-12 07:29:32'),
(24, 3, 1, '2025-12-13 02:46:07', '2025-12-13 02:46:07'),
(25, 3, 8, '2025-12-13 02:46:07', '2025-12-13 02:46:07'),
(26, 3, 4, '2025-12-13 02:46:07', '2025-12-13 02:46:07'),
(27, 3, 5, '2025-12-13 02:46:07', '2025-12-13 02:46:07'),
(28, 3, 6, '2025-12-13 02:46:07', '2025-12-13 02:46:07'),
(73, 5788, 2, '2025-12-14 16:05:29', '2025-12-14 16:05:29'),
(74, 5788, 5, '2025-12-14 16:05:29', '2025-12-14 16:05:29'),
(84, 5789, 1, '2025-12-14 16:24:54', '2025-12-14 16:24:54'),
(85, 5789, 2, '2025-12-14 16:24:54', '2025-12-14 16:24:54'),
(86, 5789, 4, '2025-12-14 16:24:54', '2025-12-14 16:24:54');

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
(132, 1, '2af2e2f9-692c-4209-9b6b-c0ce1da22d87_Nike-Air-Jordan-1-Retro-Low-OG-SP-Travis-ScottT-8-300x300.jpg.jpg'),
(133, 1, 'ebbf7fd1-b659-4dab-bca3-33691e9d661d_Nike-Air-Jordan-1-Retro-Low-OG-SP-Travis-ScottT-8-300x300.jpg.jpg'),
(134, 1, 'bfbbf398-6f57-4b27-8f90-0c61c46be7e5_Nike-Air-Jordan-1-Retro-Low-OG-SP-Travis-ScottT-8-300x300.jpg.jpg'),
(135, 1, '1bc170c9-2706-4a4e-8992-875a05e15314_alexander-mcqueen-trang-got-den-sieu-cap-1-300x300.jpg.jpg'),
(136, 3, '03fde30d-fbb6-4306-bae0-4ebfb4ece53a_700_mat ngoaiw.png'),
(138, 5788, '37df6011-9b2a-40d0-9036-bf4e40427836_SHS-P718_3-4.png'),
(139, 5788, 'c51a2eea-1c0d-4e4b-bca8-e668755b9d83_sht-3517nt-1.jpg'),
(140, 5789, '02fb966d-6bf7-43a9-b263-8ebc475bea71_channels4_profile.jpg'),
(141, 5789, '143eef63-10d6-4966-948f-bf0439fc1323_df20bb3f-5ef9-4c4a-9096-90c3144b6174 (1).png'),
(142, 5789, '1df4f3ed-5612-4b81-a99c-907786768660_Untitled.png'),
(143, 5785, '2e73c40c-e904-427f-9db9-e28d2c6578a3_Untitled.png'),
(144, 5784, '1cc31cbd-cd97-4a6d-9141-c6baa2fb61bc_loại bỏ viền trắng.png'),
(145, 14, '18dc76d1-4f21-4a6d-8dcd-9b0ec559b91c_Gateman F300-FH.jpg'),
(146, 14, '297e3625-a9b5-475f-8313-059ec3c53f67_gateman-f300fh_2048x2048-1.jpg'),
(147, 14, '5cba185a-6e59-4f30-a076-4102df5181d5_Untitled (1).png');

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
(12, 92, 'àdasfadsfdsafsadfasdf', 'REFUNDED', 29030000.00, 'Refunded via Stripe. àasdfsfds', '2025-06-13 04:47:09', '2025-06-13 04:47:23'),
(13, 109, 'fsdgdfsgsdfgsdfg', 'REFUNDED', 8530000.00, 'Refunded via Stripe. cgfdgffsdfgdfgsdfgdf', '2025-12-13 03:04:46', '2025-12-13 03:05:04');

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
(5, 3, 18, 5, 'VIP\n', 'Cảm ơn bạn', 19, '2025-11-05 21:42:28', '2025-11-05 02:19:50', '2025-11-05 21:42:28'),
(6, 5788, 20, 3, 'Super vip', 'ok', 3, '2025-12-13 13:57:53', '2025-12-13 04:27:24', '2025-12-13 13:57:53'),
(7, 3, 20, 4, 'Không ổn', 'vip vip', 3, '2025-12-13 13:57:59', '2025-12-13 04:27:42', '2025-12-13 13:57:59');

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
(3, 'Tổng tài Lạnh lùng', '0111222333', 'admin@gmail.com', 'Hanoi', '$2a$10$zgJgPl51rJQGl8xlznCKgOGipZjbaPMXiF/Zv/03ri1mA1iN1Z.su', '2024-02-21 09:00:03', '2025-11-06 02:33:11', 1, '2003-11-12 00:00:00.000000', 0, 0, 2, NULL, NULL),
(18, 'Truong Quang Lap', '0854768836', 'secroramot123@gmail.com', 'lap', '$2a$10$vagQjcnWTqYMU8mxtWsl.uF8DY3te0JzO6ObqVMkA9TfdMBa1mZEi', '2025-06-09 19:33:13', '2025-12-20 02:28:58', 1, '2003-10-26 00:00:00.000000', 0, 580957715, 1, '5e1851dd-9862-47df-9058-dda1e852f7a7', '2025-12-20 02:43:58'),
(19, 'Lap Truong Quang', '0975050669', 'lapduynh11@gmail.com', 'addsadasdasd', '$2a$10$Mx7VmM5VdSMRgR33Z2xGiuKkys1L6a1lSoLSxZ1nuSAG5aZjFFc5q', '2025-11-05 19:52:01', '2025-11-05 20:00:43', 1, '2025-11-05 19:51:32.495000', 0, 0, 3, NULL, NULL),
(20, 'Lap Truong Quang', '0222333444', 'leonelpessiu@gmail.com', 'Mình Loc', '$2a$10$CDfLU.2k9T5LiFj3JcniwOPzWbtpWapeHUFodlLuWo38gQJA8p3Nq', '2025-12-13 04:27:00', '2025-12-15 05:36:11', 1, '2003-10-28 00:00:00.000000', 0, 0, 1, NULL, NULL),
(21, 'Gyuko Fguj', '0444555666', 'kalibenzena@gmail.com', 'TQL', '$2a$10$p3mJHDHuizIl3kpqaq8QR.W8TnrcWTD7NlEOtdT9sqg4QRK5Dyjbm', '2025-12-15 05:39:10', '2025-12-15 05:39:10', 1, '2003-10-28 00:00:00.000000', 0, 0, 1, NULL, NULL);

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
(1, 'SALE66', 'Giảm giá nhân dịp 15/12', 'Giảm giá nhân dịp 15/12', 20, 500000, 100000, 100, 100, '2024-05-31 03:00:00', '2026-06-30 02:59:00', 1, '2025-06-09 18:19:46', '2025-12-13 04:26:00'),
(11, 'SAMSUNG', 'Sản phẩm SAMSUNG', '', 10, 1, NULL, 233, 230, '2025-11-05 12:14:32', '2025-12-24 12:14:32', 1, '2025-11-06 02:14:53', '2025-12-13 05:13:21');

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
(3, 11, 94, 18, 380000, '2025-11-06 02:15:09'),
(4, 11, 95, 18, 850000, '2025-11-06 14:45:09'),
(5, 11, 115, 20, 5420886, '2025-12-13 05:13:21');

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
  ADD KEY `idx_orders_payment_intent_id` (`payment_intent_id`),
  ADD KEY `fk_orders_assigned_staff` (`assigned_staff_id`);

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
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT cho bảng `carts`
--
ALTER TABLE `carts`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=45;

--
-- AUTO_INCREMENT cho bảng `categories`
--
ALTER TABLE `categories`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT cho bảng `lock_features`
--
ALTER TABLE `lock_features`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT cho bảng `news`
--
ALTER TABLE `news`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT cho bảng `orders`
--
ALTER TABLE `orders`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=123;

--
-- AUTO_INCREMENT cho bảng `order_details`
--
ALTER TABLE `order_details`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=158;

--
-- AUTO_INCREMENT cho bảng `products`
--
ALTER TABLE `products`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5791;

--
-- AUTO_INCREMENT cho bảng `product_features`
--
ALTER TABLE `product_features`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=89;

--
-- AUTO_INCREMENT cho bảng `product_images`
--
ALTER TABLE `product_images`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=148;

--
-- AUTO_INCREMENT cho bảng `return_requests`
--
ALTER TABLE `return_requests`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT cho bảng `reviews`
--
ALTER TABLE `reviews`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT cho bảng `roles`
--
ALTER TABLE `roles`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT cho bảng `users`
--
ALTER TABLE `users`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT cho bảng `vouchers`
--
ALTER TABLE `vouchers`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT cho bảng `voucher_usage`
--
ALTER TABLE `voucher_usage`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Ràng buộc đối với các bảng kết xuất
--

--
-- Ràng buộc cho bảng `carts`
--
ALTER TABLE `carts`
  ADD CONSTRAINT `FK__products` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`),
  ADD CONSTRAINT `FK__users` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Ràng buộc cho bảng `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `fk_orders_assigned_staff` FOREIGN KEY (`assigned_staff_id`) REFERENCES `users` (`id`),
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
