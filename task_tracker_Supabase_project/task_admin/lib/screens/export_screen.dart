import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:task_tracker_shared/models/user.dart' as shared;
import 'package:task_tracker_shared/task_tracker_shared.dart';
import '../providers/student_provider.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';
import '../services/admin_service.dart';
 // Import AppColors and AppSizes
import 'package:intl/intl.dart'; // For date formatting

class ExportScreen extends StatelessWidget {
  const ExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

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
            'Export Completed Tasks 📥',
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
                AppColors.gradientLightEnd.withAlpha(51),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Consumer2<StudentProvider, TaskProvider>(
            builder: (context, studentProvider, taskProvider, child) {
              final completedTasks = taskProvider.tasks
                  .where((task) => task.status == 'completed')
                  .toList();
              if (studentProvider.students.isEmpty || completedTasks.isEmpty) {
                return Center(
                  child: Text(
                    completedTasks.isEmpty
                        ? 'No completed tasks available 😔'
                        : 'No students available 😔',
                    style: const TextStyle(fontFamily: 'Comic Sans MS', fontSize: 18),
                  ),
                ).animate().fadeIn(duration: Duration(milliseconds: AppSizes.fieldAnimationDuration));
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.padding * 2),
                child: Column(
                  children: [
                    // Summary Card
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
                              'Completed Tasks Summary 🌟',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: isDarkMode ? AppColors.accentDark : AppColors.accentLight,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSizes.padding),
                            Text(
                              'Total Completed Tasks: ${completedTasks.length}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: isDarkMode ? AppColors.darkText : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(duration: Duration(milliseconds: AppSizes.cardAnimationDuration)),
                    const SizedBox(height: AppSizes.padding * 2),
                    // Completed Tasks List
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: completedTasks.length,
                      itemBuilder: (context, index) {
                        final task = completedTasks[index];
                        final student = studentProvider.students.firstWhere(
                              (s) => s.id == task.assignedTo,
                          orElse: () => shared.User(
                            id: null,
                            name: 'Unknown',
                            role: 'student',
                            createdAt: DateTime.now(),
                          ),
                        );
                        final formattedDate = task.createdAt != null
                            ? DateFormat('MMM d, yyyy').format(task.createdAt!)
                            : 'Unknown';
                        return Card(
                          elevation: AppSizes.cardElevation / 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                          ),
                          color: isDarkMode ? AppColors.darkCard : AppColors.card,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDarkMode
                                    ? [
                                  AppColors.gradientDarkStart.withOpacity(0.2),
                                  AppColors.gradientDarkEnd.withOpacity(0.2),
                                ]
                                    : [
                                  AppColors.gradientLightStart.withOpacity(0.2),
                                  AppColors.gradientLightEnd.withOpacity(0.2),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(AppSizes.padding),
                              leading: Icon(
                                Icons.check_circle,
                                color: AppColors.success,
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
                                  Text(
                                    'Student: ${student.name}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: isDarkMode ? AppColors.accentDark : AppColors.accentLight,
                                    ),
                                  ),
                                  Text(
                                    'Completed: $formattedDate',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isDarkMode ? AppColors.darkText : AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
                    const SizedBox(height: AppSizes.padding * 2),
                    // Export Button Card
                    Card(
                      elevation: AppSizes.cardElevation,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                      ),
                      color: isDarkMode ? AppColors.darkCard : AppColors.card,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.padding * 2),
                        child: GestureDetector(
                          onTap: () async {
                            try {
                              await AdminService().exportData(studentProvider.students, completedTasks);
                              _showOverlay(context, 'Data exported successfully! 🎉', isError: false);
                            } catch (e) {
                              _showOverlay(context, 'Failed to export: $e 😔', isError: true);
                              debugPrint('Export error: $e');
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
                                'Export to Excel 🚀',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ).animate(
                          onPlay: (controller) => controller.repeat(reverse: true),
                        ).scale(
                          begin: const Offset(0.95, 0.95),
                          end: const Offset(1.0, 1.0),
                          duration: Duration(milliseconds: AppSizes.buttonAnimationDuration),
                          curve: Curves.easeInOut,
                        ),
                      ),
                    ).animate().fadeIn(duration: Duration(milliseconds: AppSizes.cardAnimationDuration)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

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
}