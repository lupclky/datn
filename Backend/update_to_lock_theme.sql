-- Update categories to Korean Fingerprint Lock brands
UPDATE `categories` SET `name` = 'GATEMAN' WHERE `id` = 1;
UPDATE `categories` SET `name` = 'SAMSUNG' WHERE `id` = 2;
UPDATE `categories` SET `name` = 'H-Gang' WHERE `id` = 3;
UPDATE `categories` SET `name` = 'EPIC' WHERE `id` = 4;
UPDATE `categories` SET `name` = 'WELKOM' WHERE `id` = 5;

-- Add new categories for locks
INSERT INTO `categories` (`id`, `name`) VALUES
(7, 'KAISER+'),
(8, 'UNICOR'),
(9, 'HiOne+'),
(10, 'Khóa cửa kính'),
(11, 'Chuông hình');

-- Update products to lock products
UPDATE `products` SET 
  `name` = 'Khóa vân tay GATEMAN N5W (Hàn Quốc)',
  `price` = 8500000,
  `description` = 'Khóa cửa vân tay thông minh GATEMAN N5W, hỗ trợ vân tay, thẻ từ, mã số, app điều khiển từ xa. Thiết kế hiện đại, bảo mật cao cấp.',
  `thumbnail` = 'gateman-n5w.jpg'
WHERE `id` = 1;

UPDATE `products` SET 
  `name` = 'Khóa cửa vân tay SAMSUNG SHP-DP728',
  `price` = 9500000,
  `description` = 'Khóa cửa vân tay Samsung chính hãng Hàn Quốc. Công nghệ vân tay công nghệ cao, khả năng chống nước IP54, sử dụng pin AA.',
  `thumbnail` = 'samsung-shp-dp728.jpg'
WHERE `id` = 2;

UPDATE `products` SET 
  `name` = 'Khóa vân tay thông minh H-Gang Sync LC-100',
  `price` = 4200000,
  `description` = 'Khóa vân tay H-Gang Sync đa tính năng: vân tay, thẻ từ, mã số, chìa cơ. Phù hợp cho cửa gỗ, cửa nhôm, thiết kế tối giản.',
  `thumbnail` = 'h-gang-sync-lc100.jpg'
WHERE `id` = 3;

UPDATE `products` SET 
  `name` = 'Khóa vân tay EPIC E10 Smart Lock',
  `price` = 6500000,
  `description` = 'Khóa vân tay thông minh Epic E10 - công nghệ chống nước, độ bảo mật cao, dễ lắp đặt và sử dụng. Hỗ trợ app điều khiển.',
  `thumbnail` = 'epic-e10.jpg'
WHERE `id` = 4;

UPDATE `products` SET 
  `name` = 'Khóa vân tay WELKOM WLX-5000',
  `price` = 5500000,
  `description` = 'Khóa vân tay WELKOM cao cấp, hỗ trợ 200 dấu vân tay, 50 mã số. Thiết kế sang trọng, phù hợp với mọi loại cửa.',
  `thumbnail` = 'welkom-wlx5000.jpg'
WHERE `id` = 5;

UPDATE `products` SET 
  `name` = 'Khóa cửa vân tay KAISER+ K2 Pro',
  `price` = 7200000,
  `description` = 'Khóa vân tay KAISER+ K2 Pro - công nghệ AI nhận diện vân tay chính xác, thời gian mở khóa dưới 0.5 giây.',
  `thumbnail` = 'kaiser-k2pro.jpg'
WHERE `id` = 6;

UPDATE `products` SET 
  `name` = 'Khóa vân tay thông minh UNICOR U90',
  `price` = 4800000,
  `description` = 'Khóa vân tay UNICOR U90 đa năng: vân tay, mật khẩu, thẻ từ, chìa cơ. Kết nối WiFi, điều khiển qua app smartphone.',
  `thumbnail` = 'unicor-u90.jpg'
WHERE `id` = 7;

UPDATE `products` SET 
  `name` = 'Khóa cửa vân tay HiOne+ H8 Premium',
  `price` = 8900000,
  `description` = 'Khóa vân tay HiOne+ H8 Premium cao cấp, thiết kế sang trọng. Hỗ trợ vân tay 360 độ, chống nước IP65, màn hình cảm ứng.',
  `thumbnail` = 'hione-h8.jpg'
WHERE `id` = 8;

UPDATE `products` SET 
  `name` = 'Khóa cửa kính vân tay Omnilock Glass-3000',
  `price` = 12000000,
  `description` = 'Khóa cửa kính vân tay thông minh Omnilock, thiết kế tinh tế cho cửa kính cường lực. Công nghệ chống va đập, bảo hành chính hãng.',
  `thumbnail` = 'omnilock-glass3000.jpg'
WHERE `id` = 9;

UPDATE `products` SET 
  `name` = 'Chuông cửa có hình Honeywell Series 7',
  `price` = 3200000,
  `description` = 'Chuông cửa video Honeywell Series 7 - màn hình 7 inch, camera HD, tính năng hai chiều, đêm hồng ngoại, chống nước IP65.',
  `thumbnail` = 'honeywell-series7.jpg'
WHERE `id` = 10;

UPDATE `products` SET 
  `name` = 'Khóa vân tay GATEMAN N10 Plus',
  `price` = 11500000,
  `description` = 'Khóa vân tay GATEMAN N10 Plus cao cấp - vân tay, thẻ từ, mã số, app. Thiết kế hiện đại, chống nước IP65, phù hợp cửa kim loại.',
  `thumbnail` = 'gateman-n10plus.jpg',
  `discount` = 15
WHERE `id` = 11;

UPDATE `products` SET 
  `name` = 'Khóa cửa vân tay SAMSUNG SHP-DR708',
  `price` = 10500000,
  `description` = 'Khóa cửa vân tay Samsung SHP-DR708 với màn hình cảm ứng, công nghệ nhận diện vân tay chính xác, thiết kế đẹp mắt.',
  `thumbnail` = 'samsung-shp-dr708.jpg',
  `discount` = 10
WHERE `id` = 12;

UPDATE `products` SET 
  `name` = 'Khóa vân tay H-Gang Master Z20',
  `price` = 6800000,
  `description` = 'Khóa vân tay H-Gang Master Z20 - công nghệ mới nhất, mở khóa nhanh 0.3 giây, hỗ trợ 200 vân tay và 50 mã số.',
  `thumbnail` = 'h-gang-master-z20.jpg',
  `discount` = 20
WHERE `id` = 13;

UPDATE `products` SET 
  `name` = 'Khóa cửa thông minh EPIC E20 WiFi',
  `price` = 7800000,
  `description` = 'Khóa vân tay EPIC E20 WiFi - kết nối WiFi, điều khiển từ xa, báo động chống trộm, thiết kế hiện đại sang trọng.',
  `thumbnail` = 'epic-e20-wifi.jpg',
  `discount` = 15
WHERE `id` = 14;

UPDATE `products` SET 
  `name` = 'Khóa vân tay WELKOM Premium Lock',
  `price` = 6200000,
  `description` = 'Khóa vân tay WELKOM Premium - thiết kế cổ điển hiện đại, chống nước IP54, tuổi thọ pin lên đến 12 tháng.',
  `thumbnail` = 'welkom-premium.jpg',
  `discount` = 12
WHERE `id` = 15;

-- Update remaining products to be relevant locks
UPDATE `products` SET 
  `name` = CONCAT('Khóa vân tay cao cấp - Model ', `id`),
  `price` = 3000000 + (RAND() * 10000000),
  `description` = 'Khóa cửa vân tay thông minh cao cấp từ Hàn Quốc. Công nghệ hiện đại, bảo mật cao, thiết kế sang trọng.',
  `category_id` = FLOOR(1 + RAND() * 11)
WHERE `id` > 15;
