import 'package:flutter/material.dart';
import '../../../../services/email_service.dart';
import '../../controllers/admin_dashboard_controller.dart';
import 'advisor_form.dart';
import 'advisor_list.dart';
import '../../../../services/supabase_service.dart';

class BatchAdvisorWidget extends StatefulWidget {
  final AdminDashboardController controller;

  const BatchAdvisorWidget({
    super.key,
    required this.controller,
  });

  @override
  State<BatchAdvisorWidget> createState() => _BatchAdvisorWidgetState();
}

class _BatchAdvisorWidgetState extends State<BatchAdvisorWidget> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedBatch;
  String? _editingAdvisorId;
  String? _editingOldBatch;
  bool _isEditing = false;
  List<Map<String, dynamic>> _unassignedBatches = [];
  bool _loadingBatches = false;

  @override
  void initState() {
    super.initState();
    _loadUnassignedBatches();
  }

  Future<void> _loadUnassignedBatches() async {
    setState(() => _loadingBatches = true);
    try {
      final batches = await SupabaseService.getUnassignedBatches();
      setState(() => _unassignedBatches = batches);
    } catch (e) {
      setState(() => _unassignedBatches = []);
    } finally {
      setState(() => _loadingBatches = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _addOrEditAdvisor() async {
    print('_addOrEditAdvisor called');
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final batchId = _selectedBatch;

    if (name.isEmpty ||
        email.isEmpty ||
        (!_isEditing && password.isEmpty) ||
        batchId == null) {
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
        await widget.controller.editBatchAdvisor(
          userId: _editingAdvisorId!,
          name: name,
          email: email,
          password: password.isNotEmpty ? password : null,
          batchId: batchId,
          oldBatchId: _editingOldBatch,
        );
      } else {
        await widget.controller.addBatchAdvisor(
          name: name,
          email: email,
          password: password,
          batchId: batchId,
        );
      }

      // Send email notification
      await EmailService.sendCredentials(
        context: context,
        toEmail: email,
        name: name,
        role: 'Batch Advisor',
        username: email,
        password: password,
        batch: batchId,
        isDarkMode: Theme.of(context).brightness == Brightness.dark,
        isUpdate: _isEditing,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing
                ? 'Batch Advisor updated successfully!'
                : 'Batch Advisor added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      _clearForm();
      await _loadUnassignedBatches(); // Refresh dropdown after add
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

  Future<void> _deleteAdvisor(String userId, String batchName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text(
            'Are you sure you want to delete this batch advisor? This action cannot be undone.'),
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
        await widget.controller.deleteBatchAdvisor(
          userId: userId,
          batchName: batchName,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Batch Advisor deleted successfully!'),
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
    _passwordController.clear();
    setState(() {
      _selectedBatch = null;
      _editingAdvisorId = null;
      _editingOldBatch = null;
      _isEditing = false;
    });
  }

  void _editAdvisor(Map<String, dynamic> advisor) {
    _nameController.text = advisor['name'] ?? '';
    _emailController.text = advisor['email'] ?? '';
    _passwordController.clear();

    // Find the batch for this advisor
    final batch = widget.controller.batches.firstWhere(
      (b) => b['advisor_id'] == advisor['id'],
      orElse: () => <String, dynamic>{},
    );

    setState(() {
      _selectedBatch = batch['id'];
      _editingAdvisorId = advisor['id'];
      _editingOldBatch = batch['id'];
      _isEditing = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: Column(
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
            child: AdvisorForm(
              nameController: _nameController,
              emailController: _emailController,
              passwordController: _passwordController,
              selectedBatch: _selectedBatch,
              batches: _unassignedBatches,
              editingAdvisorId: _editingAdvisorId,
              isEditing: _isEditing,
              isLoading: _loadingBatches,
              onBatchChanged: (val) => setState(() => _selectedBatch = val),
              onSubmit: _addOrEditAdvisor,
              onCancel: _clearForm,
            ),
          ),

          const SizedBox(height: 24),

          // Advisors List
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
            child: AdvisorList(
              advisors: widget.controller.advisors,
              batches: widget.controller.batches,
              isLoading: widget.controller.isLoading,
              onEdit: _editAdvisor,
              onDelete: _deleteAdvisor,
            ),
          ),
        ],
      ),
    );
  }
}
