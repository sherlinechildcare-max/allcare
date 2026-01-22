CREATE OR REPLACE FUNCTION sync_client_id()
RETURNS trigger AS $$
BEGIN
  NEW.client_id := COALESCE(NEW.client_id, NEW.client_user_id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS sync_client_id_trigger ON requests;

CREATE TRIGGER sync_client_id_trigger
BEFORE INSERT OR UPDATE ON requests
FOR EACH ROW
EXECUTE FUNCTION sync_client_id();