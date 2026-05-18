import 'package:flutter_application_4/models/module.dart';

class StudentApplication {
  final String id;
  final String studentId;
  final String status; // 'pending', 'approved', 'rejected'
  final String yearOfStudy; // '1st Year', '2nd Year', '3rd Year'
  final Module? module1;
  final Module? module2;
  final bool meetsRequirements;
  final String? adminNotes;
  final String createdAt;
  final String updatedAt;

  StudentApplication({
    required this.id,
    required this.studentId,
    required this.status,
    required this.yearOfStudy,
    this.module1,
    this.module2,
    required this.meetsRequirements,
    this.adminNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StudentApplication.fromJson(Map<String, dynamic> json) {
    return StudentApplication(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      status: json['status'] as String,
      yearOfStudy: json['year_of_study'] as String,
      module1: json['module1'] != null
          ? Module.fromJson(json['module1'] as Map<String, dynamic>)
          : null,
      module2: json['module2'] != null
          ? Module.fromJson(json['module2'] as Map<String, dynamic>)
          : null,
      meetsRequirements: json['meets_requirements'] as bool? ?? false,
      adminNotes: json['admin_notes'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'status': status,
      'year_of_study': yearOfStudy,
      'module1': module1?.toJson(),
      'module2': module2?.toJson(),
      'meets_requirements': meetsRequirements,
      'admin_notes': adminNotes,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  StudentApplication copyWith({
    String? id,
    String? studentId,
    String? status,
    String? yearOfStudy,
    Module? module1,
    Module? module2,
    bool? meetsRequirements,
    String? adminNotes,
    String? createdAt,
    String? updatedAt,
  }) {
    return StudentApplication(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      status: status ?? this.status,
      yearOfStudy: yearOfStudy ?? this.yearOfStudy,
      module1: module1 ?? this.module1,
      module2: module2 ?? this.module2,
      meetsRequirements: meetsRequirements ?? this.meetsRequirements,
      adminNotes: adminNotes ?? this.adminNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
