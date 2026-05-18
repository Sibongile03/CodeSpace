# Quick Reference: Design Patterns Used

## 1. Initialization Pattern

### ✅ Reference Style Implementation
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_ANON_KEY',
  );
  
  runApp(const MyApp());
}
```

---

## 2. MultiProvider Pattern

### ✅ Reference Style Implementation
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthViewModel()),
    ChangeNotifierProvider(create: (_) => ApplicationViewModel()),
    ChangeNotifierProvider(create: (_) => AdminViewModel()),
  ],
  child: MaterialApp(
    home: Consumer<AuthViewModel>(
      builder: (context, auth, _) {
        if (auth.isAuthenticated) {
          return auth.currentUser?.role == 'admin'
              ? AdminDashboardScreen()
              : StudentHomeScreen();
        }
        return AuthScreen();
      },
    ),
  ),
)
```

---

## 3. ViewModel Pattern

### ✅ Reference Style Implementation
```dart
class AuthViewModel extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  bool _isLoading = false;
  String? _errorMessage;
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      return response.user != null;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

---

## 4. Model with JSON Pattern

### ✅ Reference Style Implementation
```dart
class Module {
  final String id;
  final String code;
  final String name;
  final String level;
  
  Module({
    required this.id,
    required this.code,
    required this.name,
    required this.level,
  });
  
  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      level: json['level'],
    );
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
    'level': level,
  };
}
```

---

## 5. Service Layer Pattern

### ✅ Reference Style Implementation
```dart
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  
  factory SupabaseService() => _instance;
  SupabaseService._internal();
  
  SupabaseClient get client => Supabase.instance.client;
  
  // All Supabase operations encapsulated here
  Future<List<StudentApplication>> getStudentApplications(
    String studentId,
  ) async {
    try {
      final response = await client
          .from('student_applications')
          .select('...')
          .eq('student_id', studentId);
      
      return (response as List)
          .map((app) => StudentApplication.fromJson(app))
          .toList();
    } catch (e) {
      throw 'Error: $e';
    }
  }
}
```

---

## 6. CRUD in ViewModel Pattern

### ✅ Reference Style Implementation
```dart
class ApplicationViewModel extends ChangeNotifier {
  final SupabaseService _service = SupabaseService();
  
  List<StudentApplication> _applications = [];
  bool _isLoading = false;
  String? _error;
  
  // CREATE
  Future<bool> createApplication(
    String studentId,
    String yearOfStudy,
    Module module1,
    Module? module2,
    bool meetsRequirements,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final app = await _service.createApplication(
        studentId,
        yearOfStudy,
        module1.id,
        module2?.id,
        meetsRequirements,
      );
      _applications.insert(0, app);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // READ
  Future<void> fetchStudentApplications(String studentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _applications = 
          await _service.getStudentApplications(studentId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // UPDATE
  Future<bool> updateApplication(
    String applicationId,
    String yearOfStudy,
    Module module1,
    Module? module2,
    bool meetsRequirements,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _service.updateApplication(
        applicationId,
        yearOfStudy,
        module1.id,
        module2?.id,
        meetsRequirements,
      );
      
      final index = 
          _applications.indexWhere((app) => app.id == applicationId);
      if (index != -1) {
        _applications[index] = _applications[index].copyWith(
          yearOfStudy: yearOfStudy,
          module1: module1,
          module2: module2,
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // DELETE
  Future<bool> deleteApplication(String applicationId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _service.deleteApplication(applicationId);
      _applications.removeWhere((app) => app.id == applicationId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

---

## 7. Consumer Pattern for UI

### ✅ Reference Style Implementation
```dart
Consumer<ApplicationViewModel>(
  builder: (context, vm, child) {
    // Loading State
    if (vm.isLoading && vm.applications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    
    // Error State
    if (vm.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${vm.error}'),
            ElevatedButton(
              onPressed: () => vm.fetchStudentApplications(userId),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    // Empty State
    if (vm.applications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined, size: 64),
            const SizedBox(height: 16),
            const Text('No applications yet'),
            ElevatedButton(
              onPressed: () => Navigator.push(...),
              child: const Text('Create Application'),
            ),
          ],
        ),
      );
    }
    
    // Data State
    return ListView.builder(
      itemCount: vm.applications.length,
      itemBuilder: (context, index) {
        final app = vm.applications[index];
        return ApplicationCard(application: app);
      },
    );
  },
)
```

---

## 8. Explicit Foreign Key Aliasing (Advanced)

### ✅ Reference Style + Our Enhancement
```dart
// Problem: Two FKs to same table (module1_id, module2_id)
// Solution: Use explicit FK aliasing

final response = await client
    .from('student_applications')
    .select('''
      *,
      module1:student_applications_module1_id_fkey(
        id, code, name, level
      ),
      module2:student_applications_module2_id_fkey(
        id, code, name, level
      )
    ''')
    .eq('student_id', studentId);

// Parse with nested objects
factory StudentApplication.fromJson(Map<String, dynamic> json) {
  return StudentApplication(
    id: json['id'],
    module1: json['module1'] != null
        ? Module.fromJson(json['module1'])
        : null,
    module2: json['module2'] != null
        ? Module.fromJson(json['module2'])
        : null,
  );
}
```

---

## 9. RLS Policy Pattern

### ✅ Reference Style Implementation
```sql
-- Users can only see their own data
CREATE POLICY "Users can read own applications"
ON student_applications FOR SELECT
USING (auth.uid() = student_id);

-- Admin users can see all data
CREATE POLICY "Admins can read all applications"
ON student_applications FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE id = auth.uid() AND role = 'admin'
  )
);

-- Users can only create their own applications
CREATE POLICY "Users can create own applications"
ON student_applications FOR INSERT
WITH CHECK (auth.uid() = student_id);
```

---

## 10. Error Handling Pattern

### ✅ Reference Style Implementation
```dart
try {
  // Perform operation
  final response = await _supabase
      .from('student_applications')
      .insert({...});
  
  // Success: Update state
  _applications.insert(0, StudentApplication.fromJson(response[0]));
  notifyListeners();
  
} catch (e) {
  // Catch: Store error message
  _errorMessage = e.toString();
  
} finally {
  // Always: Reset loading state and notify
  _isLoading = false;
  notifyListeners();
}
```

---

## 11. Dependency Injection Pattern

### ✅ Reference Style Implementation
```dart
// In main.dart - Inject dependencies at root
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthViewModel()),
    ChangeNotifierProvider(
      create: (_) => ApplicationViewModel(), // Has access to SupabaseService
    ),
  ],
)

// In ViewModel - Access via read
final appVM = context.read<ApplicationViewModel>();
appVM.fetchStudentApplications(userId);

// In Consumer - Listen to changes
Consumer<ApplicationViewModel>(
  builder: (context, vm, child) { ... }
)
```

---

## 12. Navigation Pattern

### ✅ Reference Style Implementation
```dart
// Push with MaterialPageRoute
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ApplicationFormScreen(
      studentId: studentId,
    ),
  ),
).then((_) {
  // Refresh after returning
  context.read<ApplicationViewModel>().fetchStudentApplications(studentId);
});

// Pop with result
Navigator.pop(context, true);

// Check result
if (result == true) {
  // Refresh data
}
```

---

## Database CRUD Mapping

| Operation | Method | Supabase Call | Pattern |
|-----------|--------|--------------|---------|
| Create | `create()` | `.insert().select()` | Insert then fetch |
| Read | `fetch()` | `.select().eq()` | Select with filter |
| Update | `update()` | `.update().eq()` | Update with match |
| Delete | `delete()` | `.delete().eq()` | Delete with match |

---

## File Structure (Reference Style)

```
lib/
├── main.dart                      # Entry point
├── models/
│   ├── user.dart
│   ├── module.dart
│   ├── student_application.dart
│   └── index.dart
├── services/
│   ├── supabase_service.dart
│   └── index.dart
├── viewmodels/
│   ├── auth_viewmodel.dart
│   ├── application_viewmodel.dart
│   ├── admin_viewmodel.dart
│   └── index.dart
├── views/
│   └── screens/
│       ├── auth_screen.dart
│       ├── student_home_screen.dart
│       ├── application_form_screen.dart
│       ├── application_detail_screen.dart
│       ├── admin_dashboard_screen.dart
│       └── index.dart
└── constants/
    └── app_constants.dart
```

---

## Summary: Key Patterns

1. **Initialization**: Async Supabase setup before app
2. **Provider**: MultiProvider with multiple ViewModels
3. **ViewModel**: ChangeNotifier with CRUD, error, loading
4. **Models**: fromJson/toJson for serialization
5. **Service**: Singleton pattern for all DB operations
6. **UI**: Consumer for reactive updates
7. **Error**: try-catch-finally with user feedback
8. **RLS**: auth.uid() validation at DB level
9. **CRUD**: All 4 operations with consistent pattern
10. **Navigation**: Push/Pop with data refresh

All patterns follow professional best practices from the reference implementation.
