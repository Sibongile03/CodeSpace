import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_4/viewmodels/index.dart';
import 'package:flutter_application_4/views/screens/index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  // Replace with your actual Supabase URL and anon key
  await Supabase.initialize(
    url: 'https://cqetmzkcwyuxvnsheyfo.supabase.co',
    anonKey: 'sb_publishable_ss4iW4jhukGdm7tl9NVZiw_MrV7c-rb',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ApplicationViewModel()),
        ChangeNotifierProvider(create: (_) => AdminViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Student Assistant Portal',
        theme: ThemeData(
          useMaterial3: true,
          primarySwatch: Colors.blue,
          appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        ),
        home: Consumer<AuthViewModel>(
          builder: (context, authViewModel, _) {
            if (authViewModel.isAuthenticated) {
              final user = authViewModel.currentUser;
              if (user?.role == 'admin') {
                return const AdminDashboardScreen();
              } else {
                return const StudentHomeScreen();
              }
            }
            return const AuthScreen();
          },
        ),
      ),
    ),
  );
}
