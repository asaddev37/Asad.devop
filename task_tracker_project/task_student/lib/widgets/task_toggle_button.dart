import 'package:flutter/material.dart';
import 'package:task_tracker_shared/task_tracker_shared.dart';

class TaskToggleButton extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;

  const TaskToggleButton({
    super.key,
    required this.task,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: task.status == 'completed' ? 'Mark Incomplete' : 'Mark Complete',
      onPressed: onToggle,
      isPrimary: task.status == 'completed',
    );
  }
}