-- Update chat_messages table to allow null sender_id for guest users
-- This script should be run after add_guest_session_id_to_chat_messages.sql

-- First, drop the foreign key constraint if it exists
ALTER TABLE `chat_messages` 
DROP FOREIGN KEY IF EXISTS `fk_chat_sender`;

-- Drop the index if it exists
ALTER TABLE `chat_messages`
DROP INDEX IF EXISTS `idx_sender`;

-- Modify sender_id to allow NULL
ALTER TABLE `chat_messages`
MODIFY COLUMN `sender_id` INT NULL COMMENT 'ID người gửi (NULL cho khách vãng lai)';

-- Recreate the index
ALTER TABLE `chat_messages`
ADD INDEX `idx_sender` (`sender_id`);

-- Recreate the foreign key constraint with ON DELETE SET NULL
ALTER TABLE `chat_messages`
ADD CONSTRAINT `fk_chat_sender` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

