import 'package:flutter/material.dart';
import 'package:task_tracker_shared/task_tracker_shared.dart';

class UploadButton extends StatelessWidget {
  final VoidCallback onPressed;

  const UploadButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: 'Upload Excel',
      onPressed: onPressed,
      isPrimary: false,
    );
  }
}