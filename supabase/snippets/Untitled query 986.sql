ALTER TABLE requests
ADD COLUMN client_id uuid;

UPDATE requests
SET client_id = client_user_id;

-- Optional: keep them in sync
CREATE OR REPLACE FUNCTION sync_client_id()
RETURNS trigger AS $$
BEGIN
  NEW.client_id := NEW.client_user_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER sync_client_id_trigger
BEFORE INSERT OR UPDATE ON requests
FOR EACH ROW
EXECUTE FUNCTION sync_client_id();