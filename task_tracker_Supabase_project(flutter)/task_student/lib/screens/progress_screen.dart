import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_tracker_shared/task_tracker_shared.dart';
import '../providers/student_provider.dart';
import '../providers/task_provider.dart';
import 'id_entry_screen.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final student = Provider.of<StudentProvider>(context).currentStudent;
    if (student == null || student.id == null) {
      return const IdEntryScreen();
    }

    return ChangeNotifierProvider(
      create: (_) => TaskProvider(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Your Progress')),
        body: Builder(
          builder: (context) {
            final taskProvider = Provider.of<TaskProvider>(context, listen: false);
            return FutureBuilder<void>(
              future: taskProvider.fetchTasks(student.id!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                return Consumer<TaskProvider>(
                  builder: (context, taskProvider, child) {
                    final analyticsService = AnalyticsService();
                    final report = analyticsService.calculateReport(taskProvider.tasks, student.id!);
                    return Padding(
                      padding: const EdgeInsets.all(AppSizes.padding),
                      child: Column(
                        children: [
                          Text(taskProvider.status, style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: AppSizes.padding),
                          ChartWidget(
                            title: 'Performance Score',
                            data: [report.performanceScore.toDouble()],
                          ),
                          const SizedBox(height: AppSizes.padding),
                          Text('Completed Tasks: ${report.completedTasks}', style: Theme.of(context).textTheme.titleLarge),
                          Text('Pending Tasks: ${report.pendingTasks}', style: Theme.of(context).textTheme.titleLarge),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}