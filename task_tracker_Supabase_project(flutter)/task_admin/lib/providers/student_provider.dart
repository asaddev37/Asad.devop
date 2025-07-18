import 'package:flutter/material.dart';
import 'package:task_tracker_shared/task_tracker_shared.dart';

class StudentProvider with ChangeNotifier {
  late final SupabaseService _supabaseService;
  List<User> _students = [];
  String _status = 'Idle';
  String? _lastAddedStudentId; // Store the ID of the last added student

  StudentProvider() {
    _supabaseService = SupabaseService();
  }

  List<User> get students => _students;
  String get status => _status;
  String? get lastAddedStudentId => _lastAddedStudentId;

  Future<void> fetchStudents() async {
    try {
      _status = 'Fetching students...';
      notifyListeners();
      _students = await _supabaseService.getStudents();
      _status = 'Students loaded';
      notifyListeners();
    } catch (e) {
      _status = 'Error: $e';
      notifyListeners();
    }
  }

  Future<void> addStudent(String name, String? email) async {
    try {
      _status = 'Adding student...';
      notifyListeners();
      final user = User(
        id: null, // Let Supabase generate the ID
        name: name,
        email: email,
        role: 'student',
        createdAt: DateTime.now(),
      );
      final createdUser = await _supabaseService.createUser(user);
      _lastAddedStudentId = createdUser.id; // Store the generated ID
      await fetchStudents();
      _status = 'Student added successfully! ID: ${createdUser.id}';
      notifyListeners();
    } catch (e) {
      _status = 'Error: $e';
      notifyListeners();
    }
  }

  Future<void> deleteStudent(String id) async {
    try {
      _status = 'Deleting student...';
      notifyListeners();
      await _supabaseService.deleteUser(id);
      await fetchStudents();
      _status = 'Student deleted';
      notifyListeners();
    } catch (e) {
      _status = 'Error: $e';
      notifyListeners();
    }
  }
}