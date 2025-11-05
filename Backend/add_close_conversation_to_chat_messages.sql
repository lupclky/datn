-- Add is_closed and closed_by fields to chat_messages table
-- This allows staff/admin to close conversations

ALTER TABLE `chat_messages`
ADD COLUMN `is_closed` TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Cuộc trò chuyện đã được đóng' AFTER `is_staff_message`,
ADD COLUMN `closed_by` INT NULL COMMENT 'ID người đóng cuộc trò chuyện (staff/admin)' AFTER `is_closed`,
ADD COLUMN `closed_at` DATETIME NULL COMMENT 'Thời gian đóng cuộc trò chuyện' AFTER `closed_by`,
ADD INDEX `idx_is_closed` (`is_closed`),
ADD INDEX `idx_closed_by` (`closed_by`),
ADD CONSTRAINT `fk_chat_closed_by` FOREIGN KEY (`closed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

