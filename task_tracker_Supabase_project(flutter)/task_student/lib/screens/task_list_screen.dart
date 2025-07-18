import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_tracker_shared/task_tracker_shared.dart';
import '../widgets/task_toggle_button.dart';
import '../providers/student_provider.dart';
import '../providers/task_provider.dart';
import 'id_entry_screen.dart';
import 'progress_screen.dart';
import 'calendar_screen.dart';
import 'gamification_screen.dart';
import 'settings_screen.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);
    final student = studentProvider.currentStudent;

    if (student == null) {
      return const IdEntryScreen();
    }

    return ChangeNotifierProvider(
      create: (context) => TaskProvider()..subscribeToTasks(student.id!), // Fix: Use ! since student is non-null
      child: Scaffold(
        appBar: AppBar(
          title: Text('Tasks for ${student.name}'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                studentProvider.logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const IdEntryScreen()),
                );
              },
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: AppColors.primary),
                child: Text(
                  'Welcome, ${student.name}',
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.bar_chart),
                title: const Text('Progress'),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProgressScreen())),
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Calendar'),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarScreen())),
              ),
              ListTile(
                leading: const Icon(Icons.star),
                title: const Text('Achievements'),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GamificationScreen())),
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
              ),
            ],
          ),
        ),
        body: Consumer<TaskProvider>(
          builder: (context, taskProvider, child) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSizes.padding),
                  child: Text(taskProvider.status, style: Theme.of(context).textTheme.bodyMedium),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSizes.padding),
                    itemCount: taskProvider.tasks.length,
                    itemBuilder: (context, index) {
                      final task = taskProvider.tasks[index];
                      return TaskCard(
                        task: task,
                        onTap: () => showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text(task.title),
                            content: Text(task.description ?? 'No description'),
                            actions: [
                              TaskToggleButton(
                                task: task,
                                onToggle: () {
                                  taskProvider.updateTaskStatus(
                                    task.id!, // Force unwrap the nullable String
                                    task.status == 'completed' ? 'pending' : 'completed',
                                  );

                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}