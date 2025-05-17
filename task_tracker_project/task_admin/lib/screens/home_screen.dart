import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:task_tracker_shared/task_tracker_shared.dart';
import '../providers/admin_provider.dart';
import 'student_management_screen.dart';
import 'task_management_screen.dart';
import 'reports_screen.dart';
import 'leaderboard_screen.dart';
import 'export_screen.dart';
import 'settings_screen.dart';
import 'admin_login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showErrorOverlay(BuildContext context, String message) {
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
                    colors: [
                      AppColors.error,
                      AppColors.error.withOpacity(0.7),
                    ],
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

    Future.delayed(const Duration(seconds: 2), () {
      if (overlayEntry != null && overlayEntry.mounted) {
        animationController.reverse().then((_) {
          overlayEntry?.remove();
          animationController.dispose();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final adminProvider = Provider.of<AdminProvider>(context);
    // Assume AdminProvider has a userName; fallback to 'Admin' if unavailable
    final userName = adminProvider.adminUser ?? 'Admin';

    return Scaffold(
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
          '${AppStrings.adminAppName} Dashboard 🌟',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            shadows: const [
              Shadow(blurRadius: 10.0, color: Colors.black45, offset: Offset(2.0, 2.0)),
            ],
          ),
        ).animate().fadeIn(duration: Duration(milliseconds: AppSizes.cardAnimationDuration)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () async {
              try {
                await Provider.of<AdminProvider>(context, listen: false).logout();
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
              } catch (e) {
                _showErrorOverlay(context, 'Logout failed: ${e.toString()} 😔');
              }
            },
          ),
        ],
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
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.padding * 2),
          child: Column(
            children: [
              Text(
                'Welcome, $userName! 🔐',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: isDarkMode ? AppColors.accentDark : AppColors.accentLight,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: Duration(milliseconds: AppSizes.cardAnimationDuration)),
              const SizedBox(height: AppSizes.padding),
              Text(
                'Manage your tasks and students with ease.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDarkMode ? AppColors.darkText : AppColors.textPrimary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: Duration(milliseconds: AppSizes.cardAnimationDuration)),
              const SizedBox(height: AppSizes.padding * 2),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSizes.padding,
                  mainAxisSpacing: AppSizes.padding,
                  children: [
                    _buildCard(context, 'Manage Students', Icons.people, const StudentManagementScreen()),
                    _buildCard(context, 'Manage Tasks', Icons.task, const TaskManagementScreen()),
                    _buildCard(context, 'Reports', Icons.bar_chart, const ReportsScreen()),
                    _buildCard(context, 'Leaderboard', Icons.star, const LeaderboardScreen()),
                    _buildCard(context, 'Export Data', Icons.file_download, const ExportScreen()),
                    _buildCard(context, 'Settings', Icons.settings, const SettingsScreen()),
                  ].asMap().entries.map((entry) {
                    final index = entry.key;
                    final widget = entry.value;
                    return widget.animate(
                      delay: Duration(milliseconds: index * 100),
                    ).fadeIn(
                      duration: Duration(milliseconds: AppSizes.fieldAnimationDuration),
                    ).slideY(
                      begin: 0.5,
                      end: 0.0,
                      duration: Duration(milliseconds: AppSizes.fieldAnimationDuration),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, IconData icon, Widget destination) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Card(
      elevation: AppSizes.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      color: isDarkMode ? AppColors.darkCard : AppColors.card,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => destination,
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode
                  ? [AppColors.gradientDarkStart.withOpacity(0.3), AppColors.gradientDarkEnd.withOpacity(0.3)]
                  : [AppColors.gradientLightStart.withOpacity(0.3), AppColors.gradientLightEnd.withOpacity(0.3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: isDarkMode ? AppColors.accentDark : AppColors.accentLight,
              ).animate(
                onPlay: (controller) => controller.repeat(reverse: true),
              ).scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1.1, 1.1),
                duration: Duration(milliseconds: AppSizes.buttonAnimationDuration),
                curve: Curves.easeInOut,
              ),
              const SizedBox(height: AppSizes.padding),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: isDarkMode ? AppColors.darkText : AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}