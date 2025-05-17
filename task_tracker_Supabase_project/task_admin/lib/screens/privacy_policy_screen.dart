import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:task_tracker_shared/task_tracker_shared.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          'Privacy Policy 📜',
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
        child: FutureBuilder<String>(
          future: DefaultAssetBundle.of(context)
              .loadString('privacy_policy_task_admin.md'),
          builder: (context, snapshot) {
            Widget content;
            if (snapshot.connectionState == ConnectionState.waiting) {
              content = Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(AppColors.success),
                    ),
                    const SizedBox(height: AppSizes.padding),
                    Text(
                      'Loading policy...',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 18,
                        color: isDarkMode ? AppColors.darkText : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: Duration(milliseconds: AppSizes.fieldAnimationDuration));
            } else if (snapshot.hasError) {
              content = Center(
                child: Text(
                  'Error loading privacy policy 😔\nCheck assets/privacy_policy_task_admin.md',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 18,
                    color: AppColors.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ).animate().fadeIn(duration: Duration(milliseconds: AppSizes.fieldAnimationDuration));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              content = Center(
                child: Text(
                  'No privacy policy available 😔',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 18,
                    color: isDarkMode ? AppColors.darkText : AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ).animate().fadeIn(duration: Duration(milliseconds: AppSizes.fieldAnimationDuration));
            } else {
              content = SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.padding * 2),
                child: Card(
                  elevation: AppSizes.cardElevation,
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
                    padding: const EdgeInsets.all(AppSizes.padding * 2),
                    child: MarkdownBody(
                      data: snapshot.data!,
                      styleSheet: MarkdownStyleSheet(
                        h1: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontFamily: 'Comic Sans MS',
                          color: isDarkMode ? AppColors.accentDark : AppColors.accentLight,
                        ),
                        h2: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontFamily: 'Comic Sans MS',
                          color: isDarkMode ? AppColors.accentDark : AppColors.accentLight,
                        ),
                        p: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontFamily: 'Comic Sans MS',
                          color: isDarkMode ? AppColors.darkText : AppColors.textPrimary,
                        ),
                        listBullet: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontFamily: 'Comic Sans MS',
                          color: isDarkMode ? AppColors.darkText : AppColors.textPrimary,
                        ),
                        strong: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontFamily: 'Comic Sans MS',
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? AppColors.darkText : AppColors.textPrimary,
                        ),
                        a: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontFamily: 'Comic Sans MS',
                          color: isDarkMode ? AppColors.accentDark : AppColors.accentLight,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: Duration(milliseconds: AppSizes.cardAnimationDuration)).slideY(
                begin: 0.5,
                end: 0.0,
                duration: Duration(milliseconds: AppSizes.fieldAnimationDuration),
              );
            }
            return content;
          },
        ),
      ),
    );
  }
}