// ** Student Numbers: XXXXXXXXX, XXXXXXXXX, XXXXXXXXX, XXXXXXXXX, XXXXXXXXX
// ** Student Names  : Name 1, Name 2, Name 3, Name 4, Name 5
// ** Question: Auth ViewModel

import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthState { idle, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;

  AuthViewModel(this._authService);

  AuthState _state = AuthState.idle;
  UserModel? _currentUser;
  String? _errorMessage;

  AuthState get state => _state;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == AuthState.loading;
  bool get isAdmin => _currentUser?.role == 'admin';

  Future<void> login(String email, String password) async {
    _setState(AuthState.loading);
    _errorMessage = null;

    try {
      final response = await _authService.login(email, password);

      if (response.user != null) {
        _currentUser = await _authService.getCurrentUserProfile();
        _setState(AuthState.success);
      } else {
        _errorMessage = 'Login failed. Please try again.';
        _setState(AuthState.error);
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setState(AuthState.error);
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _setState(AuthState.idle);
  }

  Future<void> loadCurrentUser() async {
    try {
      _currentUser = await _authService.getCurrentUserProfile();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  void _setState(AuthState state) {
    _state = state;
    notifyListeners();
  }
}