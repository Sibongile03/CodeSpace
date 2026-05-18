-- Student Assistant Application System
-- Clean Supabase SQL setup script

BEGIN;

-- Required for gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ============================================
-- TABLES (parent tables first)
-- ============================================

CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email VARCHAR(255) NOT NULL UNIQUE,
  role VARCHAR(50) NOT NULL DEFAULT 'student' CHECK (role IN ('student', 'admin')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.modules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code VARCHAR(50) NOT NULL UNIQUE,
  name VARCHAR(255) NOT NULL,
  level VARCHAR(50) NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.student_applications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  year_of_study VARCHAR(50) NOT NULL,
  module1_id UUID NOT NULL,
  module2_id UUID,
  meets_requirements BOOLEAN NOT NULL DEFAULT FALSE,
  status VARCHAR(50) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  admin_notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT student_applications_module_distinct CHECK (
    module2_id IS NULL OR module1_id <> module2_id
  )
);

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'student_applications_module1_id_fkey'
      AND conrelid = 'public.student_applications'::regclass
  ) THEN
    ALTER TABLE public.student_applications
      ADD CONSTRAINT student_applications_module1_id_fkey
      FOREIGN KEY (module1_id)
      REFERENCES public.modules(id);
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'student_applications_module2_id_fkey'
      AND conrelid = 'public.student_applications'::regclass
  ) THEN
    ALTER TABLE public.student_applications
      ADD CONSTRAINT student_applications_module2_id_fkey
      FOREIGN KEY (module2_id)
      REFERENCES public.modules(id);
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS public.application_documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  application_id UUID NOT NULL REFERENCES public.student_applications(id) ON DELETE CASCADE,
  file_name VARCHAR(255) NOT NULL,
  file_path TEXT NOT NULL,
  uploaded_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================
-- INDEXES
-- ============================================

CREATE INDEX IF NOT EXISTS idx_student_applications_student_id
  ON public.student_applications(student_id);

CREATE INDEX IF NOT EXISTS idx_student_applications_status
  ON public.student_applications(status);

CREATE INDEX IF NOT EXISTS idx_application_documents_application_id
  ON public.application_documents(application_id);

-- ============================================
-- SEED DATA (optional)
-- ============================================

INSERT INTO public.modules (code, name, level, description) VALUES
('CS101', 'Introduction to Programming', '1st Year', 'Fundamentals of programming concepts and logic'),
('CS102', 'Data Structures', '1st Year', 'Arrays, linked lists, stacks, and queues'),
('MATH101', 'Calculus I', '1st Year', 'Differential and integral calculus'),
('CS201', 'Algorithms', '2nd Year', 'Algorithm design and analysis'),
('CS202', 'Database Systems', '2nd Year', 'Database design and SQL'),
('CS203', 'Web Development', '2nd Year', 'Frontend and backend web development'),
('CS301', 'Software Engineering', '3rd Year', 'Software development methodologies'),
('CS302', 'Machine Learning', '3rd Year', 'Machine learning fundamentals and applications'),
('CS303', 'Cloud Computing', '3rd Year', 'Cloud architecture and services')
ON CONFLICT (code) DO NOTHING;

-- ============================================
-- ROW LEVEL SECURITY
-- ============================================

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.student_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.application_documents ENABLE ROW LEVEL SECURITY;

-- Helper functions to avoid recursive RLS checks on public.users
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.users
    WHERE id = auth.uid()
      AND role = 'admin'
  );
$$;

REVOKE ALL ON FUNCTION public.is_admin() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.is_admin() TO authenticated;

-- Re-runnable policy setup
DROP POLICY IF EXISTS "Users can read own profile" ON public.users;
DROP POLICY IF EXISTS "Admins can read all profiles" ON public.users;
DROP POLICY IF EXISTS "Users can update own profile" ON public.users;

DROP POLICY IF EXISTS "Authenticated users can read modules" ON public.modules;

DROP POLICY IF EXISTS "Students can create applications" ON public.student_applications;
DROP POLICY IF EXISTS "Students can read own applications" ON public.student_applications;
DROP POLICY IF EXISTS "Admins can read all applications" ON public.student_applications;
DROP POLICY IF EXISTS "Students can update own pending applications" ON public.student_applications;
DROP POLICY IF EXISTS "Students can delete own pending applications" ON public.student_applications;
DROP POLICY IF EXISTS "Admins can update all applications" ON public.student_applications;
DROP POLICY IF EXISTS "Admins can delete applications" ON public.student_applications;

DROP POLICY IF EXISTS "Students can read own application documents" ON public.application_documents;
DROP POLICY IF EXISTS "Admins can read all application documents" ON public.application_documents;
DROP POLICY IF EXISTS "Students can manage own application documents" ON public.application_documents;

DROP POLICY IF EXISTS "Authenticated users can upload documents" ON storage.objects;
DROP POLICY IF EXISTS "Users can read their application documents" ON storage.objects;
DROP POLICY IF EXISTS "Admins can read all documents" ON storage.objects;

CREATE POLICY "Users can read own profile"
ON public.users FOR SELECT
USING (auth.uid() = id);

CREATE POLICY "Admins can read all profiles"
ON public.users FOR SELECT
USING (public.is_admin());

CREATE POLICY "Users can update own profile"
ON public.users FOR UPDATE
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

CREATE POLICY "Authenticated users can read modules"
ON public.modules FOR SELECT
USING (auth.role() = 'authenticated');

CREATE POLICY "Students can create applications"
ON public.student_applications FOR INSERT
WITH CHECK (
  auth.uid() = student_id
  AND EXISTS (
    SELECT 1
    FROM public.users u
    WHERE u.id = auth.uid() AND u.role = 'student'
  )
);

CREATE POLICY "Students can read own applications"
ON public.student_applications FOR SELECT
USING (auth.uid() = student_id);

CREATE POLICY "Admins can read all applications"
ON public.student_applications FOR SELECT
USING (public.is_admin());

CREATE POLICY "Students can update own pending applications"
ON public.student_applications FOR UPDATE
USING (auth.uid() = student_id AND status = 'pending')
WITH CHECK (auth.uid() = student_id);

CREATE POLICY "Students can delete own pending applications"
ON public.student_applications FOR DELETE
USING (auth.uid() = student_id AND status = 'pending');

CREATE POLICY "Admins can update all applications"
ON public.student_applications FOR UPDATE
USING (public.is_admin())
WITH CHECK (TRUE);

CREATE POLICY "Admins can delete applications"
ON public.student_applications FOR DELETE
USING (public.is_admin());

CREATE POLICY "Students can read own application documents"
ON public.application_documents FOR SELECT
USING (
  EXISTS (
    SELECT 1
    FROM public.student_applications sa
    WHERE sa.id = application_id AND sa.student_id = auth.uid()
  )
);

CREATE POLICY "Admins can read all application documents"
ON public.application_documents FOR SELECT
USING (public.is_admin());

CREATE POLICY "Students can manage own application documents"
ON public.application_documents FOR ALL
USING (
  EXISTS (
    SELECT 1
    FROM public.student_applications sa
    WHERE sa.id = application_id
      AND sa.student_id = auth.uid()
      AND sa.status = 'pending'
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM public.student_applications sa
    WHERE sa.id = application_id
      AND sa.student_id = auth.uid()
      AND sa.status = 'pending'
  )
);

-- Storage policies (apply after creating bucket: documents)
CREATE POLICY "Authenticated users can upload documents"
ON storage.objects FOR INSERT
WITH CHECK (
  auth.role() = 'authenticated'
  AND bucket_id = 'documents'
  AND (storage.foldername(name))[1] = 'applications'
);

CREATE POLICY "Users can read their application documents"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'documents'
  AND (storage.foldername(name))[1] = 'applications'
  AND EXISTS (
    SELECT 1
    FROM public.student_applications sa
    WHERE sa.id::text = (storage.foldername(name))[2]
      AND sa.student_id = auth.uid()
  )
);

CREATE POLICY "Admins can read all documents"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'documents'
  AND public.is_admin()
);

-- ============================
-- Migration: idempotent admin promotion
-- Replace <USER_UUID> or <EMAIL> when running as the DB service role
-- Option A: Promote by auth user UUID
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

-- Option B: Promote by email
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

COMMIT;
