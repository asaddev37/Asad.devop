import 'package:flutter/material.dart';
import '../../../../services/email_service.dart';
import '../../controllers/admin_dashboard_controller.dart';
import 'hod_form.dart';
import 'hod_details_card.dart';

class HodManagementWidget extends StatefulWidget {
  final AdminDashboardController controller;

  const HodManagementWidget({
    super.key,
    required this.controller,
  });

  @override
  State<HodManagementWidget> createState() => _HodManagementWidgetState();
}

class _HodManagementWidgetState extends State<HodManagementWidget> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadHodData();
  }

  void _loadHodData() {
    final hod = widget.controller.hodProfile;
    if (hod != null) {
      _nameController.text = hod['name'] ?? '';
      _emailController.text = hod['email'] ?? '';
      _passwordController.clear();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _addOrEditHod() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || (!_isEditing && password.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await widget.controller.addOrUpdateHod(
        name: name,
        email: email,
        password: password,
        isEdit: _isEditing,
      );

      // Send email notification
      await EmailService.sendCredentials(
        context: context,
        toEmail: email,
        name: name,
        role: 'HOD',
        username: email,
        password: password,
        isDarkMode: Theme.of(context).brightness == Brightness.dark,
        isUpdate: _isEditing,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing
                ? 'HOD updated successfully!'
                : 'HOD added successfully!'),
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

  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    setState(() {
      _isEditing = false;
    });
  }

  void _editHod() {
    setState(() {
      _isEditing = true;
    });
    _loadHodData();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      child: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, child) {
          final hod = widget.controller.hodProfile;
          final bool hodExists = hod != null;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Show HOD details if one exists
              if (hodExists && !_isEditing)
                HodDetailsCard(
                  hod: hod,
                  departmentName:
                      widget.controller.state.currentDepartment?['name'],
                ),

              // Add Edit button when HOD exists and not in editing mode
              if (hodExists && !_isEditing) ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Edit HOD',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: _editHod,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Conditionally show the form or the "already assigned" message
              if (_isEditing)
                HodForm(
                  nameController: _nameController,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  isEditing: true,
                  isLoading: widget.controller.isLoading,
                  onSubmit: _addOrEditHod,
                  onCancel: _clearForm,
                )
              else if (hodExists)
                _buildHodAssignedCard(context)
              else
                HodForm(
                  nameController: _nameController,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  isEditing: false,
                  isLoading: widget.controller.isLoading,
                  onSubmit: _addOrEditHod,
                  onCancel: _clearForm,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHodAssignedCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: theme.colorScheme.primary,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HOD Already Assigned',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'A Head of Department is already assigned to this department. You can edit the existing HOD details.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
