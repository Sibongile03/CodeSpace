// ** Student Numbers: XXXXXXXXX, XXXXXXXXX, XXXXXXXXX, XXXXXXXXX, XXXXXXXXX
// ** Student Names  : Name 1, Name 2, Name 3, Name 4, Name 5
// ** Question: Application Service

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/application_model.dart';

class ApplicationService {
  final _supabase = Supabase.instance.client;

  Future<void> submitApplication(ApplicationModel application) async {
    await _supabase
        .from('applications')
        .insert(application.toMap());
  }

  Future<List<ApplicationModel>> getMyApplications() async {
    final userId = _supabase.auth.currentUser!.id;
    final response = await _supabase
        .from('applications')
        .select()
        .eq('student_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((map) => ApplicationModel.fromMap(map))
        .toList();
  }

  Future<List<ApplicationModel>> getAllApplications() async {
    final response = await _supabase
        .from('applications')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((map) => ApplicationModel.fromMap(map))
        .toList();
  }

  Future<void> updateApplication(
      String id, Map<String, dynamic> updates) async {
    await _supabase
        .from('applications')
        .update(updates)
        .eq('id', id);
  }

  Future<void> updateStatus(String id, String status) async {
    await _supabase
        .from('applications')
        .update({'status': status})
        .eq('id', id);
  }

  Future<void> deleteApplication(String id) async {
    await _supabase
        .from('applications')
        .delete()
        .eq('id', id);
  }

  Future<bool> hasExistingApplication() async {
    final userId = _supabase.auth.currentUser!.id;
    final response = await _supabase
        .from('applications')
        .select()
        .eq('student_id', userId);

    return (response as List).isNotEmpty;
  }
}