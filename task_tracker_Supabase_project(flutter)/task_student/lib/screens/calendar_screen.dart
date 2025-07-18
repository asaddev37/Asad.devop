import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_tracker_shared/task_tracker_shared.dart';
import '../providers/student_provider.dart';
import '../providers/task_provider.dart';
import 'id_entry_screen.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final student = Provider.of<StudentProvider>(context).currentStudent;
    if (student == null) return const IdEntryScreen();

    return ChangeNotifierProvider(
      create: (_) => TaskProvider()..fetchTasks(student.id!), // Fix: Use ! since student is non-null
      child: Scaffold(
        appBar: AppBar(title: const Text('Task Calendar')),
        body: Consumer<TaskProvider>(
          builder: (context, taskProvider, child) {
            return Padding(
              padding: const EdgeInsets.all(AppSizes.padding),
              child: Column(
                children: [
                  Text(taskProvider.status, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: AppSizes.padding),
                  CalendarWidget(
                    tasks: taskProvider.tasks,
                    onDaySelected: (selectedDay) {
                      final tasksOnDay = taskProvider.tasks.where((t) => t.dueDate?.day == selectedDay.day).toList();
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text('Tasks for ${selectedDay.toString().split(' ')[0]}'),
                          content: tasksOnDay.isEmpty
                              ? const Text('No tasks')
                              : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: tasksOnDay.map((task) => Text(task.title)).toList(),
                          ),
                          actions: [
                            AppButton(text: 'Close', onPressed: () => Navigator.pop(context)),
                          ],
                        ),
                      );
                    },
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