// ** Student Numbers: XXXXXXXXX, XXXXXXXXX, XXXXXXXXX, XXXXXXXXX, XXXXXXXXX
// ** Student Names  : Name 1, Name 2, Name 3, Name 4, Name 5
// ** Question: App Root

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/routes.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/application_viewmodel.dart';
import 'viewmodels/admin_viewmodel.dart';
import 'services/auth_service.dart';
import 'services/application_service.dart';
import 'services/storage_service.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(AuthService()),
        ),
        ChangeNotifierProvider(
          create: (_) => ApplicationViewModel(
            ApplicationService(),
            StorageService(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AdminViewModel(ApplicationService()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Student Assistant App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        routerConfig: appRouter,
      ),
    );
  }
}