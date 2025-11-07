-- Chat schema (MySQL 8) for Locker Korea
-- Create two tables: chat_conversations and chat_messages
-- Safe to run multiple times if you guard with IF NOT EXISTS (MySQL 8.0.13+ supports it for tables)

-- 1) Conversations
CREATE TABLE IF NOT EXISTS `chat_conversations` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `customer_id` INT NULL,
  `staff_id` INT NULL,
  `guest_session_id` VARCHAR(255) NULL,
  `is_closed` TINYINT(1) NOT NULL DEFAULT 0,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_conv_customer_staff_closed` (`customer_id`,`staff_id`,`is_closed`),
  KEY `idx_conv_guest_session_closed` (`guest_session_id`,`is_closed`),
  CONSTRAINT `fk_conv_customer` FOREIGN KEY (`customer_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_conv_staff` FOREIGN KEY (`staff_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 2) Messages
CREATE TABLE IF NOT EXISTS `chat_messages` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `sender_id` INT NULL,
  `guest_session_id` VARCHAR(255) NULL,
  `receiver_id` INT NULL,
  `conversation_id` BIGINT NULL,
  `message` TEXT NOT NULL,
  `message_type` VARCHAR(20) NOT NULL DEFAULT 'TEXT',
  `is_read` TINYINT(1) NOT NULL DEFAULT 0,
  `is_staff_message` TINYINT(1) NOT NULL DEFAULT 0,
  `is_closed` TINYINT(1) NOT NULL DEFAULT 0,
  `closed_by` INT NULL,
  `closed_at` DATETIME NULL,
  `file_url` VARCHAR(500) NULL,
  `file_name` VARCHAR(255) NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_msg_conversation_created` (`conversation_id`,`created_at`),
  KEY `idx_msg_receiver_unread` (`receiver_id`,`is_read`),
  KEY `idx_msg_guest_session` (`guest_session_id`),
  KEY `idx_msg_sender` (`sender_id`),
  KEY `idx_msg_staff_public` (`is_staff_message`,`receiver_id`),
  CONSTRAINT `fk_msg_sender` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_msg_receiver` FOREIGN KEY (`receiver_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_msg_conv` FOREIGN KEY (`conversation_id`) REFERENCES `chat_conversations` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_msg_closed_by` FOREIGN KEY (`closed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Notes
-- - Matches current JPA entities: ChatConversation, ChatMessage
-- - Supports guest chats (sender_id NULL + guest_session_id), assigned staff (receiver_id), and public staff replies (is_staff_message=1, receiver_id NULL)
-- - Closing a conversation: service currently sets flags on messages; conversation also has is_closed for quick filtering
-- - Indexes optimize: conversation retrieval, unread queries, guest session lookup
