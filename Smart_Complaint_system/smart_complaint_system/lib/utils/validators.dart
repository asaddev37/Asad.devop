import 'package:flutter/material.dart';
import '../widgets/validation_overlay.dart';

class Validators {
  static bool validateForm(
      BuildContext context, {
        required String name,
        required String email,
        required String password,
        String? role,
        String? batch,
      }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final fieldKey = GlobalKey(); // Use unique keys per field in production

    if (name.isEmpty) {
      ValidationOverlay.show(
        context: context,
        message: 'Name is required',
        fieldKey: fieldKey,
        isDarkMode: isDarkMode,
      );
      return false;
    }

    if (name.length < 3) {
      ValidationOverlay.show(
        context: context,
        message: 'Name must be at least 3 characters',
        fieldKey: fieldKey,
        isDarkMode: isDarkMode,
      );
      return false;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      ValidationOverlay.show(
        context: context,
        message: 'Invalid email format',
        fieldKey: fieldKey,
        isDarkMode: isDarkMode,
      );
      return false;
    }

    if (password.isEmpty) {
      ValidationOverlay.show(
        context: context,
        message: 'Password is required',
        fieldKey: fieldKey,
        isDarkMode: isDarkMode,
      );
      return false;
    }

    if (password.length < 6) {
      ValidationOverlay.show(
        context: context,
        message: 'Password must be at least 6 characters',
        fieldKey: fieldKey,
        isDarkMode: isDarkMode,
      );
      return false;
    }

    if (role == null) {
      ValidationOverlay.show(
        context: context,
        message: 'Role is required',
        fieldKey: fieldKey,
        isDarkMode: isDarkMode,
      );
      return false;
    }

    if (role != 'admin' && role != 'hod' && batch == null) {
      ValidationOverlay.show(
        context: context,
        message: 'Batch is required for students and batch advisors',
        fieldKey: fieldKey,
        isDarkMode: isDarkMode,
      );
      return false;
    }

    return true;
  }
}