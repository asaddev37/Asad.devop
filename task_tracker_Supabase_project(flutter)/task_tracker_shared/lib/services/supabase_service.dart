import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:typed_data';
import '../models/user.dart';
import '../models/task.dart';
import '../models/report.dart';

class SupabaseService {
  // Singleton pattern
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  late supabase.SupabaseClient _client;

  // Initialize Supabase and load .env
  Future<void> initialize() async {
    await dotenv.load(fileName: '.env');
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || supabaseAnonKey == null) {
      throw Exception('SUPABASE_URL or SUPABASE_ANON_KEY not found in .env');
    }

    await supabase.Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );

    _client = supabase.Supabase.instance.client;
  }

  // User CRUD
  Future<User> createUser(User user) async {
    final response = await _client.from('users').insert(user.toJson()).select().single();
    return User.fromJson(response);
  }

  Future<User?> getUser(String id) async {
    final response = await _client.from('users').select().eq('id', id).maybeSingle();
    return response != null ? User.fromJson(response) : null;
  }

  Future<List<User>> getStudents() async {
    final response = await _client.from('users').select().eq('role', 'student');
    return (response as List).map((json) => User.fromJson(json)).toList();
  }

  Future<void> deleteUser(String id) async {
    await _client.from('users').delete().eq('id', id);
  }

  // Task CRUD
  Future<Task> createTask(Task task) async {
    final response = await _client.from('tasks').insert(task.toJson()).select().single();
    return Task.fromJson(response);
  }
  Future<List<Task>> getAllTasks() async {
    try {
      final response = await _client
          .from('tasks')
          .select()
          .order('created_at', ascending: true);
      return (response as List<dynamic>)
          .map((json) => Task.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch all tasks: $e');
    }
  }
  Future<void> deleteTask(String taskId) async {
    try {
      await _client
          .from('tasks')
          .delete()
          .eq('id', taskId);
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }
  Future<List<Task>> getTasksForUser(String userId) async {
    final response = await _client.from('tasks').select().eq('assigned_to', userId);
    return (response as List).map((json) => Task.fromJson(json)).toList();
  }

  Future<void> updateTaskStatus(String taskId, String status) async {
    await _client.from('tasks').update({'status': status}).eq('id', taskId);
  }

  // Report CRUD
  Future<Report?> getReport(String studentId) async {
    final response = await _client.from('reports').select().eq('student_id', studentId).maybeSingle();
    return response != null ? Report.fromJson(response) : null;
  }

  Future<void> updateReport(Report report) async {
    await _client.from('reports').upsert(report.toJson());
  }

  // Realtime Subscription
  Stream<List<Task>> subscribeToTasks(String userId) {
    return _client
        .from('tasks')
        .stream(primaryKey: ['id'])
        .eq('assigned_to', userId)
        .map((data) => data.map((json) => Task.fromJson(json)).toList());
  }

  // Storage: Upload Excel file
  Future<String> uploadExcelFile(String path, Uint8List bytes) async {
    try {
      final response = await _client.storage.from('excel_uploads').uploadBinary(path, bytes);
      return response;
    } catch (e) {
      throw Exception('Failed to upload Excel file: $e');
    }
  }
}