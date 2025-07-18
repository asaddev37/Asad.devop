import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:task_tracker_shared/task_tracker_shared.dart';
import 'privacy_policy_screen.dart';
import '../providers/theme_provider.dart';
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

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
          'Settings ⚙️',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.padding * 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
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
                        'Theme 🌙',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: isDarkMode ? AppColors.accentDark : AppColors.accentLight,
                        ),
                      ),
                      const SizedBox(height: AppSizes.padding),
                      SwitchListTile(
                        activeColor: AppColors.success,
                        title: Text(
                          'Dark Mode',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDarkMode ? AppColors.darkText : AppColors.textPrimary,
                          ),
                        ),
                        value: isDarkMode,
                        onChanged: (value) {
                          Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                        },
                      ).animate(
                        onPlay: (controller) => controller.repeat(reverse: true),
                      ).scale(
                        begin: const Offset(0.95, 0.95),
                        end: const Offset(1.0, 1.0),
                        duration: Duration(milliseconds: AppSizes.buttonAnimationDuration),
                        curve: Curves.easeInOut,
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: Duration(milliseconds: AppSizes.cardAnimationDuration)).slideY(
                begin: 0.5,
                end: 0.0,
                duration: Duration(milliseconds: AppSizes.fieldAnimationDuration),
              ),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'App Info ℹ️',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: isDarkMode ? AppColors.accentDark : AppColors.accentLight,
                        ),
                      ),
                      const SizedBox(height: AppSizes.padding),
                      ListTile(
                        title: Text(
                          'Version',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDarkMode ? AppColors.darkText : AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          '1.0.0',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDarkMode ? AppColors.darkText : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: Duration(milliseconds: AppSizes.cardAnimationDuration)).slideY(
                begin: 0.5,
                end: 0.0,
                duration: Duration(milliseconds: AppSizes.fieldAnimationDuration),
              ),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Legal 📜',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: isDarkMode ? AppColors.accentDark : AppColors.accentLight,
                        ),
                      ),
                      const SizedBox(height: AppSizes.padding),
                      ListTile(
                        title: Text(
                          'Privacy Policy',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDarkMode ? AppColors.darkText : AppColors.textPrimary,
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: isDarkMode ? AppColors.accentDark : AppColors.accentLight,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
                          );
                        },
                      ).animate(
                        onPlay: (controller) => controller.repeat(reverse: true),
                      ).scale(
                        begin: const Offset(0.95, 0.95),
                        end: const Offset(1.0, 1.0),
                        duration: Duration(milliseconds: AppSizes.buttonAnimationDuration),
                        curve: Curves.easeInOut,
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: Duration(milliseconds: AppSizes.cardAnimationDuration)).slideY(
                begin: 0.5,
                end: 0.0,
                duration: Duration(milliseconds: AppSizes.fieldAnimationDuration),
              ),
            ],
          ),
        ),
      ),
    );
  }
}