-- Add file_url and file_name columns to chat_messages table
ALTER TABLE chat_messages 
ADD COLUMN file_url VARCHAR(500) NULL,
ADD COLUMN file_name VARCHAR(255) NULL;

