import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:task_tracker_shared/task_tracker_shared.dart';
import '../widgets/student_list_item.dart';
import '../providers/student_provider.dart';
import '../services/admin_service.dart';
import 'package:flutter/services.dart'; // For Clipboard

class StudentManagementScreen extends StatelessWidget {
  const StudentManagementScreen({super.key});

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
                child: Column(
                  children: [
                    Text(
                      message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (!isError && message.contains('ID')) ...[
                      const SizedBox(height: AppSizes.padding),
                      GestureDetector(
                        onTap: () {
                          final idText = message.split('ID: ')[1].split(' 🎉')[0];
                          Clipboard.setData(ClipboardData(text: idText));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('IDs copied to clipboard! 🎉')),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.padding * 2,
                            vertical: AppSizes.padding,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDarkMode
                                  ? [AppColors.gradientDarkStart, AppColors.gradientDarkEnd]
                                  : [AppColors.gradientLightStart, AppColors.gradientLightEnd],
                            ),
                            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                          ),
                          child: Text(
                            'Copy IDs 📋',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
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
          'Are you sure you want to delete this student?',
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return ChangeNotifierProvider(
      create: (_) => StudentProvider()..fetchStudents(),
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
            'Manage Students 🌟',
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
            child: Consumer<StudentProvider>(
              builder: (context, provider, child) {
                final adminService = AdminService();
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
                          provider.status.isEmpty ? 'Ready to manage students! 🚀' : provider.status,
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
                        child: GestureDetector(
                          onTap: () async {
                            try {
                              final result = await FilePicker.platform.pickFiles(
                                type: FileType.custom,
                                allowedExtensions: ['xlsx', 'xls'],
                              );
                              if (result != null && result.files.first.extension?.toLowerCase() == 'xlsx') {
                                await adminService.uploadExcel(result.files.first);
                                provider.fetchStudents();
                                if (adminService.lastAddedStudentIds.isNotEmpty) {
                                  _showOverlay(
                                    context,
                                    'Students added via Excel! ID: ${adminService.lastAddedStudentIds.join(', ')} 🎉',
                                    isError: false,
                                  );
                                } else {
                                  _showOverlay(context, 'No new students added from Excel 😔', isError: true);
                                }
                              } else {
                                _showOverlay(context, 'Please select a valid Excel file (.xlsx) 😔', isError: true);
                              }
                            } catch (e) {
                              _showOverlay(context, 'Excel upload failed: ${e.toString()} 😔', isError: true);
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
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSizes.padding * 1.5,
                              horizontal: AppSizes.padding * 2,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.upload_file,
                                  color: Colors.white,
                                  size: 24,
                                ).animate(
                                  onPlay: (controller) => controller.repeat(reverse: true),
                                ).scale(
                                  begin: const Offset(0.9, 0.9),
                                  end: const Offset(1.1, 1.1),
                                  duration: Duration(milliseconds: AppSizes.buttonAnimationDuration),
                                  curve: Curves.easeInOut,
                                ),
                                const SizedBox(width: AppSizes.padding),
                                Text(
                                  'Upload Excel 📊',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                              'Student List 📋',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: isDarkMode ? AppColors.accentDark : AppColors.accentLight,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSizes.padding),
                            provider.students.isEmpty
                                ? Text(
                              'No students found 😔',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: isDarkMode ? AppColors.darkText : AppColors.textPrimary,
                              ),
                            ).animate().fadeIn(
                              duration: Duration(milliseconds: AppSizes.fieldAnimationDuration),
                            )
                                : SizedBox(
                              height: 300, // Fixed height for scrollable list
                              child: ListView.builder(
                                itemCount: provider.students.length,
                                itemBuilder: (context, index) {
                                  final student = provider.students[index];
                                  return StudentListItem(
                                    student: student,
                                    onDelete: () async {
                                      final confirmed = await _confirmDeletion(context);
                                      if (confirmed) {
                                        try {
                                          await provider.deleteStudent(student.id!);
                                          _showOverlay(
                                            context,
                                            'Student deleted successfully! 🎉',
                                            isError: false,
                                          );
                                        } catch (e) {
                                          _showOverlay(
                                            context,
                                            'Failed to delete student: ${e.toString()} 😔',
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
                        child: _buildAddStudentForm(context, provider, isDarkMode),
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

  Widget _buildAddStudentForm(BuildContext context, StudentProvider provider, bool isDarkMode) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Add New Student ✏️',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: isDarkMode ? AppColors.accentDark : AppColors.accentLight,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSizes.padding * 2),
        TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'Name',
            hintText: 'Enter student name',
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
          style: Theme.of(context).textTheme.bodyMedium,
        ).animate().fadeIn(duration: Duration(milliseconds: AppSizes.fieldAnimationDuration)),
        const SizedBox(height: AppSizes.padding),
        TextField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: 'Email (Optional)',
            hintText: 'Enter student email',
            prefixIcon: Icon(
              Icons.email,
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
          keyboardType: TextInputType.emailAddress,
        ).animate().fadeIn(duration: Duration(milliseconds: AppSizes.fieldAnimationDuration)),
        const SizedBox(height: AppSizes.padding * 2),
        GestureDetector(
          onTap: () async {
            final name = nameController.text.trim();
            final email = emailController.text.trim().isEmpty ? null : emailController.text.trim();

            if (name.isEmpty) {
              _showOverlay(context, 'Name is required 😔', isError: true);
              return;
            }

            try {
              await provider.addStudent(name, email);
              if (provider.status.contains('Student added successfully') && provider.lastAddedStudentId != null) {
                _showOverlay(
                  context,
                  'Student added! ID: ${provider.lastAddedStudentId} 🎉',
                  isError: false,
                );
                nameController.clear();
                emailController.clear();
              } else {
                _showOverlay(context, provider.status.isEmpty ? 'Failed to add student 😔' : provider.status, isError: true);
              }
            } catch (e) {
              _showOverlay(context, 'Failed to add student: ${e.toString()} 😔', isError: true);
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
                'Add Student 🚀',
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
}