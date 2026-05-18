// ** Student Numbers: XXXXXXXXX, XXXXXXXXX, XXXXXXXXX, XXXXXXXXX, XXXXXXXXX
// ** Student Names  : Name 1, Name 2, Name 3, Name 4, Name 5
// ** Question: Application ViewModel

import 'dart:io';
import 'package:flutter/material.dart';
import '../models/application_model.dart';
import '../services/application_service.dart';
import '../services/storage_service.dart';

enum ApplicationState { idle, loading, success, error }

class ApplicationViewModel extends ChangeNotifier {
  final ApplicationService _applicationService;
  final StorageService _storageService;

  ApplicationViewModel(this._applicationService, this._storageService);

  ApplicationState _state = ApplicationState.idle;
  List<ApplicationModel> _applications = [];
  ApplicationModel? _selectedApplication;
  String? _errorMessage;
  bool _hasExistingApplication = false;

  ApplicationState get state => _state;
  List<ApplicationModel> get applications => _applications;
  ApplicationModel? get selectedApplication => _selectedApplication;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == ApplicationState.loading;
  bool get hasExistingApplication => _hasExistingApplication;

  Future<void> loadMyApplications() async {
    _setState(ApplicationState.loading);

    try {
      _applications = await _applicationService.getMyApplications();
      _hasExistingApplication = _applications.isNotEmpty;
      _setState(ApplicationState.success);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(ApplicationState.error);
    }
  }

  void selectApplication(ApplicationModel application) {
    _selectedApplication = application;
    notifyListeners();
  }

  Future<bool> submitApplication({
    required String studentId,
    required int yearOfStudy,
    required String module1Level,
    required String module1Name,
    String? module2Level,
    String? module2Name,
    required bool isEligible,
    File? documentFile,
  }) async {
    _setState(ApplicationState.loading);

    try {
      final alreadyApplied =
          await _applicationService.hasExistingApplication();
      if (alreadyApplied) {
        _errorMessage = 'You have already submitted an application.';
        _setState(ApplicationState.error);
        return false;
      }

      String? documentUrl;
      if (documentFile != null) {
        documentUrl = await _storageService.uploadDocument(
            documentFile, studentId);
      }

      final application = ApplicationModel(
        id: '',
        studentId: studentId,
        yearOfStudy: yearOfStudy,
        module1Level: module1Level,
        module1Name: module1Name,
        module2Level: module2Level,
        module2Name: module2Name,
        isEligible: isEligible,
        documentUrl: documentUrl,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      await _applicationService.submitApplication(application);
      await loadMyApplications();
      _setState(ApplicationState.success);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setState(ApplicationState.error);
      return false;
    }
  }

  Future<bool> updateApplication(
      String id, Map<String, dynamic> updates) async {
    _setState(ApplicationState.loading);

    try {
      await _applicationService.updateApplication(id, updates);
      await loadMyApplications();
      _setState(ApplicationState.success);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setState(ApplicationState.error);
      return false;
    }
  }

  Future<bool> deleteApplication(String id) async {
    _setState(ApplicationState.loading);

    try {
      await _applicationService.deleteApplication(id);
      await loadMyApplications();
      _setState(ApplicationState.success);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setState(ApplicationState.error);
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setState(ApplicationState state) {
    _state = state;
    notifyListeners();
  }
}