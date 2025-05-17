import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:task_tracker_shared/task_tracker_shared.dart';
import '../providers/task_provider.dart';
import '../providers/student_provider.dart';
import '../providers/admin_provider.dart';
import 'admin_login_screen.dart';
import 'package:intl/intl.dart'; // For date formatting

void _showOverlay(BuildContext context, String message, {required bool isError}) {
  final isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
  OverlayEntry? overlayEntry;
  final animationController = AnimationController(
    vsync: Navigator.of(context),
    duration: Duration(milliseconds: AppSizes.fieldAnimationDuration),
  );

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: 100,
      left: 20,
      right: 20,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.8, end: 1.0).animate(
          CurvedAnimation(parent: animationController, curve: Curves.bounceOut),
        ),
        child: FadeTransition(
          opacity: animationController,
          child: Material(
            elevation: AppSizes.cardElevation,
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            child: Container(
              padding: const EdgeInsets.all(AppSizes.padding * 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isError
                      ? [AppColors.error, AppColors.error.withOpacity(0.7)]
                      : [AppColors.success, AppColors.success.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              ),
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Overlay.of(context).insert(overlayEntry);
  animationController.forward();

  Future.delayed(const Duration(seconds: 3), () {
    if (overlayEntry != null && overlayEntry.mounted) {
      animationController.reverse().then((_) {
        overlayEntry?.remove();
        animationController.dispose();
      });
    }
  });
}

Future<bool> _confirmDeletion(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        'Confirm Deletion 🔍',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      content: Text(
        'Are you sure you want to delete this task?',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancel', style: Theme.of(context).textTheme.bodyMedium),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            'Delete',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.error),
          ),
        ),
      ],
    ),
  ) ??
      false;
}

class TaskManagementScreen extends StatelessWidget {
  const TaskManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    if (adminProvider.adminUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const AdminLoginScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      });
      return const SizedBox();
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StudentProvider()..fetchStudents()),
        ChangeNotifierProvider(create: (_) => TaskProvider()..fetchAllTasks()),
      ],
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [AppColors.gradientDarkStart, AppColors.gradientDarkEnd]
                    : [AppColors.gradientLightStart, AppColors.gradientLightEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ).animate().fadeIn(duration: Duration(milliseconds: AppSizes.cardAnimationDuration)),
          title: Text(
            'Manage Tasks 🌟',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              shadows: const [
                Shadow(blurRadius: 10.0, color: Colors.black45, offset: Offset(2.0, 2.0)),
              ],
            ),
          ).animate().fadeIn(duration: Duration(milliseconds: AppSizes.cardAnimationDuration)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Back',
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode
                  ? [AppColors.gradientDarkStart, AppColors.gradientDarkEnd]
                  : [
                AppColors.gradientLightStart.withAlpha(51),
                AppColors.gradientLightEnd.withAlpha(51)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.padding * 2),
            child: Consumer2<StudentProvider, TaskProvider>(
              builder: (context, studentProvider, taskProvider, child) {
                return Column(
                  children: [
                    Card(
                      elevation: AppSizes.cardElevation,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                      ),
                      color: isDarkMode ? AppColors.darkCard : AppColors.card,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.padding * 2),
                        child: Text(
                          taskProvider.status.isEmpty ? 'Ready to manage tasks! 🚀' : taskProvider.status,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDarkMode ? AppColors.darkText : AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ).animate().fadeIn(duration: Duration(milliseconds: AppSizes.cardAnimationDuration)),
                    const SizedBox(height: AppSizes.padding * 2),
                    Card(
                      elevation: AppSizes.cardElevation,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                      ),
                      color: isDarkMode ? AppColors.darkCard : AppColors.card,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.padding * 2),
                        child: Column(
                          children: [
                            Text(
                              'Task List 📋',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: isDarkMode ? AppColors.accentDark : AppColors.accentLight,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSizes.padding),
                            taskProvider.tasks.isEmpty
                                ? Text(
                              'No tasks found 😔',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: isDarkMode ? AppColors.darkText : AppColors.textPrimary,
                              ),
                            ).animate().fadeIn(
                              duration: Duration(milliseconds: AppSizes.fieldAnimationDuration),
                            )
                                : SizedBox(
                              height: 400, // Fixed height for scrollable list
                              child: ListView.builder(
                                itemCount: taskProvider.tasks.length,
                                itemBuilder: (context, index) {
                                  final task = taskProvider.tasks[index];
                                  final student = studentProvider.students.firstWhere(
                                        (s) => s.id == task.assignedTo,
                                    orElse: () => User(
                                      id: null,
                                      name: 'Unknown',
                                      role: 'student',
                                      createdAt: DateTime.now(),
                                    ),
                                  );
                                  return TaskCard(
                                    task: task,
                                    studentName: student.name,
                                    onDelete: () async {
                                      final confirmed = await _confirmDeletion(context);
                                      if (confirmed) {
                                        try {
                                          await taskProvider.deleteTask(task.id!);
                                          _showOverlay(
                                            context,
                                            'Task deleted successfully! 🎉',
                                            isError: false,
                                          );
                                        } catch (e) {
                                          _showOverlay(
                                            context,
                                            'Failed to delete task: ${e.toString()} 😔',
                                            isError: true,
                                          );
                                        }
                                      }
                                    },
                                  ).animate(
                                    delay: Duration(milliseconds: index * 100),
                                  ).fadeIn(
                                    duration: Duration(milliseconds: AppSizes.fieldAnimationDuration),
                                  ).slideY(
                                    begin: 0.5,
                                    end: 0.0,
                                    duration: Duration(milliseconds: AppSizes.fieldAnimationDuration),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(duration: Duration(milliseconds: AppSizes.cardAnimationDuration)),
                    const SizedBox(height: AppSizes.padding * 2),
                    Card(
                      elevation: AppSizes.cardElevation,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                      ),
                      color: isDarkMode ? AppColors.darkCard : AppColors.card,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.padding * 2),
                        child: _buildTaskForm(
                          context,
                          studentProvider,
                          taskProvider,
                          adminProvider.adminUser!.id!,
                          isDarkMode,
                        ),
                      ),
                    ).animate().fadeIn(duration: Duration(milliseconds: AppSizes.cardAnimationDuration)),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final Task task;
  final String studentName;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.studentName,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final formattedDate = task.createdAt != null
        ? DateFormat('MMM d, yyyy').format(task.createdAt!)
        : 'Unknown';

    return Card(
      elevation: AppSizes.cardElevation / 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      margin: const EdgeInsets.symmetric(vertical: AppSizes.padding / 2),
      color: isDarkMode ? AppColors.darkCard : AppColors.card,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [AppColors.gradientDarkStart.withOpacity(0.2), AppColors.gradientDarkEnd.withOpacity(0.2)]
                : [AppColors.gradientLightStart.withOpacity(0.2), AppColors.gradientLightEnd.withOpacity(0.2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? AppColors.shadowDark : AppColors.shadowLight,
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(AppSizes.padding),
          leading: Icon(
            Icons.task_alt,
            color: isDarkMode ? AppColors.accentDark : AppColors.accentLight,
            size: 32,
          ).animate(
            onPlay: (controller) => controller.repeat(reverse: true),
          ).scale(
            begin: const Offset(0.9, 0.9),
            end: const Offset(1.1, 1.1),
            duration: Duration(milliseconds: AppSizes.buttonAnimationDuration),
            curve: Curves.easeInOut,
          ),
          title: Text(
            task.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: isDarkMode ? AppColors.darkText : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.description != null) ...[
                Text(
                  task.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDarkMode ? AppColors.darkText : AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSizes.padding / 2),
              ],
              Text(
                'Assigned to: $studentName',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDarkMode ? AppColors.accentDark : AppColors.accentLight,
                ),
              ),
              Text(
                'Created by: ${task.createdBy} on $formattedDate',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDarkMode ? AppColors.darkText : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.delete,
              color: AppColors.error,
            ),
            onPressed: onDelete,
            tooltip: 'Delete Task',
          ),
        ),
      ),
    );
  }
}

Widget _buildTaskForm(
    BuildContext context,
    StudentProvider studentProvider,
    TaskProvider taskProvider,
    String adminId,
    bool isDarkMode,
    ) {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  String? selectedStudentId;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        'Create New Task ✏️',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: isDarkMode ? AppColors.accentDark : AppColors.accentLight,
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: AppSizes.padding * 2),
      TextField(
        controller: titleController,
        decoration: InputDecoration(
          labelText: 'Task Title',
          hintText: 'Enter task title',
          prefixIcon: Icon(
            Icons.title,
            color: isDarkMode ? AppColors.accentDark : AppColors.accentLight,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            borderSide: BorderSide(
              color: isDarkMode ? AppColors.accentDark : AppColors.accentLight,
            ),
          ),
        ),
        style: Theme.of(context).textTheme.bodyMedium,
      ).animate().fadeIn(duration: Duration(milliseconds: AppSizes.fieldAnimationDuration)),
      const SizedBox(height: AppSizes.padding),
      TextField(
        controller: descController,
        decoration: InputDecoration(
          labelText: 'Description (Optional)',
          hintText: 'Enter task description',
          prefixIcon: Icon(
            Icons.description,
            color: isDarkMode ? AppColors.accentDark : AppColors.accentLight,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            borderSide: BorderSide(
              color: isDarkMode ? AppColors.accentDark : AppColors.accentLight,
            ),
          ),
        ),
        style: Theme.of(context).textTheme.bodyMedium,
      ).animate().fadeIn(duration: Duration(milliseconds: AppSizes.fieldAnimationDuration)),
      const SizedBox(height: AppSizes.padding),
      DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Assign To',
          hintText: 'Select a student',
          prefixIcon: Icon(
            Icons.person,
            color: isDarkMode ? AppColors.accentDark : AppColors.accentLight,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            borderSide: BorderSide(
              color: isDarkMode ? AppColors.accentDark : AppColors.accentLight,
            ),
          ),
        ),
        items: studentProvider.students.map((student) {
          return DropdownMenuItem(
            value: student.id,
            child: Text(
              student.name,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }).toList(),
        onChanged: (value) => selectedStudentId = value,
        value: selectedStudentId,
      ).animate().fadeIn(duration: Duration(milliseconds: AppSizes.fieldAnimationDuration)),
      const SizedBox(height: AppSizes.padding * 2),
      GestureDetector(
        onTap: () async {
          if (selectedStudentId == null || titleController.text.trim().isEmpty) {
            _showOverlay(context, 'Title and assigned student are required 😔', isError: true);
            return;
          }

          try {
            await taskProvider.createTask(
              title: titleController.text.trim(),
              description: descController.text.trim().isEmpty ? null : descController.text.trim(),
              assignedTo: selectedStudentId!,
              createdBy: adminId,
              dueDate: null,
            );
            _showOverlay(context, 'Task created successfully! 🎉', isError: false);
            titleController.clear();
            descController.clear();
            selectedStudentId = null;
          } catch (e) {
            _showOverlay(context, 'Failed to create task: ${e.toString()} 😔', isError: true);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode
                  ? [AppColors.gradientDarkStart, AppColors.gradientDarkEnd]
                  : [AppColors.gradientLightStart, AppColors.gradientLightEnd],
            ),
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            boxShadow: [
              BoxShadow(
                color: isDarkMode ? AppColors.shadowDark : AppColors.shadowLight,
                blurRadius: 6,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: AppSizes.padding * 1.5),
          child: Center(
            child: Text(
              'Create Task 🚀',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ).animate().scale(
        begin: const Offset(0.9, 0.9),
        end: const Offset(1.0, 1.0),
        duration: Duration(milliseconds: AppSizes.buttonAnimationDuration),
        curve: Curves.bounceOut,
      ),
    ],
  );
}