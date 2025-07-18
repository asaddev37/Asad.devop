import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/admin_dashboard_controller.dart';

class AdminProfileScreen extends StatefulWidget {
  final AdminDashboardController controller;
  final ThemeData theme;

  const AdminProfileScreen(
      {super.key, required this.controller, required this.theme});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current admin data
    final admin = widget.controller.adminProfile;
    _nameController = TextEditingController(text: admin?['name'] ?? '');
    _emailController = TextEditingController(text: admin?['email'] ?? '');

    // Listen to controller changes to update the form
    widget.controller.addListener(_updateFormFields);
  }

  void _updateFormFields() {
    final admin = widget.controller.adminProfile;
    if (admin != null) {
      _nameController.text = admin['name'] ?? '';
      _emailController.text = admin['email'] ?? '';
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateFormFields);
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!mounted) return;

    // Show a loading dialog with dark theme styling
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: widget.theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    widget.theme.colorScheme.primary),
              ),
              const SizedBox(height: 16),
              Text(
                'Updating profile...',
                style: TextStyle(
                  color: widget.theme.colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      await widget.controller.updateAdminProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        image: _selectedImage,
      );

      // Clear the selected image after saving
      setState(() {
        _selectedImage = null;
      });

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully!'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        setState(() {
          _isEditing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin = widget.controller.adminProfile;
    final avatarUrl = admin?['avatar_url'] as String?;
    final adminName = admin?['name'] ?? 'Admin';
    final theme = widget.theme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.background,
            theme.colorScheme.background.withOpacity(0.95),
          ],
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isEditing ? 'Edit Profile' : 'My Profile',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        tooltip: _isEditing ? 'Save Changes' : 'Edit Profile',
                        icon: Icon(
                          _isEditing
                              ? Icons.save_alt_outlined
                              : Icons.edit_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        onPressed: () {
                          if (_isEditing) {
                            _saveProfile();
                          } else {
                            setState(() {
                              _isEditing = !_isEditing;
                            });
                          }
                        },
                      ),
                      if (_isEditing)
                        IconButton(
                          tooltip: 'Cancel',
                          icon: Icon(
                            Icons.cancel_outlined,
                            color: Colors.red.shade400,
                          ),
                          onPressed: () {
                            setState(() {
                              _isEditing = false;
                              _selectedImage = null; // Discard selected image
                              _updateFormFields(); // Reset form fields
                            });
                          },
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Content
              _buildProfileContent(theme, adminName, avatarUrl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent(
      ThemeData theme, String adminName, String? avatarUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Profile Header Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.primary,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 70,
                      backgroundColor: theme.colorScheme.surface,
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : (avatarUrl != null ? NetworkImage(avatarUrl) : null)
                              as ImageProvider?,
                      child: _selectedImage == null && avatarUrl == null
                          ? Text(
                              adminName.isNotEmpty
                                  ? adminName[0].toUpperCase()
                                  : 'A',
                              style: TextStyle(
                                fontSize: 60,
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),
                  if (_isEditing)
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _pickImage,
                          borderRadius: BorderRadius.circular(30),
                          child: const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    )
                ],
              ),
              const SizedBox(height: 20),
              Text(
                adminName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Administrator',
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Profile Details Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              _buildProfileTextField(
                controller: _nameController,
                labelText: 'Full Name',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _buildProfileTextField(
                controller: _emailController,
                labelText: 'Email Address',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    final theme = widget.theme;

    return Material(
      color: _isEditing
          ? theme.colorScheme.background.withOpacity(0.3)
          : theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _isEditing
              ? theme.colorScheme.onSurface.withOpacity(0.3)
              : theme.colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        enabled: _isEditing,
        keyboardType: keyboardType,
        style: TextStyle(
          color: theme.colorScheme.onSurface,
          fontWeight: _isEditing ? FontWeight.normal : FontWeight.w600,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            color: _isEditing
                ? theme.colorScheme.onSurface.withOpacity(0.7)
                : theme.colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            icon,
            color: _isEditing
                ? theme.colorScheme.onSurface.withOpacity(0.7)
                : theme.colorScheme.primary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
