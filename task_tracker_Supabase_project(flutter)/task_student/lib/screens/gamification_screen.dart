import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_tracker_shared/task_tracker_shared.dart';
import '../widgets/badge_widget.dart';
import '../providers/student_provider.dart';
import '../providers/task_provider.dart';
import '../services/student_service.dart';
import 'id_entry_screen.dart';

class GamificationScreen extends StatelessWidget {
  const GamificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final student = Provider.of<StudentProvider>(context).currentStudent;
    if (student == null) return const IdEntryScreen();

    return ChangeNotifierProvider(
      create: (_) => TaskProvider()..fetchTasks(student.id!), // Fix: Use ! since student is non-null
      child: Scaffold(
        appBar: AppBar(title: const Text('Your Achievements')),
        body: Consumer<TaskProvider>(
          builder: (context, taskProvider, child) {
            final studentService = StudentService();
            final streak = studentService.calculateStreak(taskProvider.tasks);
            final badges = studentService.getBadges(taskProvider.tasks);

            return Padding(
              padding: const EdgeInsets.all(AppSizes.padding),
              child: Column(
                children: [
                  Text(taskProvider.status, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: AppSizes.padding),
                  Text('Streak: $streak days', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSizes.padding),
                  Text('Badges', style: Theme.of(context).textTheme.titleLarge),
                  Expanded(
                    child: ListView.builder(
                      itemCount: badges.length,
                      itemBuilder: (context, index) {
                        return BadgeWidget(badgeName: badges[index]);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}