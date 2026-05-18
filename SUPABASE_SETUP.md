# Supabase Backend Setup Guide

Complete setup instructions for the Student Assistant Application System using Supabase.

## Prerequisites

- Supabase account (https://supabase.com)
- Access to create a new project
- For group assignment: All members use same project

---

## Step 1: Create Supabase Project

### For Project Owner

1. Go to https://supabase.com
2. Sign in or create account
3. Click "New Project"
4. Fill in details:
   - **Project Name**: `student-assistant-app`
   - **Database Password**: Create strong password
   - **Region**: Choose closest to your location
5. Wait for project initialization (~2 minutes)
6. Go to Project Settings > API
   - Copy **Project URL**
   - Copy **anon public** key
   - Copy **service_role** key (keep secret)

### For Group Members Joining

1. Ask project owner for:
   - Project URL
   - Anon public key
2. Add to your `supabase_config.dart` (see Step 5)

---

## Step 2: Create Database Tables

In your Supabase project, go to **SQL Editor** and run this complete setup script:

```sql
-- ============================================
-- STUDENT ASSISTANT APPLICATION SYSTEM
-- Database Setup Script
-- ============================================

-- CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email VARCHAR(255) NOT NULL UNIQUE,
  role VARCHAR(50) NOT NULL DEFAULT 'student' CHECK (role IN ('student', 'admin')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
-- ============================================
-- INSERT SAMPLE MODULES (FOR TESTING)
-- ============================================

INSERT INTO public.modules (code, name, level, description) VALUES
-- 1st Year Modules
('CS101', 'Introduction to Programming', '1st Year', 'Fundamentals of programming concepts and logic'),
('CS102', 'Data Structures', '1st Year', 'Arrays, linked lists, stacks, and queues'),
('MATH101', 'Calculus I', '1st Year', 'Differential and integral calculus'),

-- 2nd Year Modules
('CS201', 'Algorithms', '2nd Year', 'Algorithm design and analysis'),
('CS202', 'Database Systems', '2nd Year', 'Database design and SQL'),
('CS203', 'Web Development', '2nd Year', 'Frontend and backend web development'),

-- 3rd Year Modules
('CS301', 'Software Engineering', '3rd Year', 'Software development methodologies'),
('CS302', 'Machine Learning', '3rd Year', 'Machine learning fundamentals and applications'),
('CS303', 'Cloud Computing', '3rd Year', 'Cloud architecture and services')
ON CONFLICT (code) DO NOTHING;

-- ============================================
-- ENABLE ROW LEVEL SECURITY
-- ============================================

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.application_modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.application_documents ENABLE ROW LEVEL SECURITY;
```

---

## Step 3: Configure Row Level Security (RLS) Policies

RLS ensures data isolation between users. Run this script in SQL Editor:

```sql
-- ============================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- Ensures data isolation and access control
-- ============================================

-- 1. USERS TABLE POLICIES
-- Allow users to read their own profile
CREATE POLICY "Users can read own profile"
ON public.users FOR SELECT
USING (auth.uid() = id);

-- Allow admins to read all profiles
CREATE POLICY "Admins can read all profiles"
ON public.users FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.users
    WHERE id = auth.uid() AND role = 'admin'
  )
);

-- Allow users to update their own profile
CREATE POLICY "Users can update own profile"
ON public.users FOR UPDATE
USING (auth.uid() = id);

-- ============================================
-- 2. MODULES TABLE POLICIES
-- All authenticated users can read modules
CREATE POLICY "Authenticated users can read modules"
ON public.modules FOR SELECT
USING (auth.role() = 'authenticated');

-- ============================================
-- 3. APPLICATIONS TABLE POLICIES

-- Students can create applications
CREATE POLICY "Students can create applications"
ON public.applications FOR INSERT
WITH CHECK (
  auth.uid() = student_id AND
  EXISTS (
    SELECT 1 FROM public.users
    WHERE id = auth.uid() AND role = 'student'
  )
);

-- Students can read own applications
CREATE POLICY "Students can read own applications"
ON public.applications FOR SELECT
USING (auth.uid() = student_id);

-- Admins can read all applications
CREATE POLICY "Admins can read all applications"
ON public.applications FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.users
    WHERE id = auth.uid() AND role = 'admin'
  )
);

-- Students can update their own pending applications
CREATE POLICY "Students can update own pending applications"
ON public.applications FOR UPDATE
USING (
  auth.uid() = student_id AND
  status = 'pending'
);

-- Students can delete their own pending applications
CREATE POLICY "Students can delete own pending applications"
ON public.applications FOR DELETE
USING (
  auth.uid() = student_id AND
  status = 'pending'
);

-- Admins can update all applications
CREATE POLICY "Admins can update all applications"
ON public.applications FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM public.users
    WHERE id = auth.uid() AND role = 'admin'
  )
);

-- Admins can delete applications
CREATE POLICY "Admins can delete applications"
ON public.applications FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM public.users
    WHERE id = auth.uid() AND role = 'admin'
  )
);

-- ============================================
-- 4. APPLICATION_MODULES TABLE POLICIES
-- Follows application permissions

-- Students can read own application modules
CREATE POLICY "Students can read own application modules"
ON public.application_modules FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.applications
    WHERE id = application_id AND student_id = auth.uid()
  )
);

-- Admins can read all application modules
CREATE POLICY "Admins can read all application modules"
ON public.application_modules FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.users
    WHERE id = auth.uid() AND role = 'admin'
  )
);

-- Students can manage own application modules
CREATE POLICY "Students can manage own pending application modules"
ON public.application_modules FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM public.applications
    WHERE id = application_id AND student_id = auth.uid() AND status = 'pending'
  )
);

-- ============================================
-- 5. APPLICATION_DOCUMENTS TABLE POLICIES
-- Follows application permissions

-- Students can read own documents
CREATE POLICY "Students can read own application documents"
ON public.application_documents FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.applications
    WHERE id = application_id AND student_id = auth.uid()
  )
);

-- Admins can read all documents
CREATE POLICY "Admins can read all application documents"
ON public.application_documents FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.users
    WHERE id = auth.uid() AND role = 'admin'
  )
);

-- Students can manage own documents
CREATE POLICY "Students can manage own application documents"
ON public.application_documents FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM public.applications
    WHERE id = application_id AND student_id = auth.uid() AND status = 'pending'
  )
);
```

---

## Step 4: Create Storage Bucket

1. Go to **Storage** in left sidebar
2. Click **Create a new bucket**
3. Name: `documents`
4. Make it **Public** for read access
5. Click **Create bucket**

### Configure Storage Policies

In **Storage > documents > Policies**, create:

```sql
-- Allow authenticated users to upload to their own folder
CREATE POLICY "Authenticated users can upload documents"
ON storage.objects FOR INSERT
WITH CHECK (
  auth.role() = 'authenticated' AND
  bucket_id = 'documents' AND
  (storage.foldername(name))[1] LIKE 'applications/%'
);

-- Allow users to read documents for their applications
CREATE POLICY "Users can read their application documents"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'documents' AND
  EXISTS (
    SELECT 1 FROM public.applications
    WHERE id::text = (storage.foldername(name))[2] AND student_id = auth.uid()
  )
);

-- Allow admins to read all documents
CREATE POLICY "Admins can read all documents"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'documents' AND
  EXISTS (
    SELECT 1 FROM public.users
    WHERE id = auth.uid() AND role = 'admin'
  )
);
```

---

## Step 5: Update Flutter Configuration

### Update `lib/constants/supabase_config.dart`

Replace with your actual Supabase credentials:

```dart
class SupabaseConfig {
  // Production Supabase credentials
  static const String supabaseUrl = 'https://your-project-id.supabase.co';
  static const String supabaseAnonKey = 'your-anon-key-here';
  
  // Local development (optional)
  static const String localUrl = 'http://localhost:54321';
  static const String localAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
}
```

### Update `lib/main.dart`

```dart
await Supabase.initialize(
  url: SupabaseConfig.supabaseUrl,
  anonKey: SupabaseConfig.supabaseAnonKey,
);
```

---

## Step 6: Initialize User Profile

After authentication, the app automatically creates a user profile. To manually set an admin:

```sql
-- Set a user as admin (run in SQL Editor)
UPDATE public.users
SET role = 'admin'
WHERE email = 'admin@example.com';
```

---

## Step 7: Test Supabase Connection

### Test Authentication

1. Run the app: `flutter run`
2. Click "Don't have an account? Sign Up"
3. Create account with test email
4. Check Supabase **Auth > Users** to verify

### Test Database

1. In Supabase, go to **Database > Browser**
2. Check **users** table - your account should appear
3. Create a test application in the app
4. Verify in **applications** table

### Test Storage

1. Upload a document from the app (optional feature)
2. Check **Storage > documents** bucket

---

## Step 8: Group Setup (For Team Assignment)

### Project Owner Steps

1. Create Supabase project (Steps 1-7)
2. Share with team:
   - Project URL
   - Anon public key
   - Database credentials (if needed)

### Team Member Steps

1. Add to `supabase_config.dart`:
   ```dart
   static const String supabaseUrl = '[shared-url]';
   static const String supabaseAnonKey = '[shared-anon-key]';
   ```
2. Run: `flutter pub get && flutter run`
3. Test: Create account and submit application

---

## Troubleshooting

### "Supabase initialization failed"
- ✓ Check URL format (should be `https://...supabase.co`)
- ✓ Verify anon key is correct
- ✓ Ensure Supabase project is active

### "Auth failed" errors
- ✓ Check email format is valid
- ✓ Password must be 6+ characters
- ✓ Verify email isn't already registered

### "Permission denied" in database
- ✓ Check RLS policies are enabled
- ✓ Verify user role is set correctly
- ✓ Ensure user is authenticated

### Applications not loading
- ✓ Check user is authenticated
- ✓ Verify RLS SELECT policy exists
- ✓ Test: `SELECT * FROM applications WHERE student_id = '[your-id]'`

### Storage upload fails
- ✓ Verify bucket is public
- ✓ Check storage policies are correct
- ✓ Ensure file path format is valid

---

## Security Best Practices

✅ **Credentials**
- Never commit `.env` files with credentials
- Use environment variables in production
- Rotate keys regularly

✅ **Database**
- RLS enabled on all tables
- Only anon key in Flutter app
- Service role key kept on server only

✅ **Storage**
- Bucket set to public for reads
- Path-based access control
- Virus scanning enabled (Supabase Pro)

✅ **Authentication**
- Email verification enabled
- Password requirements enforced
- JWT tokens with expiration

---

## Reference Tables

### Users Table
| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key (from auth.users) |
| email | VARCHAR | Unique email address |
| role | VARCHAR | 'student' or 'admin' |
| created_at | TIMESTAMP | Account creation time |
| updated_at | TIMESTAMP | Last update time |

### Modules Table
| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| code | VARCHAR | Unique module code |
| name | VARCHAR | Module name |
| level | VARCHAR | Year level |
| description | TEXT | Module description |

### Applications Table
| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| student_id | UUID | Foreign key to users |
| status | VARCHAR | pending/approved/rejected |
| year_of_study | VARCHAR | Student's year |
| meets_requirements | BOOLEAN | Eligibility confirmation |
| created_at | TIMESTAMP | Submission time |
| updated_at | TIMESTAMP | Last update time |

### Application Modules Table
| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| application_id | UUID | FK to applications |
| module_id | UUID | FK to modules |
| created_at | TIMESTAMP | Association time |

### Application Documents Table
| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| application_id | UUID | FK to applications |
| file_name | VARCHAR | Original filename |
| file_path | VARCHAR | Storage path |
| uploaded_at | TIMESTAMP | Upload time |

---

## Additional Resources

- **Supabase Dashboard**: https://app.supabase.com
- **Supabase Documentation**: https://supabase.com/docs
- **Authentication Docs**: https://supabase.com/docs/guides/auth
- **Database Docs**: https://supabase.com/docs/guides/database
- **Storage Docs**: https://supabase.com/docs/guides/storage
- **RLS Policies**: https://supabase.com/docs/guides/auth/row-level-security

---

## Verification Checklist

- ✅ Supabase project created
- ✅ All 5 tables created
- ✅ Indexes created
- ✅ RLS policies enabled
- ✅ Storage bucket created
- ✅ Credentials updated in Flutter
- ✅ Test signup successful
- ✅ Test application creation works
- ✅ Admin can view all applications
- ✅ Students see only own applications

**Ready for deployment!**
