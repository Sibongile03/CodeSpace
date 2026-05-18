import 'package:flutter/material.dart';
import 'package:flutter_application_4/models/index.dart';
import 'package:flutter_application_4/services/supabase_service.dart';

class AdminViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<StudentApplication> _allApplications = [];
  List<StudentApplication> _filteredApplications = [];
  bool _isLoading = false;
  String? _error;
  String _filterStatus = 'all';

  List<StudentApplication> get allApplications => _allApplications;
  List<StudentApplication> get filteredApplications => _filteredApplications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get filterStatus => _filterStatus;

  Future<void> fetchAllApplications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allApplications = await _supabaseService.getAllApplications();
      _applyFilter();
    } catch (e) {
      _error = e.toString();
      _filteredApplications = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> approveApplication(String applicationId, String? adminNotes) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supabaseService.updateApplicationStatus(applicationId, 'approved', adminNotes);

      final index = _allApplications.indexWhere(
        (app) => app.id == applicationId,
      );
      if (index != -1) {
        _allApplications[index] = _allApplications[index].copyWith(
          status: 'approved',
          adminNotes: adminNotes,
        );
      }

      _applyFilter();
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

  Future<bool> rejectApplication(String applicationId, String? adminNotes) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supabaseService.updateApplicationStatus(applicationId, 'rejected', adminNotes);

      final index = _allApplications.indexWhere(
        (app) => app.id == applicationId,
      );
      if (index != -1) {
        _allApplications[index] = _allApplications[index].copyWith(
          status: 'rejected',
          adminNotes: adminNotes,
        );
      }

      _applyFilter();
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
      _allApplications.removeWhere((app) => app.id == applicationId);
      _applyFilter();

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

  void setFilter(String status) {
    _filterStatus = status;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_filterStatus == 'all') {
      _filteredApplications = _allApplications;
    } else {
      _filteredApplications = _allApplications
          .where((app) => app.status == _filterStatus)
          .toList();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
