import 'package:flutter/material.dart';

class ConfirmationDialog {
  static Future<bool> show(BuildContext context, {required String title, required String content, bool isDarkMode = false}) async {
    final _lightModeDialogBg = Colors.white;
    final _lightModeDialogText = Colors.grey;
    final _lightModeConfirmButton = Colors.blue;
    final _lightModeCancelButton = Colors.grey;
    final _darkModeDialogBg = Color(0xFF424242);
    final _darkModeDialogText = Colors.white70;
    final _darkModeConfirmButton = Colors.amber;
    final _darkModeCancelButton = Colors.grey;

    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? _darkModeDialogBg : _lightModeDialogBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          title,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          content,
          style: TextStyle(
            color: isDarkMode ? _darkModeDialogText : _lightModeDialogText,
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: isDarkMode ? _darkModeCancelButton : _lightModeCancelButton,
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDarkMode ? _darkModeCancelButton : _lightModeCancelButton,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: isDarkMode ? _darkModeConfirmButton : _lightModeConfirmButton,
              backgroundColor: isDarkMode ? _darkModeConfirmButton.withAlpha(26) : _lightModeConfirmButton.withAlpha(26),
            ),
            child: Text(
              'Confirm',
              style: TextStyle(
                color: isDarkMode ? _darkModeConfirmButton : _lightModeConfirmButton,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    ) ?? false;
  }
}