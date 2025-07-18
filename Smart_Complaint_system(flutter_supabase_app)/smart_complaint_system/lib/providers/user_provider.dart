import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/supabase_service.dart';

class UserProvider with ChangeNotifier {
  UserProfile? _user;

  UserProfile? get user => _user;

  Future<void> loadUser(String userId) async {
    _user = await SupabaseService.getUserProfile(userId);
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}