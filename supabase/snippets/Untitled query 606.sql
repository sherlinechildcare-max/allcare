select policyname, permissive, roles, cmd
from pg_policies
where tablename = 'requests';