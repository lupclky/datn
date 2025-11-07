-- Migration script: Update chat system to conversation-based model
-- Version: 2.0
-- Date: 2025-11-06

-- Step 1: Add new columns to chat_conversations table
ALTER TABLE `chat_conversations`
  ADD COLUMN `closed_by_id` INT NULL AFTER `is_closed`,
  ADD COLUMN `closed_at` DATETIME NULL AFTER `closed_by_id`,
  ADD COLUMN `first_message_at` DATETIME NULL AFTER `closed_at`,
  ADD COLUMN `last_message_at` DATETIME NULL AFTER `first_message_at`;

-- Step 2: Add foreign key for closed_by
ALTER TABLE `chat_conversations`
  ADD CONSTRAINT `fk_conv_closed_by` FOREIGN KEY (`closed_by_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

-- Step 3: Remove closure tracking from chat_messages (moved to conversation level)
ALTER TABLE `chat_messages`
  DROP COLUMN IF EXISTS `is_closed`,
  DROP COLUMN IF EXISTS `closed_by`,
  DROP COLUMN IF EXISTS `closed_at`;

-- Step 4: Make conversation_id REQUIRED in chat_messages
-- First, update all existing messages to link to a conversation
-- Create a default conversation for orphan messages

-- Option A: If you have no data or can recreate:
-- TRUNCATE TABLE `chat_messages`;
-- ALTER TABLE `chat_messages` MODIFY COLUMN `conversation_id` INT UNSIGNED NOT NULL;

-- Option B: For existing data with orphan messages:
-- Create a temp conversation for orphan messages
INSERT INTO `chat_conversations` (`id`, `customer_id`, `staff_id`, `guest_session_id`, `is_closed`, `created_at`, `updated_at`)
VALUES (999999, NULL, NULL, 'ORPHAN_MIGRATION', 0, NOW(), NOW())
ON DUPLICATE KEY UPDATE `id` = `id`;

-- Link all orphan messages to temp conversation
UPDATE `chat_messages` 
SET `conversation_id` = 999999 
WHERE `conversation_id` IS NULL;

-- Now make conversation_id required
ALTER TABLE `chat_messages` 
  MODIFY COLUMN `conversation_id` INT UNSIGNED NOT NULL;

-- Step 5: Add indexes for performance
ALTER TABLE `chat_conversations`
  ADD INDEX `idx_conv_closed_at` (`closed_at`),
  ADD INDEX `idx_conv_last_message` (`last_message_at`);

-- Step 6: Populate timestamps for existing conversations from their messages
UPDATE `chat_conversations` c
SET 
  `first_message_at` = (
    SELECT MIN(m.created_at) 
    FROM `chat_messages` m 
    WHERE m.conversation_id = c.id
  ),
  `last_message_at` = (
    SELECT MAX(m.created_at) 
    FROM `chat_messages` m 
    WHERE m.conversation_id = c.id
  )
WHERE c.id IS NOT NULL;

-- Step 7: Clean up - you can delete the orphan conversation after migration
-- DELETE FROM `chat_conversations` WHERE `id` = 999999;
-- DELETE FROM `chat_messages` WHERE `conversation_id` = 999999;

-- Verification queries:
-- Check all messages have conversations
SELECT COUNT(*) as orphan_messages FROM `chat_messages` WHERE `conversation_id` IS NULL;

-- Check conversations have timestamps
SELECT COUNT(*) as conversations_without_timestamps 
FROM `chat_conversations` 
WHERE `first_message_at` IS NULL AND `id` != 999999;

-- Show conversation summary
SELECT 
  c.id,
  c.customer_id,
  c.staff_id,
  c.guest_session_id,
  c.is_closed,
  c.first_message_at,
  c.last_message_at,
  (SELECT COUNT(*) FROM `chat_messages` WHERE `conversation_id` = c.id) as message_count
FROM `chat_conversations` c
ORDER BY c.last_message_at DESC;
