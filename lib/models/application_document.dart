/*223056129 Mokoena SP , 224085810 BBL NTSUTLE, 222019937 Melupe NE, 224120806 Maseko O, 223085941 TSM MATJENI*/ 
class ApplicationDocument {
  final String id;
  final String applicationId;
  final String fileName;
  final String filePath;
  final String uploadedAt;

  ApplicationDocument({
    required this.id,
    required this.applicationId,
    required this.fileName,
    required this.filePath,
    required this.uploadedAt,
  });

  factory ApplicationDocument.fromJson(Map<String, dynamic> json) {
    return ApplicationDocument(
      id: json['id'] as String,
      applicationId: json['application_id'] as String,
      fileName: json['file_name'] as String,
      filePath: json['file_path'] as String,
      uploadedAt: json['uploaded_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'application_id': applicationId,
      'file_name': fileName,
      'file_path': filePath,
      'uploaded_at': uploadedAt,
    };
  }
}
