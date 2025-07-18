class Complaint {
  final String id;
  final String title;
  final String description;
  final String status;
  final String studentId;
  final String? advisorId;
  final String? hodId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastActionAt;

  Complaint({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.studentId,
    this.advisorId,
    this.hodId,
    required this.createdAt,
    required this.updatedAt,
    this.lastActionAt,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      studentId: json['student_id'],
      advisorId: json['advisor_id'],
      hodId: json['hod_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      lastActionAt: json['last_action_at'] != null
          ? DateTime.parse(json['last_action_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'student_id': studentId,
      'advisor_id': advisorId,
      'hod_id': hodId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_action_at': lastActionAt?.toIso8601String(),
    };
  }
}
