CREATE OR REPLACE FUNCTION update_last_message_at()
RETURNS trigger AS $$
BEGIN
  UPDATE chat_threads
  SET last_message_at = now()
  WHERE id = NEW.thread_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_update_last_message_at ON chat_messages;

CREATE TRIGGER trg_update_last_message_at
AFTER INSERT ON chat_messages
FOR EACH ROW
EXECUTE FUNCTION update_last_message_at();