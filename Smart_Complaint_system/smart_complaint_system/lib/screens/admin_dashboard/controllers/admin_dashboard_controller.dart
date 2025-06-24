import 'package:flutter/material.dart';
import '../../../services/supabase_service.dart';
import '../models/admin_dashboard_state.dart';
import 'dart:io';

class AdminDashboardController extends ChangeNotifier {
  AdminDashboardState _state = AdminDashboardState.initial();
  AdminDashboardState get state => _state;

  // Getters for easy access to state properties
  bool get isLoading => _state.isLoading;
  String? get errorMessage => _state.errorMessage;
  int get totalUsers => _state.totalUsers;
  int get totalComplaints => _state.totalComplaints;
  int get resolvedComplaints => _state.resolvedComplaints;
  int get pendingComplaints =>
      complaints.where((c) => c['status'] == 'Submitted').length;
  double get resolutionRate => _state.resolutionRate;
  List<Map<String, dynamic>> get batches => _state.batches;
  List<Map<String, dynamic>> get advisors => _state.advisors;
  List<Map<String, dynamic>> get students => _state.students;
  List<Map<String, dynamic>> get complaints => _state.complaints;
  Map<String, dynamic>? get hodProfile => _state.hodProfile;
  Map<String, dynamic>? get adminProfile => _state.adminProfile;

  Future<void> loadData() async {
    _setLoading(true);
    _clearError();

    try {
      print('Admin Dashboard: Starting data load...');

      // Ensure database is properly initialized
      await SupabaseService.ensureDefaultBatches();

      // Load all data in parallel
      final results = await Future.wait([
        _loadBatches(),
        _loadAdvisors(),
        _loadStudents(),
        _loadComplaints(),
        _loadHodProfile(),
        _loadAdminProfile(),
        _loadCurrentDepartment(),
      ]);

      print('Admin Dashboard: Data loaded successfully');
      print('Batches: ${(results[0] as List<Map<String, dynamic>>).length}');
      print('Advisors: ${(results[1] as List<Map<String, dynamic>>).length}');
      print('Students: ${(results[2] as List<Map<String, dynamic>>).length}');
      print('Complaints: ${(results[3] as List<Map<String, dynamic>>).length}');
      print('HOD: ${results[4] != null ? 'Found' : 'Not found'}');
      print('Admin: ${results[5] != null ? 'Found' : 'Not found'}');
      print('Department: ${results[6] != null ? 'Found' : 'Not found'}');

      _state = _state.copyWith(
        batches: results[0] as List<Map<String, dynamic>>,
        advisors: results[1] as List<Map<String, dynamic>>,
        students: results[2] as List<Map<String, dynamic>>,
        complaints: results[3] as List<Map<String, dynamic>>,
        hodProfile: results[4] as Map<String, dynamic>?,
        adminProfile: results[5] as Map<String, dynamic>?,
        currentDepartment: results[6] as Map<String, dynamic>?,
      );

      _calculateStatistics();
      print('Admin Dashboard: Statistics calculated');
    } catch (e) {
      print('Admin Dashboard: Error loading data: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<List<Map<String, dynamic>>> _loadBatches() async {
    return await SupabaseService.getBatchesWithDetails();
  }

  Future<List<Map<String, dynamic>>> _loadAdvisors() async {
    return await SupabaseService.getBatchAdvisors();
  }

  Future<List<Map<String, dynamic>>> _loadStudents() async {
    return await SupabaseService.getAllStudents();
  }

  Future<List<Map<String, dynamic>>> _loadComplaints() async {
    // Load all complaints for admin view with related data
    return await SupabaseService.getAllComplaintsForAdmin();
  }

  Future<Map<String, dynamic>?> _loadHodProfile() async {
    return await SupabaseService.getHodProfile();
  }

  Future<Map<String, dynamic>?> _loadAdminProfile() async {
    return await SupabaseService.getAdminProfile();
  }

  Future<Map<String, dynamic>?> _loadCurrentDepartment() async {
    try {
      print('Controller: Loading current department...');
      final department = await SupabaseService.getCurrentDepartment();
      print('Controller: Loaded department: $department');
      return department;
    } catch (e) {
      print('Controller: Error loading department: $e');
      return null;
    }
  }

  void _calculateStatistics() {
    final totalUsers = students.length +
        advisors.length +
        (hodProfile != null ? 1 : 0) +
        (adminProfile != null ? 1 : 0);

    // Calculate complaint statistics
    final totalComplaints = complaints.length;
    final resolvedComplaints =
        complaints.where((c) => c['status'] == 'Resolved').length;
    final rejectedComplaints =
        complaints.where((c) => c['status'] == 'Rejected').length;
    final escalatedComplaints =
        complaints.where((c) => c['status'] == 'Escalated').length;
    final pendingComplaints = complaints
        .where((c) => c['status'] == 'Submitted' || c['status'] == 'Pending')
        .length;

    final resolutionRate = totalComplaints > 0
        ? (resolvedComplaints / totalComplaints) * 100
        : 0.0;

    _state = _state.copyWith(
      totalUsers: totalUsers,
      totalComplaints: totalComplaints,
      resolvedComplaints: resolvedComplaints,
      resolutionRate: resolutionRate,
    );

    print('Statistics calculated:');
    print('Total Users: $totalUsers');
    print('Total Complaints: $totalComplaints');
    print('Resolved: $resolvedComplaints');
    print('Rejected: $rejectedComplaints');
    print('Escalated: $escalatedComplaints');
    print('Pending: $pendingComplaints');
    print('Resolution Rate: ${resolutionRate.toStringAsFixed(1)}%');
  }

  Future<void> updateAdminProfile({
    required String name,
    required String email,
    File? image,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      print('Updating admin profile...');
      print('Name: $name');
      print('Email: $email');
      print('New image selected: ${image != null}');

      String? avatarUrl;
      if (image != null) {
        print('Uploading new profile picture...');
        avatarUrl = await SupabaseService.uploadProfilePicture(image.path);
        print('New avatar URL: $avatarUrl');
      } else {
        // Preserve existing avatar URL if no new image
        avatarUrl = _state.adminProfile?['avatar_url'] as String?;
        print('Preserving existing avatar URL: $avatarUrl');
      }

      await SupabaseService.updateAdminProfile(
        name: name,
        email: email,
        avatarUrl: avatarUrl,
      );

      print('Profile updated successfully, reloading data...');
      await loadData(); // Reload to reflect changes everywhere
      print('Data reloaded successfully');
    } catch (e) {
      print('Error updating admin profile: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Department Management Methods
  Future<Map<String, dynamic>?> getCurrentDepartment() async {
    try {
      print('Getting current department...');
      final result = await SupabaseService.getCurrentDepartment();
      print('Current department: $result');
      return result;
    } catch (e) {
      print('Error getting current department: $e');
      _setError(e.toString());
      return null;
    }
  }

  Future<void> updateDepartment({
    required String name,
    required String description,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      print('Controller: Updating department...');
      print('Name: $name');
      print('Description: $description');

      await SupabaseService.updateDepartment(
        name: name,
        description: description,
      );

      print('Controller: Department updated successfully');
      await loadData(); // Reload data
    } catch (e) {
      print('Controller: Error updating department: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Batch Management Methods
  Future<List<Map<String, dynamic>>> getAllBatches() async {
    try {
      print('Getting all batches...');
      final result = await SupabaseService.getAllBatchesForAdmin();
      print('Found ${result.length} batches');
      return result;
    } catch (e) {
      print('Error getting all batches: $e');
      _setError(e.toString());
      return [];
    }
  }

  Future<void> updateBatch({
    required String batchId,
    required String batchName,
    String? advisorId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      print('Controller: Updating batch...');
      print('Batch ID: $batchId, Name: $batchName, Advisor ID: $advisorId');
      await SupabaseService.updateBatch(
        batchId: batchId,
        batchName: batchName,
        advisorId: advisorId,
      );
      print('Controller: Batch updated successfully. Reloading data...');
      await loadData(); // Reload data to reflect changes
    } catch (e) {
      print('Controller: Error updating batch: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<List<Map<String, dynamic>>> getStudentsForBatch(String batchId) async {
    try {
      return await SupabaseService.getStudentsByBatch(batchId);
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  // HOD Management Methods
  Future<void> addOrUpdateHod({
    required String name,
    required String email,
    required String password,
    required bool isEdit,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await SupabaseService.addOrUpdateHod(
        name: name,
        email: email,
        password: password,
        isEdit: isEdit,
      );
      await loadData(); // Reload data
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Batch Advisor Management Methods
  Future<void> addBatchAdvisor({
    required String name,
    required String email,
    required String password,
    required String batchId,
  }) async {
    print('Controller: addBatchAdvisor called');
    _setLoading(true);
    _clearError();

    try {
      await SupabaseService.addBatchAdvisor(
        name: name,
        email: email,
        password: password,
        batchId: batchId,
      );
      await loadData();
    } catch (e) {
      print('Controller: Exception in addBatchAdvisor: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> editBatchAdvisor({
    required String userId,
    required String name,
    required String email,
    String? password,
    required String batchId,
    String? oldBatchId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await SupabaseService.editBatchAdvisor(
        userId: userId,
        name: name,
        email: email,
        password: password,
        batchId: batchId,
        oldBatchId: oldBatchId,
      );
      await loadData(); // Reload data
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteBatchAdvisor({
    required String userId,
    required String batchName,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await SupabaseService.deleteBatchAdvisor(
        userId: userId,
        batchName: batchName,
      );
      await loadData(); // Reload data
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Student Management Methods
  Future<void> addStudent({
    required String name,
    required String email,
    required String phone,
    required String batchName,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await SupabaseService.addStudent(
        name: name,
        email: email,
        phone: phone,
        batchName: batchName,
        password: password,
      );
      await loadData(); // Reload data
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> editStudent({
    required String userId,
    required String name,
    required String email,
    required String phone,
    required String batchName,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await SupabaseService.editStudent(
        userId: userId,
        name: name,
        email: email,
        phone: phone,
        batchName: batchName,
      );
      await loadData(); // Reload data
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteStudent(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      await SupabaseService.deleteStudent(userId);
      await loadData(); // Reload data
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _state = _state.copyWith(isLoading: loading);
    notifyListeners();
  }

  void _setError(String error) {
    _state = _state.copyWith(errorMessage: error);
    notifyListeners();
  }

  void _clearError() {
    _state = _state.copyWith(errorMessage: null);
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  // Logout functionality
  Future<void> logout() async {
    try {
      await SupabaseService.signOut();
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  Future<void> fetchCurrentDepartment() async {
    _setLoading(true);
    try {
      final department = await SupabaseService.getCurrentDepartment();
      _state = _state.copyWith(currentDepartment: department);
    } catch (e) {
      _setError('Failed to fetch department data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Student Management Methods
  Future<void> fetchStudents() async {
    _setLoading(true);
    // ... existing code ...
  }

  Future<void> deleteHod() async {
    if (state.hodProfile == null) {
      _setError('No HOD to delete.');
      return;
    }
    final hodId = state.hodProfile!['id'];

    _setLoading(true);
    _clearError();
    try {
      await SupabaseService.deleteHod(hodId);
      await loadData(); // Reload data to reflect changes
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
}
