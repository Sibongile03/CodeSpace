-- Variant A: if your `users` table contains an `email` column
UPDATE users
SET role = 'admin'
WHERE email = 'ntsutlebophelo@gmail.com';

-- Variant B Option 1: if your app users table references auth.users by user_id
UPDATE users
SET role = 'admin'
WHERE user_id = (
  SELECT id FROM auth.users WHERE email = 'ntsutlebophelo@gmail.com'
);

-- Variant B Option 2: Postgres UPDATE ... FROM join
UPDATE users
SET role = 'admin'
FROM auth.users
WHERE users.user_id = auth.users.id
  AND auth.users.email = 'ntsutlebophelo@gmail.com';

-- Verification: confirm the change
SELECT id, email, role
FROM users
WHERE email = 'ntsutlebophelo@gmail.com';
