// ** Student Numbers: XXXXXXXXX, XXXXXXXXX, XXXXXXXXX, XXXXXXXXX, XXXXXXXXX
// ** Student Names  : Name 1, Name 2, Name 3, Name 4, Name 5
// ** Question: User Model

class UserModel {
  final String id;
  final String fullName;
  final String studentNumber;
  final String role;
  final int? yearOfStudy;

  UserModel({
    required this.id,
    required this.fullName,
    required this.studentNumber,
    required this.role,
    this.yearOfStudy,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      fullName: map['full_name'],
      studentNumber: map['student_number'],
      role: map['role'],
      yearOfStudy: map['year_of_study'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'student_number': studentNumber,
      'role': role,
      'year_of_study': yearOfStudy,
    };
  }
}