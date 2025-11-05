-- Allow guest users to chat (sender_id can be NULL)
-- This script modifies the chat_messages table to allow NULL sender_id

ALTER TABLE chat_messages 
MODIFY COLUMN sender_id BIGINT NULL;

-- Update existing messages if needed (optional)
-- This is just for reference, no action needed if table is empty

