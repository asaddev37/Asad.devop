import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:task_tracker_shared/models/task.dart' as shared;
import 'package:task_tracker_shared/models/user.dart' as shared;
import 'package:task_tracker_shared/task_tracker_shared.dart';
import '../providers/student_provider.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';
 // Import AppColors and AppSizes

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

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
            'Leaderboard 🏆',
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

              return FutureBuilder<List<Map<String, dynamic>>>(
                future: _buildLeaderboard(studentProvider, taskProvider.tasks),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }
                  final leaderboard = snapshot.data ?? [];
                  if (leaderboard.isEmpty) {
                    return const Center(
                      child: Text(
                        'No leaderboard data 😔',
                        style: TextStyle(fontFamily: 'Comic Sans MS', fontSize: 18),
                      ),
                    ).animate().fadeIn(duration: Duration(milliseconds: AppSizes.fieldAnimationDuration));
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSizes.padding * 2),
                    child: Column(
                      children: [
                        // Podium Card
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
                                  'Top Performers 🏅',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: isDarkMode ? AppColors.accentDark : AppColors.accentLight,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: AppSizes.padding),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildPodiumItem(
                                      context,
                                      leaderboard.length > 1 ? leaderboard[1] : null,
                                      2,
                                      '🥈',
                                      isDarkMode,
                                    ),
                                    _buildPodiumItem(
                                      context,
                                      leaderboard.isNotEmpty ? leaderboard[0] : null,
                                      1,
                                      '🥇',
                                      isDarkMode,
                                    ),
                                    _buildPodiumItem(
                                      context,
                                      leaderboard.length > 2 ? leaderboard[2] : null,
                                      3,
                                      '🥉',
                                      isDarkMode,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSizes.padding),
                                Text(
                                  'Total Students: ${studentProvider.students.length}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: isDarkMode ? AppColors.darkText : AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(duration: Duration(milliseconds: AppSizes.cardAnimationDuration)),
                        const SizedBox(height: AppSizes.padding * 2),
                        // Leaderboard List
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: leaderboard.length,
                          itemBuilder: (context, index) {
                            final entry = leaderboard[index];
                            final student = entry['student'] as shared.User?;
                            final score = entry['score'] as int;
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
                                  leading: Text(
                                    '#${index + 1}',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: isDarkMode ? AppColors.accentDark : AppColors.accentLight,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  title: Text(
                                    student?.name ?? 'Unknown Student',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: isDarkMode ? AppColors.darkText : AppColors.textPrimary,
                                    ),
                                  ),
                                  trailing: Text(
                                    '$score%',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: score < 50
                                          ? AppColors.error
                                          : score > 75
                                          ? AppColors.success
                                          : isDarkMode
                                          ? AppColors.accentDark
                                          : AppColors.accentLight,
                                      fontWeight: FontWeight.bold,
                                    ),
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
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _buildLeaderboard(
      StudentProvider studentProvider,
      List<shared.Task> tasks,
      ) async {
    final analyticsService = AnalyticsService();
    final leaderboard = <Map<String, dynamic>>[];

    for (final student in studentProvider.students) {
      if (student.id == null) {
        leaderboard.add({
          'student': student,
          'score': 0,
        });
        continue;
      }
      final studentTasks = tasks.where((task) => task.assignedTo == student.id).toList();
      final report = analyticsService.calculateReport(studentTasks, student.id!);
      leaderboard.add({
        'student': student,
        'score': report.performanceScore,
      });
    }

    leaderboard.sort((a, b) {
      final scoreA = a['score'] as int;
      final scoreB = b['score'] as int;
      return scoreB.compareTo(scoreA); // Descending order
    });

    return leaderboard;
  }

  Widget _buildPodiumItem(
      BuildContext context,
      Map<String, dynamic>? entry,
      int rank,
      String medal,
      bool isDarkMode,
      ) {
    final student = entry != null ? entry['student'] as shared.User? : null;
    final score = entry != null ? entry['score'] as int : 0;

    return Expanded(
      child: Column(
        children: [
          Text(
            medal,
            style: TextStyle(
              fontSize: rank == 1 ? 40 : 32,
              color: rank == 1
                  ? Colors.yellow[700]
                  : rank == 2
                  ? Colors.grey[400]
                  : Colors.brown,
            ),
          ).animate(
            onPlay: (controller) => controller.repeat(reverse: true),
          ).scale(
            begin: const Offset(0.9, 0.9),
            end: const Offset(1.1, 1.1),
            duration: Duration(milliseconds: AppSizes.buttonAnimationDuration),
            curve: Curves.easeInOut,
          ),
          const SizedBox(height: AppSizes.padding / 2),
          Container(
            height: rank == 1 ? 100 : rank == 2 ? 80 : 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [AppColors.gradientDarkStart, AppColors.gradientDarkEnd]
                    : [AppColors.gradientLightStart, AppColors.gradientLightEnd],
              ),
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            ),
            child: Center(
              child: Text(
                student?.name ?? 'N/A',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.padding / 2),
          Text(
            '$score%',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: score < 50
                  ? AppColors.error
                  : score > 75
                  ? AppColors.success
                  : isDarkMode
                  ? AppColors.accentDark
                  : AppColors.accentLight,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}