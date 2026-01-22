-- 1) pick a caregiver id
select id, full_name from public.caregivers limit 5;

-- 2) pick your logged-in user id (client)
select id, email from auth.users order by created_at desc limit 5;

-- 3) insert a request (REPLACE the two UUIDs)
insert into public.requests (
  client_user_id,
  caregiver_id,
  status,
  requested_date,
  notes
) values (
  'YOUR_CLIENT_USER_UUID_HERE',
  'YOUR_CAREGIVER_UUID_HERE',
  'pending',
  current_date + 1,
  'Demo request from client'
);

-- 4) verify
select * from public.requests order by created_at desc;