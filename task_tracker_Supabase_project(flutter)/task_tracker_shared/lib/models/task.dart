class Task {
  final String? id;
  final String title;
  final String? description;
  final String assignedTo;
  final String createdBy;
  final String status;
  final DateTime? dueDate;
  final DateTime createdAt;

  Task({
    this.id,
    required this.title,
    this.description,
    required this.assignedTo,
    required this.createdBy,
    required this.status,
    this.dueDate,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'assigned_to': assignedTo,
      'created_by': createdBy,
      'status': status,
      'due_date': dueDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      assignedTo: json['assigned_to'] as String,
      createdBy: json['created_by'] as String,
      status: json['status'] as String,
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}