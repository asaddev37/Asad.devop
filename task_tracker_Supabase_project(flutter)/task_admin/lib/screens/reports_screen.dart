import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:task_tracker_shared/task_tracker_shared.dart';
import '../providers/student_provider.dart';
import '../providers/task_provider.dart';

// Import AppColors and AppSizes

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

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
            'Performance Reports 📊',
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
              if (studentProvider.students.isEmpty) {
                return const Center(
                  child: Text(
                    'No students available 😔',
                    style: TextStyle(fontFamily: 'Comic Sans MS', fontSize: 18),
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
                              'Summary 🌟',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: isDarkMode ? AppColors.accentDark : AppColors.accentLight,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSizes.padding),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildSummaryItem(
                                  context,
                                  'Students',
                                  studentProvider.students.length.toString(),
                                  isDarkMode,
                                ),
                                _buildSummaryItem(
                                  context,
                                  'Tasks',
                                  taskProvider.tasks.length.toString(),
                                  isDarkMode,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(duration: Duration(milliseconds: AppSizes.cardAnimationDuration)),
                    const SizedBox(height: AppSizes.padding * 2),
                    // Student Performance Charts
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: studentProvider.students.length,
                      itemBuilder: (context, index) {
                        final student = studentProvider.students[index];
                        if (student.id == null) {
                          return Card(
                            child: ListTile(
                              title: Text(
                                'Invalid Student Data',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          );
                        }
                        final analyticsService = AnalyticsService();
                        final report = analyticsService.calculateReport(
                          taskProvider.tasks.where((task) => task.assignedTo == student.id).toList(),
                          student.id!,
                        );
                        return Card(
                          elevation: AppSizes.cardElevation,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                          ),
                          color: isDarkMode ? AppColors.darkCard : AppColors.card,
                          child: Padding(
                            padding: const EdgeInsets.all(AppSizes.padding * 2),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${student.name}\'s Performance',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: isDarkMode ? AppColors.accentDark : AppColors.accentLight,
                                  ),
                                ),
                                const SizedBox(height: AppSizes.padding),
                                SizedBox(
                                  height: 200,
                                  child: BarChart(
                                    BarChartData(
                                      alignment: BarChartAlignment.spaceAround,
                                      maxY: 100,
                                      minY: 0,
                                      barGroups: [
                                        BarChartGroupData(
                                          x: 0,
                                          barRods: [
                                            BarChartRodData(
                                              toY: report.performanceScore.toDouble(),
                                              color: report.performanceScore < 50
                                                  ? AppColors.error
                                                  : report.performanceScore > 75
                                                  ? AppColors.success
                                                  : isDarkMode
                                                  ? AppColors.accentDark
                                                  : AppColors.accentLight,
                                              width: 40,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ],
                                        ),
                                      ],
                                      titlesData: FlTitlesData(
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 40,
                                            getTitlesWidget: (value, meta) {
                                              return Text(
                                                value.toInt().toString(),
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: isDarkMode ? AppColors.darkText : AppColors.textPrimary,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (value, meta) => Text(
                                              'Score',
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: isDarkMode ? AppColors.accentDark : AppColors.accentLight,
                                              ),
                                            ),
                                          ),
                                        ),
                                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      ),
                                      gridData: const FlGridData(show: false),
                                      borderData: FlBorderData(show: false),
                                      barTouchData: BarTouchData(
                                        touchTooltipData: BarTouchTooltipData(
                                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                            return BarTooltipItem(
                                              '${rod.toY.toInt()}',
                                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSizes.padding),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Completed: ${report.completedTasks}',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppColors.success,
                                      ),
                                    ),
                                    Text(
                                      'Pending: ${report.pendingTasks}',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppColors.error,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String label, String value, bool isDarkMode) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: isDarkMode ? AppColors.accentDark : AppColors.accentLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isDarkMode ? AppColors.darkText : AppColors.textPrimary,
          ),
        ),
      ],
    ).animate().scale(
      begin: const Offset(0.9, 0.9),
      end: const Offset(1.0, 1.0),
      duration: Duration(milliseconds: AppSizes.buttonAnimationDuration),
      curve: Curves.bounceOut,
    );
  }
}