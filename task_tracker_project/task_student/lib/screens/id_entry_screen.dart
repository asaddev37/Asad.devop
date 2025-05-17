import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_tracker_shared/task_tracker_shared.dart';
import '../providers/student_provider.dart';
import 'task_list_screen.dart';

class IdEntryScreen extends StatelessWidget {
  const IdEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StudentProvider>(context);
    final idController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Enter Student ID')),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: Column(
          children: [
            Text(provider.status, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: AppSizes.padding),
            TextField(
              controller: idController,
              decoration: const InputDecoration(
                labelText: 'Student ID',
                hintText: 'Enter your unique ID',
              ),
            ),
            const SizedBox(height: AppSizes.padding),
            AppButton(
              text: 'Login',
              onPressed: () async {
                final success = await provider.authenticateStudent(idController.text.trim());
                if (success) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const TaskListScreen()),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
