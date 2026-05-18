// ** Student Numbers: XXXXXXXXX, XXXXXXXXX, XXXXXXXXX, XXXXXXXXX, XXXXXXXXX
// ** Student Names  : Name 1, Name 2, Name 3, Name 4, Name 5
// ** Question: Admin ViewModel

import 'package:flutter/material.dart';
import '../models/application_model.dart';
import '../services/application_service.dart';

enum AdminState { idle, loading, success, error }

class AdminViewModel extends ChangeNotifier {
  final ApplicationService _applicationService;

  AdminViewModel(this._applicationService);

  AdminState _state = AdminState.idle;
  List<ApplicationModel> _allApplications = [];
  List<ApplicationModel> _filteredApplications = [];
  String? _errorMessage;
  String _filterStatus = 'all';

  AdminState get state => _state;
  List<ApplicationModel> get applications => _filteredApplications;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == AdminState.loading;
  String get filterStatus => _filterStatus;

  int get totalApplications => _allApplications.length;
  int get pendingCount =>
      _allApplications.where((a) => a.status == 'pending').length;
  int get approvedCount =>
      _allApplications.where((a) => a.status == 'approved').length;
  int get rejectedCount =>
      _allApplications.where((a) => a.status == 'rejected').length;

  Future<void> loadAllApplications() async {
    _setState(AdminState.loading);

    try {
      _allApplications =
          await _applicationService.getAllApplications();
      _applyFilter();
      _setState(AdminState.success);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(AdminState.error);
    }
  }

  void filterByStatus(String status) {
    _filterStatus = status;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_filterStatus == 'all') {
      _filteredApplications = List.from(_allApplications);
    } else {
      _filteredApplications = _allApplications
          .where((a) => a.status == _filterStatus)
          .toList();
    }
  }

  Future<void> approveApplication(String id) async {
    await _updateStatus(id, 'approved');
  }

  Future<void> rejectApplication(String id) async {
    await _updateStatus(id, 'rejected');
  }

  Future<void> _updateStatus(String id, String status) async {
    _setState(AdminState.loading);

    try {
      await _applicationService.updateStatus(id, status);
      await loadAllApplications();
      _setState(AdminState.success);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(AdminState.error);
    }
  }

  Future<void> deleteApplication(String id) async {
    _setState(AdminState.loading);

    try {
      await _applicationService.deleteApplication(id);
      await loadAllApplications();
      _setState(AdminState.success);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(AdminState.error);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setState(AdminState state) {
    _state = state;
    notifyListeners();
  }
}