# Quick Reference Card

## File Paths & Locations

### Configuration
- `lib/constants/supabase_config.dart` - Add your Supabase credentials here
- `lib/main.dart` - App entry point, add credentials here too

### Models
- `lib/models/user.dart` - User authentication model
- `lib/models/module.dart` - Module/Course model
- `lib/models/student_application.dart` - Application submission
- `lib/models/application_document.dart` - Document metadata

### Services
- `lib/services/supabase_service.dart` - All backend operations

### ViewModels (State Management)
- `lib/viewmodels/auth_viewmodel.dart` - Login/Signup logic
- `lib/viewmodels/application_viewmodel.dart` - Application CRUD
- `lib/viewmodels/admin_viewmodel.dart` - Admin operations

### Screens
- `lib/views/screens/auth_screen.dart` - Login/Sign up page
- `lib/views/screens/student_home_screen.dart` - Student dashboard
- `lib/views/screens/application_form_screen.dart` - Create/Edit application
- `lib/views/screens/application_detail_screen.dart` - View/Edit/Delete application
- `lib/views/screens/admin_dashboard_screen.dart` - Admin panel

### Documentation
- `README.md` - User guide
- `SUPABASE_SETUP.md` - Database schema
- `IMPLEMENTATION_GUIDE.md` - Setup instructions
- `IMPLEMENTATION_COMPLETE.md` - What was implemented

---

## Database Tables (Create in Supabase)

### users
```
id (uuid) | email (text) | role (text) | created_at | updated_at
```

### modules
```
id (uuid) | code (text) | name (text) | level (text) | created_at
```

### applications
```
id (uuid) | student_id (uuid) | status (text) | year_of_study (text) | 
meets_requirements (boolean) | created_at | updated_at
```

### application_modules
```
id (uuid) | application_id (uuid) | module_id (uuid) | created_at
```

### application_documents
```
id (uuid) | application_id (uuid) | file_name (text) | file_path (text) | uploaded_at
```

---

## Setup Checklist

- [ ] Create Supabase project at supabase.com
- [ ] Copy Project URL
- [ ] Copy Anon Key
- [ ] Update `lib/constants/supabase_config.dart`
- [ ] Update `lib/main.dart` Supabase.initialize()
- [ ] Run database setup SQL from SUPABASE_SETUP.md
- [ ] Create 'documents' storage bucket
- [ ] Run `flutter pub get`
- [ ] Run `flutter run`
- [ ] Test signup as student
- [ ] Set one user as admin in database
- [ ] Test as admin

---

## Key Dependencies

```yaml
supabase_flutter: ^2.5.0    # Backend
provider: ^6.1.0             # State management
go_router: ^14.0.0          # Navigation (ready for use)
file_picker: ^6.1.1         # File upload (ready for use)
intl: ^0.19.0               # Internationalization (ready for use)
cupertino_icons: ^1.0.8     # Icons
```

---

## Common Code Snippets

### Get Current User
```dart
final authViewModel = context.read<AuthViewModel>();
final user = authViewModel.currentUser;
final userId = user?.id;
```

### Fetch Applications
```dart
final appViewModel = context.read<ApplicationViewModel>();
await appViewModel.fetchStudentApplications(userId);
```

### Create Application
```dart
final success = await appViewModel.createApplication(
  userId,
  '1st Year',
  selectedModules,
  true,
);
```

### Navigate to Detail Screen
```dart
Navigator.of(context).pushNamed(
  '/application-detail',
  arguments: application,
);
```

### Show Error Message
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Error message')),
);
```

---

## Status Values

- `pending` - Application submitted, awaiting review
- `approved` - Application approved by admin
- `rejected` - Application rejected by admin

---

## Year of Study Values

- `1st Year`
- `2nd Year`
- `3rd Year`

---

## User Roles

- `student` - Can submit and manage applications
- `admin` - Can review and approve/reject applications

---

## Required Fields for Application

1. Year of Study (required)
2. At least 1 module (max 2)
3. Meet requirements confirmation (required)

---

## Supabase SQL Query Examples

### Get student's applications
```sql
SELECT * FROM applications WHERE student_id = 'USER_ID'
ORDER BY created_at DESC;
```

### Get modules for a year
```sql
SELECT * FROM modules WHERE level = '1st Year'
ORDER BY name;
```

### Approve application
```sql
UPDATE applications SET status = 'approved' 
WHERE id = 'APP_ID';
```

### Set user as admin
```sql
UPDATE users SET role = 'admin' 
WHERE email = 'admin@example.com';
```

### Get application with modules
```sql
SELECT a.*, m.* FROM applications a
LEFT JOIN application_modules am ON a.id = am.application_id
LEFT JOIN modules m ON am.module_id = m.id
WHERE a.id = 'APP_ID';
```

---

## Error Messages to Watch For

- "Supabase initialization failed" → Check URL and anon key
- "Sign in failed" → Check email/password format
- "Failed to fetch modules" → Check database connection
- "Failed to create application" → Check required fields
- "Not authenticated" → Need to sign in first

---

## Debugging Tips

1. Check Supabase console for real-time updates
2. Use `flutter pub get` if dependencies change
3. Use `flutter clean` if build issues occur
4. Check pubspec.lock for version conflicts
5. Use DevTools for widget debugging

---

## File Size Reference

- Models: ~2KB each
- Services: ~7KB
- ViewModels: ~3-4KB each
- Screens: ~5-12KB each
- Total: ~3000+ lines of code

---

## Next Features (Optional)

- Document upload
- Email notifications
- GPA verification
- Interview scheduling
- Application statistics
- Deadline tracking

---

## Support Resources

- Flutter docs: https://flutter.dev
- Supabase docs: https://supabase.com/docs
- Provider docs: https://pub.dev/packages/provider
- Material Design: https://m3.material.io/

---

## Contact & Documentation

- README.md - Full user guide
- IMPLEMENTATION_GUIDE.md - Complete setup
- SUPABASE_SETUP.md - Database reference

**Last Updated**: May 14, 2026
**Status**: Ready for Development & Deployment
