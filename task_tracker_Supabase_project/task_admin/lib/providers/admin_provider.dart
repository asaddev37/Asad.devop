import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:task_tracker_shared/task_tracker_shared.dart';

class AdminProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  User? _adminUser;
  String _status = 'Idle';

  User? get adminUser => _adminUser;
  String get status => _status;

  Future<void> login({required String email, required String password}) async {
    try {
      _status = 'Logging in...';
      notifyListeners();

      // Authenticate with Supabase
      final response = await supabase.Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final userId = response.user?.id;
      if (userId == null) {
        throw Exception('Failed to retrieve user ID');
      }

      // Fetch user data from users table
      final user = await _supabaseService.getUser(userId);
      if (user == null || user.role != 'admin') {
        await supabase.Supabase.instance.client.auth.signOut();
        throw Exception('User is not an admin');
      }

      _adminUser = user;
      _status = 'Logged in';
      notifyListeners();
    } catch (e) {
      _status = 'Error: $e';
      notifyListeners();
      rethrow; // Rethrow to allow UI to handle the error
    }
  }

  Future<void> logout() async {
    try {
      await supabase.Supabase.instance.client.auth.signOut();
      _adminUser = null;
      _status = 'Logged out';
      notifyListeners();
    } catch (e) {
      _status = 'Error: $e';
      notifyListeners();
    }
  }
}