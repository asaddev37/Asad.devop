import '../models/task.dart';
import '../models/report.dart';

class AnalyticsService {
  Report calculateReport(List<Task> tasks, String studentId) {
    final completed = tasks.where((t) => t.status == 'completed').length;
    final pending = tasks.where((t) => t.status == 'pending').length;
    final total = completed + pending;
    final performanceScore = total > 0 ? (completed / total * 100).round() : 0;
    return Report(
      studentId: studentId,
      completedTasks: completed,
      pendingTasks: pending,
      performanceScore: performanceScore,
    );
  }

  int calculateStreak(List<Task> tasks) {
    // Placeholder: Calculate consecutive task completion days
    return 0;
  }
}