import 'package:flutter/material.dart';
import 'package:flutter_application_4/models/index.dart';
import 'package:flutter_application_4/services/supabase_service.dart';

class ApplicationViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<StudentApplication> _applications = [];
  List<Module> _modules = [];
  StudentApplication? _selectedApplication;
  bool _isLoading = false;
  String? _error;

  List<StudentApplication> get applications => _applications;
  List<Module> get modules => _modules;
  StudentApplication? get selectedApplication => _selectedApplication;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchStudentApplications(String studentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _applications = await _supabaseService.getStudentApplications(studentId);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchModules() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _modules = await _supabaseService.getModules();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchModulesByLevel(String level) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _modules = await _supabaseService.getModulesByLevel(level);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

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
      final app = await _supabaseService.createApplication(
        studentId,
        yearOfStudy,
        module1.id,
        module2?.id,
        meetsRequirements,
      );

      _applications.insert(0, app);
      _selectedApplication = app;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

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
      await _supabaseService.updateApplication(
        applicationId,
        yearOfStudy,
        module1.id,
        module2?.id,
        meetsRequirements,
      );

      final index = _applications.indexWhere((app) => app.id == applicationId);
      if (index != -1) {
        _applications[index] = _applications[index].copyWith(
          yearOfStudy: yearOfStudy,
          module1: module1,
          module2: module2,
          meetsRequirements: meetsRequirements,
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> deleteApplication(String applicationId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supabaseService.deleteApplication(applicationId);
      _applications.removeWhere((app) => app.id == applicationId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  void selectApplication(StudentApplication application) {
    _selectedApplication = application;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
