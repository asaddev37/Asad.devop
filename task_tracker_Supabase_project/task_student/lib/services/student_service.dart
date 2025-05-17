import 'package:task_tracker_shared/task_tracker_shared.dart';

class StudentService {
  final AnalyticsService _analyticsService = AnalyticsService();

  int calculateStreak(List<Task> tasks) {
    return _analyticsService.calculateStreak(tasks);
  }

  List<String> getBadges(List<Task> tasks) {
    final completed = tasks.where((t) => t.status == 'completed').length;
    final badges = <String>[];
    if (completed >= 5) badges.add('Task Master');
    if (completed >= 10) badges.add('Super Achiever');
    return badges;
  }
}