import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_4/viewmodels/index.dart';
import 'package:flutter_application_4/utils/router.dart';

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
      child: MaterialApp.router(
        routerConfig: goRouter,
        debugShowCheckedModeBanner: false,
        title: 'Student Assistant Portal',
        theme: ThemeData(
          useMaterial3: true,
          primarySwatch: Colors.teal,
          appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        ),
      ),
    ),
  );
}
