class UserProfile {
  final String id;
  final String email;
  final String role;
  final String name;
  final String? batchId;
  final String? departmentId;
  final String? phoneNo;
  final String? studentId;
  final String? advisorId;

  UserProfile({
    required this.id,
    required this.email,
    required this.role,
    required this.name,
    this.batchId,
    this.departmentId,
    this.phoneNo,
    this.studentId,
    this.advisorId,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'],
        email: json['email'],
        role: json['role'],
        name: json['name'],
        batchId: json['batch_id'],
        departmentId: json['department_id'],
        phoneNo: json['phone_no'],
        studentId: json['student_id'],
        advisorId: json['advisor_id'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'role': role,
        'name': name,
        'batch_id': batchId,
        'department_id': departmentId,
        'phone_no': phoneNo,
        'student_id': studentId,
        'advisor_id': advisorId,
      };
}
