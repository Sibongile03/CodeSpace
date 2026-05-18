# Group Setup Guide - Shared Supabase Project

For Student Assistant Application System - Group Assignment

---

## Overview

This guide helps a development team set up and use a **shared Supabase project** where all group members connect to the same backend.

## Team Roles

### Project Owner
- Creates the Supabase project
- Sets up database schema and policies
- Manages project settings
- Shares credentials with team

### Team Members
- Use shared credentials
- Develop and test features
- Contribute to codebase
- Test in shared environment

---

## Phase 1: Project Owner Setup (5-10 minutes)

### Step 1.1: Create Supabase Project

1. Go to https://supabase.com
2. Click **New Project**
3. Fill details:
   - **Name**: `student-assistant-group` (or similar)
   - **Database Password**: Generate strong password
   - **Region**: Pick location closest to your team
4. Wait for initialization
5. Go to **Settings > API**

### Step 1.2: Collect Credentials

Copy these values and share with team (only anon key is safe):

```
Project URL: https://[your-project-id].supabase.co
Anon Public Key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

⚠️ **NEVER share:**
- Database password
- Service role key
- Any private keys

### Step 1.3: Run Database Setup

1. In Supabase, go to **SQL Editor**
2. Click **New Query**
3. Paste the complete SQL script from `SUPABASE_SETUP.md`
4. Click **Run**
5. Wait for tables to be created

### Step 1.4: Enable RLS Policies

1. In SQL Editor, create **New Query**
2. Paste RLS policies from `SUPABASE_SETUP.md`
3. Click **Run**

### Step 1.5: Create Storage Bucket

1. Go to **Storage**
2. Click **Create a new bucket**
3. Name: `documents`
4. Make **Public**
5. Click **Create bucket**

### Step 1.6: Share Credentials with Team

Create a document with:

```
SHARED SUPABASE CREDENTIALS
==========================

Project URL: https://[your-project-id].supabase.co
Anon Key: [your-anon-key]

Setup Instructions: See SUPABASE_SETUP.md
```

Send via secure channel (email, Discord, Teams, etc.)

---

## Phase 2: Team Member Setup (3-5 minutes)

### Step 2.1: Get Credentials from Owner

Request:
- Project URL
- Anon public key

### Step 2.2: Update Flutter Configuration

Edit `lib/constants/supabase_config.dart`:

```dart
class SupabaseConfig {
  // Shared team project
  static const String supabaseUrl = '[PROJECT_URL_FROM_OWNER]';
  static const String supabaseAnonKey = '[ANON_KEY_FROM_OWNER]';
}
```

### Step 2.3: Update main.dart

Ensure initialization uses correct credentials:

```dart
await Supabase.initialize(
  url: SupabaseConfig.supabaseUrl,
  anonKey: SupabaseConfig.supabaseAnonKey,
);
```

### Step 2.4: Install Dependencies

```bash
cd flutter_application_4
flutter pub get
```

### Step 2.5: Test Connection

```bash
flutter run
```

1. Create test account
2. Submit test application
3. Check Supabase dashboard to verify data appears

---

## Phase 3: Team Development (Ongoing)

### Accessing Shared Resources

#### View Applications
1. Go to Supabase dashboard
2. **Database > Browser**
3. Select **applications** table
4. See all team members' test data

#### Check Users
1. **Database > Browser > users** table
2. Verify team members' accounts exist

#### Check Modules
1. **Database > Browser > modules** table
2. See all available modules for testing

#### View Storage
1. **Storage > documents**
2. See uploaded test documents

### Local Development

Each team member develops independently:

```bash
flutter run
```

All changes sync to shared Supabase automatically.

### Testing Scenarios

#### Test as Student
1. Create new account
2. Submit application
3. Edit application
4. Delete application

#### Test as Admin
1. Create account
2. Contact owner to set role = 'admin'
3. View all applications
4. Approve/reject applications

---

## Shared Development Best Practices

### 1. Database Changes
- **Coordinate with team** before schema changes
- Test locally first
- Get owner approval
- Apply changes during off-hours if possible
- Update documentation

### 2. Test Data Management
- Use realistic test data
- Prefix test accounts (e.g., `test-member-name@example.com`)
- Clean up test data regularly
- Mark test applications clearly in notes

### 3. Credentials Management
- ✅ Share ONLY anon key
- ✅ Use environment variables (see below)
- ✅ Commit credentials template only
- ✅ Never commit actual credentials
- ❌ Never share database password
- ❌ Never share service role key

### 4. Git Workflow

#### .gitignore
Add to your project's `.gitignore`:

```
# Supabase credentials
lib/constants/supabase_config.dart
.env
.env.local
```

#### Create Template
Create `lib/constants/supabase_config.template.dart`:

```dart
class SupabaseConfig {
  // Add your credentials here
  static const String supabaseUrl = 'YOUR_PROJECT_URL';
  static const String supabaseAnonKey = 'YOUR_ANON_KEY';
}
```

Add to repository with instructions.

### 5. Communication
- Slack/Discord channel for sync
- Daily standups (optional)
- Log issues in shared tracker
- Document breaking changes

---

## Environment Variables (Optional)

For added security, use environment variables:

### Android (android/local.properties)
```properties
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

### iOS (ios/.env)
```
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

### Load in Flutter
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

// In main.dart
await dotenv.load();

await Supabase.initialize(
  url: dotenv.env['SUPABASE_URL']!,
  anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
);
```

---

## Troubleshooting

### "Project not found" error
- ✓ Check Project URL is correct
- ✓ Verify Supabase project is active
- ✓ Try copying URL again from Supabase dashboard

### "Invalid API key" error
- ✓ Verify anon key is correct
- ✓ Ensure it's the "anon public" key, not service role
- ✓ Check for accidental spaces or truncation

### "Permission denied" on signup
- ✓ Ensure auth is enabled
- ✓ Check email/password requirements
- ✓ Verify RLS policies are correct

### Can't see other team members' data
- ✓ Verify you're all on same project URL
- ✓ Check RLS policies for admin access
- ✓ Verify your role is set to 'admin'

### Applications not syncing
- ✓ Check internet connection
- ✓ Verify RLS SELECT policy exists
- ✓ Test in Supabase SQL editor first

### Team member gets "Application not found"
- ✓ Their user account needs to exist first
- ✓ They need to log in (creates user profile)
- ✓ Check RLS policies match their role

---

## Admin Role Setup

To make someone an admin:

1. **Owner logs into Supabase dashboard**
2. Go to **Database > users** table
3. Find team member's row
4. Change `role` from `'student'` to `'admin'`
5. Team member logs out and back in

Or in SQL Editor:

```sql
UPDATE public.users
SET role = 'admin'
WHERE email = 'member@example.com';
```

---

## Data Isolation Verification

RLS policies ensure:

### Students see only their own data
```sql
-- This will return ONLY the student's own applications
SELECT * FROM applications;
-- In RLS, filtered automatically to: WHERE student_id = auth.uid()
```

### Admins see all data
```sql
-- Admins see all applications (policy allows full access)
SELECT * FROM applications;
```

### Modules are visible to all
```sql
-- All authenticated users can read
SELECT * FROM modules;
```

---

## Performance Tips

### For Faster Queries
- Use indexes (already created)
- Filter in WHERE clause, not in code
- Use LIMIT for large result sets
- Cache module list locally

### Monitor Usage
1. **Analytics** in Supabase
2. **Usage** shows API calls
3. Keep under free tier limits:
   - 500 Megabytes database
   - 1 Gigabyte file storage
   - 50,000 API requests/day

---

## Common Workflows

### Adding a New Module
1. **Owner or admin** runs SQL:
   ```sql
   INSERT INTO modules (code, name, level) VALUES
   ('CS304', 'Web Security', '3rd Year', 'Web application security');
   ```
2. All team members can see it immediately
3. New applications can select it

### Approving Application
1. **Admin** logs in to app
2. Goes to **Admin Dashboard**
3. Expands application card
4. Clicks **Approve**
5. Status changes to 'approved'
6. Student sees updated status

### Resetting Test Data
```sql
-- DELETE all test applications (be careful!)
DELETE FROM applications WHERE student_id IN (
  SELECT id FROM users WHERE email LIKE '%test%'
);

-- DELETE all test users
DELETE FROM auth.users WHERE email LIKE '%test%';
```

---

## Security Reminders

✅ **DO**
- Share only anon public key
- Use HTTPS only
- Enable 2FA on Supabase account
- Rotate credentials if compromised
- Backup database regularly

❌ **DON'T**
- Commit credentials to Git
- Share database password
- Share service role key
- Use same password everywhere
- Share via unsecured channels

---

## Support & Resources

### Team Communication
- Setup Discord/Slack channel
- Share this guide with everyone
- Have owner's contact for issues

### Supabase Help
- Dashboard built-in help
- SQL documentation in console
- Supabase docs: https://supabase.com/docs
- Community: https://supabase.com/community

### Group Project Links
- Main README: `README.md`
- Setup Guide: `IMPLEMENTATION_GUIDE.md`
- Supabase Setup: `SUPABASE_SETUP.md`
- Quick Reference: `QUICK_REFERENCE.md`

---

## Checklist for Team

### Owner
- ✅ Created Supabase project
- ✅ Ran database setup SQL
- ✅ Enabled RLS policies
- ✅ Created storage bucket
- ✅ Shared credentials (anon key only)
- ✅ Set admins if needed

### Each Team Member
- ✅ Got credentials from owner
- ✅ Updated supabase_config.dart
- ✅ Ran flutter pub get
- ✅ Tested flutter run
- ✅ Created test account
- ✅ Verified data syncs
- ✅ Completed test workflow

### Before Submission
- ✅ All tests pass
- ✅ Sample data exists
- ✅ Admins configured
- ✅ Documentation complete
- ✅ Code committed
- ✅ Credentials template only (no real keys in Git)

---

## Next Steps

1. **Owner**: Complete Phase 1
2. **All Members**: Complete Phase 2
3. **Start Development**: Phase 3
4. **Regular Sync**: Daily updates

**Ready to build together! 🚀**
