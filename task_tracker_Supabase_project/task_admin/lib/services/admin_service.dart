import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:task_tracker_shared/task_tracker_shared.dart';

class AdminService {
  final SupabaseService _supabaseService = SupabaseService();
  final ExcelService _excelService = ExcelService();
  List<String> _lastAddedStudentIds = []; // Store IDs of students added via Excel

  List<String> get lastAddedStudentIds => _lastAddedStudentIds;

  Future<void> uploadExcel(PlatformFile file) async {
    try {
      _lastAddedStudentIds.clear(); // Reset the list for new uploads
      final students = await _excelService.parseExcel(file);
      for (var student in students) {
        final newUser = await _supabaseService.createUser(
          User(
            id: null, // Let Supabase generate the ID
            name: student['name'] as String,
            email: student['email'] as String?,
            role: 'student',
            createdAt: DateTime.now(),
          ),
        );
        _lastAddedStudentIds.add(newUser.id!); // Store the generated ID
      }
    } catch (e) {
      throw Exception('Failed to upload Excel: $e');
    }
  }

  Future<void> exportData(List<User> students, List<Task> tasks) async {
    try {
      // Prepare data for completed tasks
      final data = tasks.map((task) {
        final student = students.firstWhere(
              (s) => s.id == task.assignedTo,
          orElse: () => User(
            id: null,
            name: 'Unknown',
            role: 'student',
            createdAt: DateTime.now(),
          ),
        );
        return {
          'student_id': student.id ?? 'N/A',
          'student_name': student.name,
          'task_title': task.title,
          'completion_date': task.createdAt != null
              ? DateFormat('MMM d, yyyy').format(task.createdAt!)
              : 'Unknown',
        };
      }).toList();

      // Export to Excel
      await _excelService.exportToExcel(data, 'completed_tasks_report.xlsx');
    } catch (e) {
      throw Exception('Failed to export data: $e');
    }
  }
}