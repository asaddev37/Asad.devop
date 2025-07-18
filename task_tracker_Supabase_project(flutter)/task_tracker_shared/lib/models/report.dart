class Report {
  final String studentId;
  final int completedTasks;
  final int pendingTasks;
  final int performanceScore;

  Report({
    required this.studentId,
    required this.completedTasks,
    required this.pendingTasks,
    required this.performanceScore,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      studentId: json['student_id'],
      completedTasks: json['completed_tasks'],
      pendingTasks: json['pending_tasks'],
      performanceScore: json['performance_score'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'completed_tasks': completedTasks,
      'pending_tasks': pendingTasks,
      'performance_score': performanceScore,
    };
  }
}