import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:flutter_application_4/models/index.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  SupabaseClient get client => Supabase.instance.client;

  // Authentication Methods
  Future<AuthResponse> signUp(String email, String password) async {
    try {
      return await client.auth.signUp(email: email, password: password);
    } catch (e) {
      throw 'Sign up failed: $e';
    }
  }

  Future<AuthResponse> signIn(String email, String password) async {
    try {
      return await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw 'Sign in failed: $e';
    }
  }

  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      throw 'Sign out failed: $e';
    }
  }

  User? getCurrentUser() {
    final authUser = client.auth.currentUser;
    if (authUser != null) {
      return User(
        id: authUser.id,
        email: authUser.email ?? '',
        role: 'student',
      );
    }
    return null;
  }

  String? getCurrentUserId() {
    return client.auth.currentUser?.id;
  }

  // User Profile Methods
  Future<User?> getUserProfile(String userId) async {
    try {
      final response = await client
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      return User.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<void> createUserProfile(
    String userId,
    String email,
    String role,
  ) async {
    try {
      await client.from('users').insert({
        'id': userId,
        'email': email,
        'role': role,
      });
    } catch (e) {
      throw 'Failed to create user profile: $e';
    }
  }

  // Application Methods
  Future<List<StudentApplication>> getStudentApplications(
    String studentId,
  ) async {
    try {
      final response = await client
          .from('student_applications')
          .select('''
            *,
            module1:modules!student_applications_module1_id_fkey(id, code, name, level),
            module2:modules!student_applications_module2_id_fkey(id, code, name, level)
          ''')
          .eq('student_id', studentId)
          .order('created_at', ascending: false);

      return (response as List)
          .map(
            (app) => StudentApplication.fromJson(app as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw 'Failed to fetch applications: $e';
    }
  }

  Future<List<StudentApplication>> getAllApplications() async {
    try {
      final response = await client
          .from('student_applications')
          .select('''
            *,
            module1:modules!student_applications_module1_id_fkey(id, code, name, level),
            module2:modules!student_applications_module2_id_fkey(id, code, name, level)
          ''')
          .order('created_at', ascending: false);

      return (response as List)
          .map(
            (app) => StudentApplication.fromJson(app as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw 'Failed to fetch all applications: $e';
    }
  }

  Future<StudentApplication> createApplication(
    String studentId,
    String yearOfStudy,
    String module1Id,
    String? module2Id,
    bool meetsRequirements,
  ) async {
    try {
      final response = await client
          .from('student_applications')
          .insert({
            'student_id': studentId,
            'status': 'pending',
            'year_of_study': yearOfStudy,
            'module1_id': module1Id,
            'module2_id': module2Id,
            'meets_requirements': meetsRequirements,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select('''
            *,
            module1:modules!student_applications_module1_id_fkey(id, code, name, level),
            module2:modules!student_applications_module2_id_fkey(id, code, name, level)
          ''')
          .single();

      return StudentApplication.fromJson(response);
    } catch (e) {
      throw 'Failed to create application: $e';
    }
  }

  Future<void> updateApplication(
    String applicationId,
    String yearOfStudy,
    String module1Id,
    String? module2Id,
    bool meetsRequirements,
  ) async {
    try {
      await client
          .from('student_applications')
          .update({
            'year_of_study': yearOfStudy,
            'module1_id': module1Id,
            'module2_id': module2Id,
            'meets_requirements': meetsRequirements,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', applicationId);
    } catch (e) {
      throw 'Failed to update application: $e';
    }
  }

  Future<void> deleteApplication(String applicationId) async {
    try {
      await client
          .from('student_applications')
          .delete()
          .eq('id', applicationId);
    } catch (e) {
      throw 'Failed to delete application: $e';
    }
  }

  Future<void> updateApplicationStatus(
    String applicationId,
    String status,
    String? adminNotes,
  ) async {
    try {
      await client
          .from('student_applications')
          .update({
            'status': status,
            'admin_notes': adminNotes,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', applicationId);
    } catch (e) {
      throw 'Failed to update application status: $e';
    }
  }

  // Module Methods
  Future<List<Module>> getModules() async {
    try {
      final response = await client.from('modules').select();
      return (response as List)
          .map((m) => Module.fromJson(m as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw 'Failed to fetch modules: $e';
    }
  }

  Future<List<Module>> getModulesByLevel(String level) async {
    try {
      final response = await client.from('modules').select().eq('level', level);
      return (response as List)
          .map((m) => Module.fromJson(m as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw 'Failed to fetch modules by level: $e';
    }
  }

  // File Upload Methods
  Future<String> uploadApplicationDocument(
    String applicationId,
    String filePath,
    String fileName,
  ) async {
    try {
      final file = File(filePath);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storagePath =
          'applications/$applicationId/documents/$timestamp-$fileName';

      await client.storage.from('documents').upload(storagePath, file);

      return storagePath;
    } catch (e) {
      throw 'Failed to upload document: $e';
    }
  }

  Future<void> deleteApplicationDocument(String filePath) async {
    try {
      await client.storage.from('documents').remove([filePath]);
    } catch (e) {
      throw 'Failed to delete document: $e';
    }
  }

  String getDocumentUrl(String filePath) {
    try {
      return client.storage.from('documents').getPublicUrl(filePath);
    } catch (e) {
      throw 'Failed to get document URL: $e';
    }
  }
}
