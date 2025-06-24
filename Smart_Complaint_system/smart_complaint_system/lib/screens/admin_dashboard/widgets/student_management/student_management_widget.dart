import 'package:flutter/material.dart';
import '../../../../services/email_service.dart';
import '../../controllers/admin_dashboard_controller.dart';
import 'student_form.dart';
import 'student_list.dart';

class StudentManagementWidget extends StatefulWidget {
  final AdminDashboardController controller;

  const StudentManagementWidget({
    super.key,
    required this.controller,
  });

  @override
  State<StudentManagementWidget> createState() =>
      _StudentManagementWidgetState();
}

class _StudentManagementWidgetState extends State<StudentManagementWidget> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedBatch;
  String? _editingStudentId;
  bool _isEditing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _addOrEditStudent() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final batch = _selectedBatch;

    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        (!_isEditing && password.isEmpty) ||
        batch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      if (_isEditing) {
        await widget.controller.editStudent(
          userId: _editingStudentId!,
          name: name,
          email: email,
          phone: phone,
          batchName: batch,
        );
      } else {
        await widget.controller.addStudent(
          name: name,
          email: email,
          phone: phone,
          batchName: batch,
          password: password,
        );
      }

      // Send email notification
      await EmailService.sendCredentials(
        context: context,
        toEmail: email,
        name: name,
        role: 'Student',
        username: email,
        password: password,
        batch: batch,
        isDarkMode: Theme.of(context).brightness == Brightness.dark,
        isUpdate: _isEditing,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing
                ? 'Student updated successfully!'
                : 'Student added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      _clearForm();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteStudent(String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text(
            'Are you sure you want to delete this student? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await widget.controller.deleteStudent(userId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Student deleted successfully!'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _passwordController.clear();
    setState(() {
      _selectedBatch = null;
      _editingStudentId = null;
      _isEditing = false;
    });
  }

  void _editStudent(Map<String, dynamic> student) {
    _nameController.text = student['name'] ?? '';
    _emailController.text = student['email'] ?? '';
    _phoneController.text = student['phone_no'] ?? '';
    _passwordController.clear();

    setState(() {
      _selectedBatch = student['batch_no'];
      _editingStudentId = student['id'];
      _isEditing = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header

        // Add/Edit Form
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: StudentForm(
            nameController: _nameController,
            emailController: _emailController,
            phoneController: _phoneController,
            passwordController: _passwordController,
            selectedBatch: _selectedBatch,
            batches: widget.controller.batches,
            isEditing: _isEditing,
            isLoading: widget.controller.isLoading,
            onBatchChanged: (batch) => setState(() => _selectedBatch = batch),
            onSubmit: _addOrEditStudent,
            onCancel: _clearForm,
          ),
        ),

        const SizedBox(height: 24),

        // Students List
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: StudentList(
            students: widget.controller.students,
            isLoading: widget.controller.isLoading,
            onEdit: _editStudent,
            onDelete: _deleteStudent,
          ),
        ),
      ],
    );
  }
}
