// ** Student Numbers: XXXXXXXXX, XXXXXXXXX, XXXXXXXXX, XXXXXXXXX, XXXXXXXXX
// ** Student Names  : Name 1, Name 2, Name 3, Name 4, Name 5
// ** Question: App Routes

import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../views/auth/login_screen.dart';
import '../views/student/home_screen.dart';
import '../views/student/application_form_screen.dart';
import '../views/student/application_detail_screen.dart';
import '../views/admin/admin_dashboard_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    final isLoggedIn = Supabase.instance.client.auth.currentUser != null;
    if (!isLoggedIn && state.fullPath != '/login') return '/login';
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/apply',
      builder: (context, state) => const ApplicationFormScreen(),
    ),
    GoRoute(
      path: '/application/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ApplicationDetailScreen(applicationId: id);
      },
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
  ],
);
