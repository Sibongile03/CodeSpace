// ** Student Numbers: XXXXXXXXX, XXXXXXXXX, XXXXXXXXX, XXXXXXXXX, XXXXXXXXX
// ** Student Names  : Name 1, Name 2, Name 3, Name 4, Name 5
// ** Question: Application Model

class ApplicationModel {
  final String id;
  final String studentId;
  final int yearOfStudy;
  final String module1Level;
  final String module1Name;
  final String? module2Level;
  final String? module2Name;
  final bool isEligible;
  final String? documentUrl;
  final String status;
  final DateTime createdAt;

  ApplicationModel({
    required this.id,
    required this.studentId,
    required this.yearOfStudy,
    required this.module1Level,
    required this.module1Name,
    this.module2Level,
    this.module2Name,
    required this.isEligible,
    this.documentUrl,
    required this.status,
    required this.createdAt,
  });

  factory ApplicationModel.fromMap(Map<String, dynamic> map) {
    return ApplicationModel(
      id: map['id'],
      studentId: map['student_id'],
      yearOfStudy: map['year_of_study'],
      module1Level: map['module_1_level'],
      module1Name: map['module_1_name'],
      module2Level: map['module_2_level'],
      module2Name: map['module_2_name'],
      isEligible: map['is_eligible'],
      documentUrl: map['document_url'],
      status: map['status'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'student_id': studentId,
      'year_of_study': yearOfStudy,
      'module_1_level': module1Level,
      'module_1_name': module1Name,
      'module_2_level': module2Level,
      'module_2_name': module2Name,
      'is_eligible': isEligible,
      'document_url': documentUrl,
      'status': status,
    };
  }

  bool get isPending => status == 'pending';
}