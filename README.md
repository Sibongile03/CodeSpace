# Student Assistant Application System

A comprehensive Flutter mobile application for managing Student Assistant applications with secure authentication, application management, and administrative review capabilities.

## Features

### Student Portal
- **Authentication**: Secure login/sign up using Supabase
- **Home Screen**: View submitted applications and their status
- **Application Form**: Submit applications for up to 2 modules per year
  - Select academic level (1st, 2nd, or 3rd year)
  - Choose modules available for that level
  - Confirm eligibility requirements
- **Application Details**: View full application details and manage pending applications
- **Edit/Delete**: Modify or delete applications while they remain pending

### Admin Portal
- **Dashboard**: View all submitted applications
- **Filtering**: Filter applications by status (Pending, Approved, Rejected)
- **Application Review**: View applicant information and details
- **Approval/Rejection**: Approve or reject pending applications
- **Application Management**: Delete invalid applications

### Technical Architecture

#### Architecture Pattern: MVVM
- **Models**: Data models with JSON serialization
- **ViewModels**: Business logic using Provider for state management
- **Views**: UI screens using Flutter Material Design

#### Key Technologies
- **Flutter**: Cross-platform mobile framework
- **Provider**: State management
- **Supabase**: Backend authentication, database, and file storage
- **Material Design 3**: Modern UI components

## Setup Instructions

### 1. Flutter Setup
```bash
flutter pub get
```

### 2. Supabase Configuration
1. Create a Supabase project at [supabase.com](https://supabase.com)
2. Follow the database setup in `SUPABASE_SETUP.md`
3. Update `lib/constants/supabase_config.dart` with your credentials:
   ```dart
   static const String supabaseUrl = 'https://your-project-id.supabase.co';
   static const String supabaseAnonKey = 'your-anon-key';
   ```

### 3. Create Demo Data (Optional)
Run the following SQL in Supabase console to add sample modules:

```sql
INSERT INTO modules (code, name, level) VALUES
('CS101', 'Introduction to Programming', '1st Year'),
('CS102', 'Data Structures', '1st Year'),
('CS201', 'Algorithms', '2nd Year'),
('CS202', 'Database Systems', '2nd Year'),
('CS301', 'Software Engineering', '3rd Year'),
('CS302', 'Advanced Algorithms', '3rd Year');

-- Create admin user (after signing up through the app)
UPDATE users SET role = 'admin' WHERE email = 'admin@example.com';
```

### 4. Run the Application
```bash
flutter run
```

## Usage Guide

### For Students
1. **Sign Up**: Create account with email and password
2. **Submit Application**: 
   - Select year of study
   - Choose 1-2 modules from available options
   - Confirm eligibility requirements
3. **Manage Application**:
   - View application status on home screen
   - Edit application while pending
   - Delete application if needed
4. **Sign Out**: Use menu option to logout

### For Admins
1. **Sign In**: Login with admin credentials
2. **Review Applications**:
   - View all submitted applications
   - Filter by status for easier review
3. **Make Decisions**:
   - Approve qualified applicants
   - Reject unsuitable applicants
   - Delete invalid applications

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── constants/
│   └── supabase_config.dart          # Supabase credentials
├── models/
│   ├── user.dart                     # User model
│   ├── module.dart                   # Module model
│   ├── student_application.dart      # Application model
│   ├── application_document.dart     # Document model
│   └── index.dart                    # Model exports
├── services/
│   └── supabase_service.dart         # Supabase integration
├── viewmodels/
│   ├── auth_viewmodel.dart           # Authentication logic
│   ├── application_viewmodel.dart    # Application logic
│   ├── admin_viewmodel.dart          # Admin logic
│   └── index.dart                    # ViewModel exports
├── views/
│   ├── screens/
│   │   ├── auth_screen.dart          # Login/Sign up
│   │   ├── student_home_screen.dart  # Student dashboard
│   │   ├── application_form_screen.dart # Application submission
│   │   ├── application_detail_screen.dart # Application details
│   │   ├── admin_dashboard_screen.dart # Admin panel
│   │   └── index.dart                # Screen exports
│   └── widgets/                      # Reusable UI components
└── utils/
    └── router.dart                   # Navigation setup
```

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.5.0
  provider: ^6.1.0
  go_router: ^14.0.0
  file_picker: ^6.1.1
  intl: ^0.19.0
  cupertino_icons: ^1.0.8
```

## Database Schema

See `SUPABASE_SETUP.md` for complete schema details and configuration instructions.

### Core Tables
- **users**: User profiles and roles
- **modules**: Available Student Assistant modules
- **applications**: Student applications
- **application_modules**: Module selections for each application
- **application_documents**: Supporting documentation

## Authentication Flow

```
Unauthenticated User
        ↓
    Auth Screen (Login/Sign Up)
        ↓
   Authenticate with Supabase
        ↓
    Fetch User Role
        ↓
    ├── Student → Student Home Screen
    └── Admin → Admin Dashboard
```

## Application Lifecycle

```
Create Application
    ↓
[PENDING] → Can Edit/Delete
    ↓
Admin Review
    ↓
├── Approve → [APPROVED]
├── Reject → [REJECTED]
└── Delete → Application Removed
```

## Best Practices Implemented

1. **Security**:
   - Supabase authentication with secure credentials
   - Row-level security policies on database
   - User role-based access control

2. **Performance**:
   - Efficient state management with Provider
   - Lazy loading of data
   - Minimal widget rebuilds

3. **User Experience**:
   - Clean Material Design 3 interface
   - Loading indicators and error messages
   - Confirmation dialogs for destructive actions
   - Intuitive navigation flow

4. **Code Quality**:
   - MVVM architecture separation of concerns
   - Reusable models with JSON serialization
   - Centralized service layer
   - Clear file organization
Updated by Tlhompo21
