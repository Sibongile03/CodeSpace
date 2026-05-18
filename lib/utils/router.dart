import 'package:go_router/go_router.dart';
import 'package:flutter_application_4/views/screens/index.dart';
import 'package:flutter_application_4/models/index.dart';

final goRouter = GoRouter(
  initialLocation: '/auth',
  redirect: (context, state) {
    // Handle redirects if needed
    return null;
  },
  routes: [
    GoRoute(
      path: '/auth',
      name: 'auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/student-home',
      name: 'studentHome',
      builder: (context, state) => const StudentHomeScreen(),
    ),
    GoRoute(
      path: '/application-form',
      name: 'applicationForm',
      builder: (context, state) {
        final existingApp = state.extra as StudentApplication?;
        return ApplicationFormScreen(existingApplication: existingApp);
      },
    ),
    GoRoute(
      path: '/application-detail',
      name: 'applicationDetail',
      builder: (context, state) {
        final app = state.extra as StudentApplication;
        return ApplicationDetailScreen(application: app);
      },
    ),
    GoRoute(
      path: '/admin-dashboard',
      name: 'adminDashboard',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
  ],
);
