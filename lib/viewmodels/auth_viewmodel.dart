import 'package:flutter/material.dart';
import 'package:flutter_application_4/models/index.dart';
import 'package:flutter_application_4/services/supabase_service.dart';

class AuthViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  AuthViewModel() {
    _initializeUser();
  }

  void _initializeUser() {
    _currentUser = _supabaseService.getCurrentUser();
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabaseService.signIn(email, password);

      if (response.user != null) {
        _currentUser = User(
          id: response.user!.id,
          email: response.user!.email ?? '',
          role: 'student',
        );

        // Fetch user profile to get role
        final userProfile = await _supabaseService.getUserProfile(
          response.user!.id,
        );
        if (userProfile != null) {
          _currentUser = userProfile;
        }

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> signUp(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabaseService.signUp(email, password);

      if (response.user != null) {
        // Create user profile
        await _supabaseService.createUserProfile(
          response.user!.id,
          response.user!.email ?? '',
          'student',
        );

        _currentUser = User(
          id: response.user!.id,
          email: response.user!.email ?? '',
          role: 'student',
        );

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _supabaseService.signOut();
      _currentUser = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
