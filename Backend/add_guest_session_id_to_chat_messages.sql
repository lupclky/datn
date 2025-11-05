-- Add guest_session_id column to chat_messages table
-- This allows guest users to send messages using a session ID from localStorage
-- instead of requiring a user account

ALTER TABLE `chat_messages`
ADD COLUMN `guest_session_id` VARCHAR(255) NULL COMMENT 'Session ID của khách vãng lai (từ localStorage)' AFTER `sender_id`,
ADD INDEX `idx_guest_session` (`guest_session_id`);

-- Update constraint: sender_id can be null if guest_session_id is provided
-- Note: This might require dropping and recreating the foreign key constraint
-- For now, we'll allow null sender_id since we're adding guest_session_id

