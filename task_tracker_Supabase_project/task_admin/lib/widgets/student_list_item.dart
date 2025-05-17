import 'package:flutter/material.dart';
import 'package:task_tracker_shared/task_tracker_shared.dart';

class StudentListItem extends StatelessWidget {
  final User student;
  final VoidCallback onDelete;

  const StudentListItem({
    super.key,
    required this.student,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      child: ListTile(
        title: Text(student.name, style: Theme.of(context).textTheme.titleLarge),
        subtitle: Text(student.email ?? 'No email'),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: AppColors.error),
          onPressed: onDelete,
        ),
      ),
    );
  }
}