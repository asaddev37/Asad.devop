import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user_profile.dart';
import '../models/complaint.dart';
import '../models/batch.dart';
import 'dart:io';

class SupabaseService {
  static String? getCurrentUserId() {
    return SupabaseConfig.client.auth.currentUser?.id;
  }

  static Future<bool> checkAdminExists() async {
    try {
      final response = await SupabaseConfig.client
          .from('profiles')
          .select('id')
          .eq('role', 'admin')
          .limit(1)
          .maybeSingle();
      return response != null;
    } catch (e) {
      return false;
    }
  }

  static Future<String> getStudentEmail(String studentId) async {
    final studentProfile = await SupabaseConfig.client
        .from('profiles')
        .select('email')
        .eq('student_id', studentId)
        .single();
    return studentProfile['email'] as String;
  }

  static Future<AuthResponse> signIn(String email, String password) async {
    return await SupabaseConfig.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<UserProfile> getUserProfile(String userId) async {
    final response = await SupabaseConfig.client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return UserProfile.fromJson(response);
  }

  static Future<void> updateComplaint({
    required String complaintId,
    required String status,
    String? comment,
    String? hodId,
  }) async {
    final updateMap = {
      'status': status,
      'updated_at': DateTime.now().toIso8601String(),
      'last_action_at': DateTime.now().toIso8601String(),
      if (hodId != null) 'hod_id': hodId,
    };
    await SupabaseConfig.client
        .from('complaints')
        .update(updateMap)
        .eq('id', complaintId);

    if (comment != null) {
      await SupabaseConfig.client.from('complaint_timeline').insert({
        'complaint_id': complaintId,
        'comment': comment,
        'status': status,
        'created_by': getCurrentUserId(),
      });
    }
  }

  static Future<String> addUser({
    required String name,
    required String email,
    required String password,
    required String role,
    String? batch,
    String? phone,
  }) async {
    try {
      final authResponse =
          await SupabaseConfig.adminClient.auth.admin.createUser(
        AdminUserAttributes(
          email: email,
          password: password,
          emailConfirm: true,
        ),
      );

      final deptResponse = await SupabaseConfig.client
          .from('departments')
          .select('id')
          .eq('name', 'CS')
          .maybeSingle();
      if (deptResponse == null) {
        throw Exception(
            'CS department not found. Please initialize departments.');
      }
      final deptId = deptResponse['id'];

      String? batchId;
      if (batch != null) {
        final batchResponse = await SupabaseConfig.client
            .from('batches')
            .select('id')
            .eq('batch_name', batch)
            .maybeSingle();
        if (batchResponse == null) {
          throw Exception('Batch $batch not found.');
        }
        batchId = batchResponse['id'];
      }

      final studentId = role == 'student' ? await _generateStudentId() : null;
      await SupabaseConfig.client.from('profiles').insert({
        'id': authResponse.user!.id,
        'email': email,
        'role': role,
        'name': name,
        'batch_id': batchId,
        'department_id': deptId,
        'phone_no': phone,
        'student_id': studentId,
        'advisor_id': null, // Adjust if advisor assignment is needed
      });

      if (role == 'batch_advisor' && batch != null) {
        await SupabaseConfig.client.from('batches').update({
          'advisor_id': authResponse.user!.id,
        }).eq('batch_name', batch);
      }

      return studentId ?? authResponse.user!.id;
    } catch (e) {
      // If profile creation failed after Auth signup, clean up Auth user
      await deleteAuthUser(email);
      // Show error to user
      throw Exception('Signup failed. Please try again. (${e.toString()})');
    }
  }

  static Future<String> _generateStudentId() async {
    final lastId = await SupabaseConfig.client
        .from('profiles')
        .select('student_id')
        .like('student_id', 'BCS%')
        .order('student_id', ascending: true)
        .limit(1)
        .maybeSingle();
    final nextId =
        lastId == null ? 1 : int.parse(lastId['student_id'].substring(4)) + 1;
    return 'BCS-${nextId.toString().padLeft(2, '0')}';
  }

  static Future<List<Complaint>> getComplaints(
      String role, String userId) async {
    var query = SupabaseConfig.client.from('complaints').select();
    if (role == 'student') {
      query = query.eq('student_id', userId);
    } else if (role == 'batch_advisor') {
      query = query.eq('advisor_id', userId);
    } else if (role == 'hod') {
      query = query.eq('hod_id', userId);
    }
    // For admin role, return all complaints (no filtering)
    final response = await query;
    return (response as List).map((json) => Complaint.fromJson(json)).toList();
  }

  static Future<void> submitComplaint({
    required String studentId,
    required String batchId,
    String? advisorId,
    required String title,
    required String description,
    String? mediaUrl,
    String status = 'Submitted',
    String? hodId,
  }) async {
    await SupabaseConfig.client.from('complaints').insert({
      'student_id': studentId,
      'batch_id': batchId,
      'advisor_id': advisorId,
      'title': title,
      'description': description,
      'media_url': mediaUrl,
      'status': status,
      'hod_id': hodId,
    });
  }

  static Future<List<Batch>> getBatches() async {
    final response = await SupabaseConfig.client.from('batches').select();
    return (response as List).map((json) => Batch.fromJson(json)).toList();
  }

  static Future<bool> isEmailRegistered(String email) async {
    final response = await SupabaseConfig.client
        .from('profiles')
        .select('id')
        .eq('email', email)
        .maybeSingle();
    return response != null;
  }

  static Future<void> deleteAuthUser(String email) async {
    final users = await SupabaseConfig.adminClient.auth.admin.listUsers();
    User? user;
    try {
      user = users.firstWhere((u) => u.email == email);
    } catch (e) {
      user = null;
    }
    if (user != null) {
      await SupabaseConfig.adminClient.auth.admin.deleteUser(user.id);
    }
  }

  /// Ensure CS department exists, create if it doesn't
  static Future<String> ensureCSDepartment() async {
    try {
      final dept = await SupabaseConfig.client
          .from('departments')
          .select('id')
          .eq('name', 'CS')
          .maybeSingle();

      if (dept != null) {
        return dept['id'].toString();
      }

      // Create CS department if it doesn't exist
      final response = await SupabaseConfig.client
          .from('departments')
          .insert({
            'name': 'CS',
            'description': 'Computer Science Department',
            'created_at': DateTime.now().toIso8601String(),
          })
          .select('id')
          .single();

      print('CS department created with ID: ${response['id']}');
      return response['id'].toString();
    } catch (e) {
      print('Error ensuring CS department: $e');
      throw Exception('Failed to ensure CS department exists: $e');
    }
  }

  /// Get the department id for CS
  static Future<String> getCSDeptId() async {
    return await ensureCSDepartment();
  }

  /// Get the current HOD profile for CS department
  static Future<Map<String, dynamic>?> getHodProfile() async {
    try {
      // First try to get by department
      try {
        final deptId = await getCSDeptId();
        final response = await SupabaseConfig.client
            .from('profiles')
            .select()
            .eq('role', 'hod')
            .eq('department_id', deptId)
            .maybeSingle();
        return response;
      } catch (e) {
        // If department filtering fails, get any HOD
        final response = await SupabaseConfig.client
            .from('profiles')
            .select()
            .eq('role', 'hod')
            .maybeSingle();
        return response;
      }
    } catch (e) {
      print('Error fetching HOD profile: $e');
      return null;
    }
  }

  /// Add or update HOD (only one allowed per department)
  static Future<String> addOrUpdateHod({
    required String name,
    required String email,
    required String password,
    required bool isEdit,
  }) async {
    final deptId = await getCSDeptId();
    if (isEdit) {
      // Find the HOD user
      final hod = await getHodProfile();
      if (hod == null) throw Exception('No HOD found to update.');
      // Optionally update password if provided
      if (password.isNotEmpty) {
        await SupabaseConfig.adminClient.auth.admin.updateUserById(
          hod['id'],
          attributes: AdminUserAttributes(password: password),
        );
      }
      // Update profile
      await SupabaseConfig.client
          .from('profiles')
          .update({'name': name, 'email': email, 'department_id': deptId}).eq(
              'id', hod['id']);
      return hod['id'];
    } else {
      // Check if HOD already exists
      final hod = await getHodProfile();
      if (hod != null)
        throw Exception('Only one HOD allowed for CS department.');
      // Create HOD user in Auth
      final authResponse =
          await SupabaseConfig.adminClient.auth.admin.createUser(
        AdminUserAttributes(
          email: email,
          password: password,
          emailConfirm: true,
        ),
      );
      final userId = authResponse.user?.id;
      if (userId == null) throw Exception('Failed to create HOD user.');
      // Insert profile
      await SupabaseConfig.client.from('profiles').insert({
        'id': userId,
        'name': name,
        'email': email,
        'role': 'hod',
        'department_id': deptId,
        'created_at': DateTime.now().toIso8601String(),
      });
      return userId;
    }
  }

  /// Delete the HOD (by user id)
  static Future<void> deleteHod(String hodId) async {
    try {
      // Use admin client to delete the user from auth schema.
      // This will cascade and delete the profile if foreign keys are set up correctly.
      await SupabaseConfig.adminClient.auth.admin.deleteUser(hodId);
      print('HOD with id $hodId deleted successfully from auth.');
    } catch (e) {
      print('Failed to delete HOD from auth: $e');
      throw Exception('Failed to delete HOD.');
    }
  }

  /// Get all batches with their assigned advisor (if any)
  static Future<List<Map<String, dynamic>>> getBatchesWithAdvisors() async {
    try {
      final response = await SupabaseConfig.client
          .from('batches')
          .select(
              'id, batch_name, advisor_id, advisor:advisor_id (id, name, email)')
          .order('batch_name');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching batches with advisors: $e');
      return [];
    }
  }

  /// Get all batch advisors (profiles with role 'batch_advisor')
  static Future<List<Map<String, dynamic>>> getBatchAdvisors() async {
    try {
      // First try to get by department, if that fails, get all batch advisors
      try {
        final deptId = await getCSDeptId();
        final response = await SupabaseConfig.client
            .from('profiles')
            .select()
            .eq('role', 'batch_advisor')
            .eq('department_id', deptId)
            .order('name');
        return List<Map<String, dynamic>>.from(response);
      } catch (e) {
        // If department filtering fails, get all batch advisors
        final response = await SupabaseConfig.client
            .from('profiles')
            .select()
            .eq('role', 'batch_advisor')
            .order('name');
        return List<Map<String, dynamic>>.from(response);
      }
    } catch (e) {
      print('Error fetching batch advisors: $e');
      return [];
    }
  }

  /// Add a new batch advisor (enforce one per batch)
  static Future<String> addBatchAdvisor({
    required String name,
    required String email,
    required String password,
    required String batchId,
  }) async {
    String? userId;
    try {
      // Get batch details first to validate
      final batch = await SupabaseConfig.client
          .from('batches')
          .select('id, advisor_id, department_id')
          .eq('id', batchId)
          .maybeSingle();

      if (batch == null) throw Exception('Batch not found.');
      if (batch['advisor_id'] != null) {
        throw Exception('This batch already has an assigned advisor.');
      }

      // Get department ID using the batch's department_id (not by name)
      final deptId = batch['department_id'];
      if (deptId == null) throw Exception('Batch missing department_id.');

      // Create advisor user in Auth
      final authResponse =
          await SupabaseConfig.adminClient.auth.admin.createUser(
        AdminUserAttributes(
          email: email,
          password: password,
          emailConfirm: true,
        ),
      );
      userId = authResponse.user?.id;
      if (userId == null) {
        throw Exception('Failed to create batch advisor user.');
      }

      // Insert the profile and log the result
      final insertResult = await SupabaseConfig.client.from('profiles').insert({
        'id': userId,
        'name': name,
        'email': email,
        'role': 'batch_advisor',
        'department_id': deptId,
        'batch_id': batch['id'],
        'created_at': DateTime.now().toIso8601String(),
      }).select();
      print('Insert result for advisor profile: $insertResult');
      if (insertResult == null ||
          (insertResult is List && insertResult.isEmpty)) {
        throw Exception('Failed to insert advisor profile.');
      }
      if (insertResult is Map) {
        final mapResult = insertResult as Map<String, dynamic>;
        if (mapResult['error'] != null) {
          throw Exception('Insert error: ${mapResult['error'].toString()}');
        }
      }

      // First update the batch with advisor_id
      await SupabaseConfig.client
          .from('batches')
          .update({'advisor_id': userId}).eq('id', batch['id']);

      return userId;
    } catch (e) {
      print('Exception in addBatchAdvisor: $e');
      if (userId != null) {
        try {
          await SupabaseConfig.adminClient.auth.admin.deleteUser(userId);
          await SupabaseConfig.client
              .from('profiles')
              .delete()
              .eq('id', userId);
        } catch (_) {}
      }
      throw Exception('Failed to create batch advisor: ${e.toString()}');
    }
  }

  /// Edit batch advisor (update profile, reassign batch)
  static Future<void> editBatchAdvisor({
    required String userId,
    required String name,
    required String email,
    String? password,
    required String batchId,
    String? oldBatchId,
  }) async {
    // Get batch details
    final batch = await SupabaseConfig.client
        .from('batches')
        .select('id')
        .eq('id', batchId)
        .maybeSingle();
    if (batch == null) throw Exception('Batch not found.');

    // Get old batch details if needed
    String? oldBatchIdResolved;
    if (oldBatchId != null && oldBatchId != batchId) {
      final oldBatch = await SupabaseConfig.client
          .from('batches')
          .select('id')
          .eq('id', oldBatchId)
          .maybeSingle();
      if (oldBatch != null) {
        oldBatchIdResolved = oldBatch['id'];
      }
    }

    // Optionally update password
    if (password != null && password.isNotEmpty) {
      await SupabaseConfig.adminClient.auth.admin.updateUserById(
        userId,
        attributes: AdminUserAttributes(password: password),
      );
    }

    // Update profile with new batch_id
    await SupabaseConfig.client.from('profiles').update({
      'name': name,
      'email': email,
      'batch_id': batch['id'],
    }).eq('id', userId);

    // Unassign from old batch if changed
    if (oldBatchIdResolved != null) {
      await SupabaseConfig.client
          .from('batches')
          .update({'advisor_id': null}).eq('id', oldBatchIdResolved);
    }

    // Assign to new batch
    await SupabaseConfig.client
        .from('batches')
        .update({'advisor_id': userId}).eq('id', batch['id']);
  }

  /// Delete batch advisor (remove user/profile, unassign batch)
  static Future<void> deleteBatchAdvisor({
    required String userId,
    required String batchName,
  }) async {
    // Get batch details
    final batch = await SupabaseConfig.client
        .from('batches')
        .select('id')
        .eq('batch_name', batchName)
        .maybeSingle();

    if (batch != null) {
      // Unassign from batch
      await SupabaseConfig.client
          .from('batches')
          .update({'advisor_id': null}).eq('id', batch['id']);
    }

    // Delete from Auth
    await SupabaseConfig.adminClient.auth.admin.deleteUser(userId);

    // Delete from profiles
    await SupabaseConfig.client.from('profiles').delete().eq('id', userId);
  }

  /// Get all students (alternative method without department filtering)
  static Future<List<Map<String, dynamic>>> getAllStudents() async {
    try {
      print('Fetching all students (alternative method)...');

      // First try to get students with batch info
      try {
        final response = await SupabaseConfig.client
            .from('profiles')
            .select(
                'id, name, email, phone_no, student_id, batch:batches!profiles_batch_id_fkey(batch_name)')
            .eq('role', 'student')
            .order('name');

        print('Students with batch info: ${response.length}');
        return response.map<Map<String, dynamic>>((student) {
          return {
            'id': student['id'],
            'name': student['name'],
            'email': student['email'],
            'phone_no': student['phone_no'],
            'student_id': student['student_id'],
            'batch_no': student['batch']?['batch_name'] ?? 'Not Assigned',
          };
        }).toList();
      } catch (e) {
        print('Error with batch join, trying without: $e');

        // Fallback: get students without batch info
        final response = await SupabaseConfig.client
            .from('profiles')
            .select('id, name, email, phone_no, student_id')
            .eq('role', 'student')
            .order('name');

        print('Students without batch info: ${response.length}');
        return response.map<Map<String, dynamic>>((student) {
          return {
            'id': student['id'],
            'name': student['name'],
            'email': student['email'],
            'phone_no': student['phone_no'],
            'student_id': student['student_id'],
            'batch_no': 'Not Assigned',
          };
        }).toList();
      }
    } catch (e) {
      print('Error fetching all students: $e');
      return [];
    }
  }

  /// Get all students (with batch info)
  static Future<List<Map<String, dynamic>>> getStudents() async {
    try {
      print('Fetching students...');
      final response = await SupabaseConfig.client
          .from('profiles')
          .select(
              'id, name, email, phone_no, student_id, batch:batches!profiles_batch_id_fkey(batch_name)')
          .eq('role', 'student')
          .order('name');

      print('Raw student response: $response');

      final students = response.map<Map<String, dynamic>>((student) {
        return {
          'id': student['id'],
          'name': student['name'],
          'email': student['email'],
          'phone_no': student['phone_no'],
          'student_id': student['student_id'],
          'batch_no': student['batch']?['batch_name'] ?? 'Not Assigned',
        };
      }).toList();

      print('Processed students: ${students.length}');
      return students;
    } catch (e) {
      print('Error fetching students: $e');
      return [];
    }
  }

  /// Generate the next student ID (e.g., BCS-01, BCS-02, ...)
  static Future<String> generateStudentId() async {
    final deptId = await getCSDeptId();
    final last = await SupabaseConfig.client
        .from('profiles')
        .select('student_id')
        .eq('role', 'student')
        .eq('department_id', deptId)
        .order('student_id', ascending: false)
        .limit(1)
        .maybeSingle();
    int next = 1;
    if (last != null && last['student_id'] != null) {
      final match = RegExp(r'BCS-(\d+)').firstMatch(last['student_id']);
      if (match != null) {
        next = int.parse(match.group(1)!) + 1;
      }
    }
    return 'BCS-${next.toString().padLeft(2, '0')}';
  }

  /// Add a new student (auto-generate ID, assign batch)
  static Future<String> addStudent({
    required String name,
    required String email,
    required String phone,
    required String batchName,
    required String password,
  }) async {
    try {
      // Create auth user first
      final authResponse =
          await SupabaseConfig.adminClient.auth.admin.createUser(
        AdminUserAttributes(
          email: email,
          password: password,
          emailConfirm: true,
          data: {
            'role': 'student',
            'name': name,
          },
        ),
      );

      if (authResponse.user == null) {
        throw Exception('Failed to create auth user');
      }

      // Get batch ID
      final batchResponse = await SupabaseConfig.client
          .from('batches')
          .select('id')
          .eq('batch_name', batchName)
          .single();

      // Create student profile
      final response = await SupabaseConfig.client.from('profiles').insert({
        'id': authResponse.user!.id,
        'name': name,
        'email': email,
        'phone_no': phone,
        'batch_id': batchResponse['id'],
        'role': 'student',
      }).select();

      // Generate and return student ID
      final studentId = 'STD-${response[0]['id'].toString().substring(0, 8)}';
      await SupabaseConfig.client
          .from('profiles')
          .update({'student_id': studentId}).eq('id', authResponse.user!.id);

      return studentId;
    } catch (e) {
      throw Exception('Failed to add student: $e');
    }
  }

  /// Edit student (update profile, batch)
  static Future<void> editStudent({
    required String userId,
    required String name,
    required String email,
    required String phone,
    required String batchName,
  }) async {
    // Get batch id
    final batch = await SupabaseConfig.client
        .from('batches')
        .select('id')
        .eq('batch_name', batchName)
        .maybeSingle();
    if (batch == null) throw Exception('Batch not found.');
    final batchId = batch['id'];
    // Update profile
    await SupabaseConfig.client.from('profiles').update({
      'name': name,
      'email': email,
      'phone_no': phone,
      'batch_id': batchId,
    }).eq('id', userId);
  }

  /// Delete student (remove user/profile)
  static Future<void> deleteStudent(String userId) async {
    // Delete from Auth
    await SupabaseConfig.adminClient.auth.admin.deleteUser(userId);
    // Delete from profiles
    await SupabaseConfig.client.from('profiles').delete().eq('id', userId);
  }

  /// Get all batches (for dropdowns)
  static Future<List<Map<String, dynamic>>> getAllBatches() async {
    final response = await SupabaseConfig.client
        .from('batches')
        .select('id, batch_name')
        .order('batch_name');
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> signOut() async {
    try {
      await SupabaseConfig.client.auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // Batch Advisor Methods
  static Future<Map<String, dynamic>> getBatchAdvisorProfile() async {
    try {
      final user = SupabaseConfig.client.auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      final response = await SupabaseConfig.client
          .from('profiles')
          .select(
              '*, batch:batches!profiles_batch_id_fkey(*, advisor:advisor_id(*), department:department_id(hod:hod_id(*)))')
          .eq('id', user.id)
          .single();

      return response;
    } catch (e) {
      throw Exception('Failed to get batch advisor profile: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getBatchComplaints(
      String batchId) async {
    try {
      final response = await SupabaseConfig.client
          .from('complaints')
          .select('*, student:profiles!complaints_student_id_fkey(*)')
          .eq('batch_id', batchId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get batch complaints: $e');
    }
  }

  static Future<void> updateComplaintStatus(
      String complaintId, String status) async {
    try {
      await SupabaseConfig.client
          .from('complaints')
          .update({'status': status}).eq('id', complaintId);
    } catch (e) {
      throw Exception('Failed to update complaint status: $e');
    }
  }

  // Student Methods
  static Future<Map<String, dynamic>> getStudentProfile() async {
    try {
      final user = SupabaseConfig.client.auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Fetch profile with batch, advisor, and department name
      final response = await SupabaseConfig.client
          .from('profiles')
          .select(
              '*, batch:batches!profiles_batch_id_fkey(*, advisor:advisor_id(*), department:department_id(id, name))')
          .eq('id', user.id)
          .single();

      return response;
    } catch (e) {
      throw Exception('Failed to get student profile: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getStudentComplaints() async {
    try {
      final user = SupabaseConfig.client.auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      final response = await SupabaseConfig.client
          .from('complaints')
          .select('*')
          .eq('student_id', user.id)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get student complaints: $e');
    }
  }

  // Helper method to create default batches
  static Future<void> _createDefaultBatches() async {
    try {
      // Get CS department ID
      final deptId = await getCSDeptId();

      // Create default batches
      final defaultBatches = [
        {'batch_name': 'FA22-BSE-037', 'department_id': deptId},
        {'batch_name': 'FA22-BSE-038', 'department_id': deptId},
        {'batch_name': 'FA22-BSE-039', 'department_id': deptId},
        {'batch_name': 'FA22-BSE-040', 'department_id': deptId},
      ];

      for (final batch in defaultBatches) {
        await SupabaseConfig.client.from('batches').insert(batch);
      }

      print('Default batches created successfully');
    } catch (e) {
      print('Error creating default batches: $e');
    }
  }

  static Future<void> _fixStudentBatchAssignment(String userId) async {
    try {
      // Get the first available batch
      final batches = await SupabaseConfig.client
          .from('batches')
          .select('id, batch_name')
          .limit(1);

      if (batches.isNotEmpty) {
        final batchId = batches.first['id'];
        print('Assigning student to batch: ${batches.first['batch_name']}');

        // Update the student's batch_id
        await SupabaseConfig.client
            .from('profiles')
            .update({'batch_id': batchId}).eq('id', userId);

        print('Student batch assignment fixed');
      }
    } catch (e) {
      print('Error fixing student batch assignment: $e');
    }
  }

  // HOD Methods
  static Future<Map<String, dynamic>> getHODProfile() async {
    try {
      final user = SupabaseConfig.client.auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      final response = await SupabaseConfig.client
          .from('profiles')
          .select('*')
          .eq('id', user.id)
          .single();

      return response;
    } catch (e) {
      throw Exception('Failed to get HOD profile: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getHODComplaints() async {
    try {
      final user = SupabaseConfig.client.auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Get all complaints assigned to this HOD
      final response = await SupabaseConfig.client
          .from('complaints')
          .select(
              '*, student:profiles!complaints_student_id_fkey(*), batch:batches(*)')
          .eq('hod_id', user.id)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get HOD complaints: $e');
    }
  }

  /// Fetch the timeline (status/comments/handler) for a given complaint
  static Future<List<Map<String, dynamic>>> getComplaintTimeline(
      String complaintId) async {
    try {
      final response = await SupabaseConfig.client
          .from('complaint_timeline')
          .select(
              '*, created_by:profiles!complaint_timeline_created_by_fkey(name, role)')
          .eq('complaint_id', complaintId)
          .order('created_at', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch complaint timeline: $e');
    }
  }

  /// Count complaints by title in a batch (for escalation logic)
  static Future<int> countComplaintsByTitleInBatch({
    required String batchId,
    required String title,
  }) async {
    final response = await SupabaseConfig.client
        .from('complaints')
        .select('id')
        .eq('batch_id', batchId)
        .eq('title', title);
    return response.length;
  }

  /// Get all students in a batch (for advisor dashboard filter)
  static Future<List<Map<String, dynamic>>> getStudentsInBatch(
      String batchId) async {
    final response = await SupabaseConfig.client
        .from('profiles')
        .select('id, name, email')
        .eq('role', 'student')
        .eq('batch_id', batchId);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Get batch complaints with optional filters: status, studentId, dateFrom, dateTo
  static Future<List<Map<String, dynamic>>> getBatchComplaintsFiltered({
    required String batchId,
    String? status,
    String? studentId,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    var query = SupabaseConfig.client
        .from('complaints')
        .select(
            '*, batch:batches(*, department:department_id(*)), student:profiles!complaints_student_id_fkey(*)')
        .eq('batch_id', batchId);
    if (status != null && status != 'all') {
      query = query.eq('status', status);
    }
    if (studentId != null && studentId.isNotEmpty) {
      query = query.eq('student_id', studentId);
    }
    if (dateFrom != null) {
      query = query.gte('created_at', dateFrom.toIso8601String());
    }
    if (dateTo != null) {
      query = query.lte('created_at', dateTo.toIso8601String());
    }
    final response = await query.order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Get all complaints for admin view (with related data)
  static Future<List<Map<String, dynamic>>> getAllComplaintsForAdmin() async {
    final response = await SupabaseConfig.client.from('complaints').select('''
          *,
          student:profiles!complaints_student_id_fkey(id, name, email, student_id),
          batch:batches!complaints_batch_id_fkey(batch_name),
          advisor:profiles!complaints_advisor_id_fkey(id, name, email),
          hod:profiles!complaints_hod_id_fkey(id, name, email)
        ''').order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Get all batches with their assigned advisor and student count
  static Future<List<Map<String, dynamic>>> getBatchesWithDetails() async {
    try {
      // First get all batches with advisor info
      final response = await SupabaseConfig.client.from('batches').select('''
            id, 
            batch_name, 
            advisor_id, 
            advisor:advisor_id (id, name, email)
          ''').order('batch_name');

      // Then get student count for each batch
      final batchesWithCounts = <Map<String, dynamic>>[];

      for (final batch in response) {
        final studentCountResponse = await SupabaseConfig.client
            .from('profiles')
            .select('id')
            .eq('role', 'student')
            .eq('batch_id', batch['id']);

        final studentCount = studentCountResponse.length;

        batchesWithCounts.add({
          ...batch,
          'students': [
            {'count': studentCount}
          ],
        });
      }

      return batchesWithCounts;
    } catch (e) {
      print('Error fetching batches with details: $e');
      return [];
    }
  }

  /// Ensure default batches exist, create if they don't
  static Future<void> ensureDefaultBatches() async {
    try {
      final deptId = await getCSDeptId();

      // Check if batches already exist
      final existingBatches = await SupabaseConfig.client
          .from('batches')
          .select('batch_name')
          .eq('department_id', deptId);

      if (existingBatches.isNotEmpty) {
        print('Batches already exist: ${existingBatches.length} found');
        return;
      }

      // Create default batches
      final defaultBatches = [
        {'batch_name': 'FA22-BSE-037', 'department_id': deptId},
        {'batch_name': 'FA22-BSE-038', 'department_id': deptId},
        {'batch_name': 'FA22-BSE-039', 'department_id': deptId},
        {'batch_name': 'FA22-BSE-040', 'department_id': deptId},
      ];

      for (final batch in defaultBatches) {
        await SupabaseConfig.client.from('batches').insert(batch);
      }

      print('Default batches created successfully');
    } catch (e) {
      print('Error creating default batches: $e');
    }
  }

  static Future<Map<String, dynamic>?> getAdminProfile() async {
    final userId = getCurrentUserId();
    if (userId == null) return null;
    try {
      final response = await SupabaseConfig.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .eq('role', 'admin')
          .single();
      return response;
    } catch (e) {
      return null;
    }
  }

  static Future<void> updateAdminProfile({
    required String name,
    required String email,
    String? avatarUrl,
  }) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not logged in.');

    final updates = {
      'name': name,
      'email': email,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    };

    await SupabaseConfig.client
        .from('profiles')
        .update(updates)
        .eq('id', userId);

    print('Profile updated successfully.');
  }

  static Future<String> uploadProfilePicture(String filePath) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not logged in.');

    try {
      // First, let's see what buckets are available
      await _listStorageBuckets();

      // Try common bucket names
      final bucketNames = ['avatars', 'media', 'files', 'uploads'];
      String? uploadedUrl;
      String? lastError;

      for (final bucketName in bucketNames) {
        try {
          print('Trying bucket: $bucketName');

          final fileName =
              'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final storagePath = 'avatars/$userId/$fileName';

          print('Uploading profile picture:');
          print('  File path: $filePath');
          print('  Storage path: $storagePath');
          print('  Bucket: $bucketName');

          // Upload the file
          final response = await SupabaseConfig.client.storage
              .from(bucketName)
              .upload(storagePath, File(filePath));

          print('Upload response: $response');

          // Get the public URL
          uploadedUrl = SupabaseConfig.client.storage
              .from(bucketName)
              .getPublicUrl(storagePath);

          print('Public URL: $uploadedUrl');
          break; // Success, exit the loop
        } catch (e) {
          lastError = e.toString();
          print('Failed with bucket $bucketName: $e');
          continue; // Try next bucket
        }
      }

      if (uploadedUrl == null) {
        throw Exception(
            'Failed to upload to any bucket. Last error: $lastError');
      }

      return uploadedUrl;
    } catch (e) {
      print('Error uploading profile picture: $e');
      throw Exception('Failed to upload profile picture: $e');
    }
  }

  static Future<void> _listStorageBuckets() async {
    try {
      final buckets = await SupabaseConfig.client.storage.listBuckets();
      print('Available storage buckets:');
      for (final bucket in buckets) {
        print('  - ${bucket.name}');
      }
    } catch (e) {
      print('Error listing storage buckets: $e');
    }
  }

  // Department Management Methods
  static Future<Map<String, dynamic>?> getCurrentDepartment() async {
    try {
      print('Service: Getting current department...');
      final response = await SupabaseConfig.client
          .from('departments')
          .select()
          .limit(1)
          .maybeSingle();
      print('Service: Department response: $response');
      return response;
    } catch (e) {
      print('Service: Error getting current department: $e');
      return null;
    }
  }

  static Future<void> updateDepartment({
    required String name,
    required String description,
  }) async {
    try {
      print('Service: Updating department...');
      print('Service: Name: $name');
      print('Service: Description: $description');
      // First check if department exists
      final existingDept = await getCurrentDepartment();
      if (existingDept != null) {
        print(
            'Service: Updating existing department with ID: ${existingDept['id']}');
        // Update existing department and return the updated row
        final response = await SupabaseConfig.client
            .from('departments')
            .update({
              'name': name,
              'description': description,
            })
            .eq('id', existingDept['id'])
            .select(); // <-- This will return the updated row
        print('Update response: $response');
        if (response == null || response.isEmpty) {
          throw Exception('No department updated');
        }
      } else {
        print('Service: Creating new department');
        final response =
            await SupabaseConfig.client.from('departments').insert({
          'name': name,
          'description': description,
        }).select();
        print('Insert response: $response');
        if (response == null || response.isEmpty) {
          throw Exception('Department not created');
        }
      }
      print('Service: Department updated/created successfully');
    } catch (e) {
      print('Service: Error updating department: $e');
      throw Exception('Failed to update department: $e');
    }
  }

  // Batch Management Methods
  static Future<List<Map<String, dynamic>>> getAllBatchesForAdmin() async {
    try {
      print('Service: Getting all batches...');
      final response = await SupabaseConfig.client
          .from('batches')
          .select('*')
          .order('batch_name');
      print('Service: Found ${response.length} batches');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Service: Error getting all batches: $e');
      throw Exception('Failed to get batches: $e');
    }
  }

  static Future<void> updateBatch({
    required String batchId,
    required String batchName,
    String? advisorId,
  }) async {
    try {
      final updateData = {
        'batch_name': batchName,
        if (advisorId != null) 'advisor_id': advisorId,
      };

      if (updateData.isNotEmpty) {
        await SupabaseConfig.client
            .from('batches')
            .update(updateData)
            .eq('id', batchId);
      }
    } catch (e) {
      print('Error updating batch in Supabase: $e');
      throw Exception('Failed to update batch: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getStudentsByBatch(
      String batchId) async {
    final response = await SupabaseConfig.client
        .from('profiles')
        .select()
        .eq('batch_id', batchId)
        .eq('role', 'student');
    return (response as List).cast<Map<String, dynamic>>();
  }

  /// Deletes a user profile from the 'profiles' table.
  static Future<void> deleteProfile(String userId) async {
    try {
      // Delete from Auth
      await SupabaseConfig.adminClient.auth.admin.deleteUser(userId);
      // Delete from profiles
      await SupabaseConfig.client.from('profiles').delete().eq('id', userId);
    } catch (e) {
      print('Error deleting profile: $e');
      throw Exception('Failed to delete profile: $e');
    }
  }

  // --- Notification Methods ---
  static Future<List<Map<String, dynamic>>> getStudentNotifications() async {
    final user = SupabaseConfig.client.auth.currentUser;
    if (user == null) throw Exception('No user logged in');
    final response = await SupabaseConfig.client
        .from('notifications')
        .select('*')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> markNotificationAsRead(String notificationId) async {
    await SupabaseConfig.client
        .from('notifications')
        .update({'is_read': true}).eq('id', notificationId);
  }

  static Future<Map<String, dynamic>> getDepartmentById(
      String departmentId) async {
    final response = await SupabaseConfig.client
        .from('departments')
        .select('*')
        .eq('id', departmentId)
        .maybeSingle();
    if (response == null) throw Exception('Department not found');
    return response;
  }

  static Future<void> updateAdvisorProfile({
    required String userId,
    required String name,
    required String email,
    String? avatarUrl,
  }) async {
    final updateMap = {'name': name, 'email': email};
    if (avatarUrl != null) updateMap['avatar_url'] = avatarUrl;
    await SupabaseConfig.client
        .from('profiles')
        .update(updateMap)
        .eq('id', userId);
  }

  static Future<void> updateStudentProfile({
    required String userId,
    required String name,
    required String email,
    String? avatarUrl,
  }) async {
    final updateMap = {'name': name, 'email': email};
    if (avatarUrl != null) updateMap['avatar_url'] = avatarUrl;
    await SupabaseConfig.client
        .from('profiles')
        .update(updateMap)
        .eq('id', userId);
  }

  // --- HOD Profile Update ---
  static Future<void> updateHODProfile({
    required String? userId,
    required String name,
    required String email,
    String? avatarUrl,
  }) async {
    if (userId == null) throw Exception('User ID is required');
    final updates = {
      'name': name,
      'email': email,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    };
    await SupabaseConfig.client
        .from('profiles')
        .update(updates)
        .eq('id', userId);
  }

  // --- HOD Notifications ---
  static Future<List<Map<String, dynamic>>> getHODNotifications() async {
    final userId = getCurrentUserId();
    if (userId == null) return [];
    final response = await SupabaseConfig.client
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Get all batches that do not have an assigned advisor (for dropdown)
  static Future<List<Map<String, dynamic>>> getUnassignedBatches() async {
    final response = await SupabaseConfig.client
        .from('batches')
        .select('id, batch_name')
        .filter('advisor_id', 'is', null)
        .order('batch_name');
    return List<Map<String, dynamic>>.from(response);
  }
}
