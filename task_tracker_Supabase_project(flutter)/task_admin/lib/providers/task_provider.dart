import 'package:flutter/material.dart';
import 'package:task_tracker_shared/task_tracker_shared.dart';

class TaskProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  List<Task> _tasks = [];
  String _status = 'Idle';
  String? _error;

  List<Task> get tasks => _tasks;
  String get status => _status;
  String? get error => _error;

  Future<void> fetchTasks(String userId) async {
    try {
      _status = 'Fetching tasks...';
      _error = null;
      notifyListeners();
      _tasks = await _supabaseService.getTasksForUser(userId);
      _status = 'Tasks loaded';
      debugPrint('Fetched ${_tasks.length} user tasks');
      notifyListeners();
    } catch (e) {
      _status = 'Error: $e';
      _error = 'Failed to fetch user tasks: $e';
      debugPrint('Fetch user tasks error: $e');
      notifyListeners();
    }
  }

  Future<void> fetchAllTasks() async {
    try {
      _status = 'Fetching all tasks...';
      _error = null;
      notifyListeners();
      _tasks = await _supabaseService.getAllTasks();
      if (_tasks.isEmpty) {
        _status = 'No tasks found';
        _error = 'No tasks in Supabase or no tasks with status "completed"';
        debugPrint('No tasks found in Supabase');
      } else {
        _status = 'Tasks loaded';
        debugPrint('Fetched ${_tasks.length} tasks:');
        for (var task in _tasks) {
          debugPrint('Task: id=${task.id}, title=${task.title}, status=${task.status}, assigned_to=${task.assignedTo}');
        }
      }
      notifyListeners();
    } catch (e) {
      _status = 'Error: $e';
      _error = 'Failed to fetch all tasks: $e';
      debugPrint('Fetch all tasks error: $e');
      notifyListeners();
    }
  }

  Future<void> createTask({
    required String title,
    String? description,
    required String assignedTo,
    required String createdBy,
    DateTime? dueDate,
  }) async {
    try {
      if (!isValidUuid(assignedTo)) {
        throw Exception('Invalid assignedTo value. Must be a valid UUID.');
      }
      if (!isValidUuid(createdBy)) {
        throw Exception('Invalid createdBy value. Must be a valid UUID.');
      }

      _status = 'Creating task...';
      notifyListeners();
      final task = Task(
        id: null,
        title: title,
        description: description,
        assignedTo: assignedTo,
        createdBy: createdBy,
        status: 'pending',
        dueDate: dueDate,
        createdAt: DateTime.now(),
      );
      await _supabaseService.createTask(task);
      await fetchAllTasks();
      _status = 'Task created';
      notifyListeners();
    } catch (e) {
      _status = 'Error: $e';
      _error = 'Failed to create task: $e';
      debugPrint('Create task error: $e');
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      _status = 'Deleting task...';
      notifyListeners();
      await _supabaseService.deleteTask(taskId);
      await fetchAllTasks();
      _status = 'Task deleted';
      notifyListeners();
    } catch (e) {
      _status = 'Error: $e';
      _error = 'Failed to delete task: $e';
      debugPrint('Delete task error: $e');
      notifyListeners();
    }
  }

  bool isValidUuid(String value) {
    final uuidPattern = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    return uuidPattern.hasMatch(value);
  }
}