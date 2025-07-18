import 'package:flutter/material.dart';
import 'package:task_tracker_shared/task_tracker_shared.dart';

class TaskProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  List<Task> _tasks = [];
  String _status = 'Idle';

  List<Task> get tasks => _tasks;
  String get status => _status;

  Future<void> fetchTasks(String userId) async {
    try {
      _status = 'Fetching tasks...';
      notifyListeners();
      _tasks = await _supabaseService.getTasksForUser(userId);
      _status = 'Tasks loaded';
      notifyListeners();
    } catch (e) {
      _status = 'Error: $e';
      notifyListeners();
    }
  }

  void subscribeToTasks(String userId) {
    _supabaseService.subscribeToTasks(userId).listen((tasks) {
      _tasks = tasks;
      _status = 'Tasks updated';
      notifyListeners();
    });
  }

  Future<void> updateTaskStatus(String taskId, String status) async {
    try {
      _status = 'Updating task...';
      notifyListeners();
      await _supabaseService.updateTaskStatus(taskId, status);
      _status = 'Task updated';
      notifyListeners();
    } catch (e) {
      _status = 'Error: $e';
      notifyListeners();
    }
  }
}