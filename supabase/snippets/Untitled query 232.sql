ALTER TABLE chat_threads
ADD COLUMN IF NOT EXISTS last_message_at timestamptz DEFAULT now();
