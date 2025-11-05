-- SQL script to add STAFF role and create chat/review reply tables
-- Run this script to update the database

-- Add STAFF role (id=3)
INSERT INTO `roles` (`id`, `name`) VALUES (3, 'STAFF')
ON DUPLICATE KEY UPDATE `name` = 'STAFF';

-- Add reply field to reviews table
ALTER TABLE `reviews` 
ADD COLUMN `staff_reply` TEXT NULL COMMENT 'Phản hồi từ nhân viên' AFTER `comment`,
ADD COLUMN `staff_reply_by` INT NULL COMMENT 'ID nhân viên phản hồi' AFTER `staff_reply`,
ADD COLUMN `staff_reply_at` DATETIME NULL COMMENT 'Thời gian phản hồi' AFTER `staff_reply_by`,
ADD INDEX `idx_staff_reply_by` (`staff_reply_by`),
ADD CONSTRAINT `fk_review_staff` FOREIGN KEY (`staff_reply_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

-- Create chat_messages table
CREATE TABLE IF NOT EXISTS `chat_messages` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `sender_id` INT NOT NULL COMMENT 'ID người gửi',
  `receiver_id` INT NULL COMMENT 'ID người nhận (NULL nếu là chat công khai)',
  `message` TEXT NOT NULL COMMENT 'Nội dung tin nhắn',
  `message_type` VARCHAR(20) NOT NULL DEFAULT 'TEXT' COMMENT 'Loại tin nhắn: TEXT, IMAGE, FILE',
  `is_read` TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Đã đọc chưa',
  `is_staff_message` TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Có phải tin nhắn từ nhân viên',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_sender` (`sender_id`),
  INDEX `idx_receiver` (`receiver_id`),
  INDEX `idx_created_at` (`created_at`),
  INDEX `idx_is_staff` (`is_staff_message`),
  CONSTRAINT `fk_chat_sender` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_chat_receiver` FOREIGN KEY (`receiver_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Bảng lưu trữ tin nhắn chat';

