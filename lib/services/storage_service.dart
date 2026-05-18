// ** Student Numbers: XXXXXXXXX, XXXXXXXXX, XXXXXXXXX, XXXXXXXXX, XXXXXXXXX
// ** Student Names  : Name 1, Name 2, Name 3, Name 4, Name 5
// ** Question: Storage Service

import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final _supabase = Supabase.instance.client;
  final _bucketName = 'application_documents';

  Future<String> uploadDocument(File file, String studentId) async {
    final fileName =
        '${studentId}_${DateTime.now().millisecondsSinceEpoch}.pdf';

    await _supabase.storage
        .from(_bucketName)
        .upload(fileName, file);

    final url = _supabase.storage
        .from(_bucketName)
        .getPublicUrl(fileName);

    return url;
  }

  Future<void> deleteDocument(String fileName) async {
    await _supabase.storage
        .from(_bucketName)
        .remove([fileName]);
  }
}