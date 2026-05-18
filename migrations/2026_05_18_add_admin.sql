-- Migration: add admin (idempotent)
-- Replace the placeholder values below and run this file as the DB service role
-- (Supabase SQL editor with the service_role key or psql using the service role connection).

-- === Option A: Promote by auth user UUID ===
-- Replace <USER_UUID> with the user's UUID (e.g. '3fa85f64-...')
DO $$
DECLARE
  uid UUID := '<USER_UUID>'::uuid;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE id = uid) THEN
    RAISE NOTICE 'No auth.user found with id %', uid;
  ELSE
    IF NOT EXISTS (SELECT 1 FROM public.users WHERE id = uid) THEN
      INSERT INTO public.users (id, email, role, created_at, updated_at)
      SELECT id, email, 'admin', NOW(), NOW()
      FROM auth.users WHERE id = uid;
    ELSE
      UPDATE public.users SET role = 'admin', updated_at = NOW() WHERE id = uid;
    END IF;
  END IF;
END $$;

-- === Option B: Promote by email ===
-- Replace <EMAIL> with the user's email (e.g. 'alice@example.com')
DO $$
DECLARE
  u_email TEXT := 'ntsutlebophelo@gmail.com';
  uid UUID;
BEGIN
  SELECT id INTO uid FROM auth.users WHERE email = u_email LIMIT 1;
  IF uid IS NULL THEN
    RAISE NOTICE 'No auth.user found with email %', u_email;
  ELSE
    IF NOT EXISTS (SELECT 1 FROM public.users WHERE id = uid) THEN
      INSERT INTO public.users (id, email, role, created_at, updated_at)
      VALUES (uid, u_email, 'admin', NOW(), NOW());
    ELSE
      UPDATE public.users SET role = 'admin', updated_at = NOW() WHERE id = uid;
    END IF;
  END IF;
END $$;

-- ============================
-- Run instructions
-- ============================
-- Supabase SQL editor: open SQL editor in your project and paste this file; run as the service_role.
-- psql example (replace placeholders and connection details):
-- PGPASSWORD=<SERVICE_ROLE_KEY> psql "host=<DB_HOST> port=5432 dbname=postgres user=postgres sslmode=require" -f migrations/2026_05_18_add_admin.sql
-- Alternatively, use the Supabase CLI or the Project SQL Editor with the service role key.
