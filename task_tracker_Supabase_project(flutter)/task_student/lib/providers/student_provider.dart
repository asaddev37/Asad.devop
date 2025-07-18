import 'package:flutter/material.dart';
import 'package:task_tracker_shared/task_tracker_shared.dart';

class StudentProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  User? _currentStudent;
  String _status = 'Idle';

  User? get currentStudent => _currentStudent;
  String get status => _status;

  Future<bool> authenticateStudent(String id) async {
    try {
      _status = 'Authenticating...';
      notifyListeners();
      final user = await _supabaseService.getUser(id);
      if (user != null && user.role == 'student') {
        _currentStudent = user;
        _status = 'Authenticated';
        notifyListeners();
        return true;
      } else {
        _status = 'Invalid ID';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = 'Error: $e';
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _currentStudent = null;
    _status = 'Idle';
    notifyListeners();
  }
}