update profiles
set role = 'client',
    onboarding_completed = true
where id = auth.uid();