import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:task_tracker_shared/task_tracker_shared.dart';
import 'package:provider/provider.dart';
import 'admin_login_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with TickerProviderStateMixin {
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeSupabase();
  }

  Future<void> _initializeSupabase() async {
    try {
      await SupabaseService().initialize();
      // Ensure minimum 3-second display for polish
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        _navigateToLogin();
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Initialization failed: ${e.toString()} 😔';
      });
      _showErrorOverlay(_errorMessage);
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const AdminLoginScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  void _showErrorOverlay(String message) {
    final isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    OverlayEntry? overlayEntry;
    final animationController = AnimationController(
      vsync: this,
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
                    const SizedBox(height: AppSizes.padding),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _hasError = false;
                          _errorMessage = '';
                        });
                        overlayEntry?.remove();
                        _initializeSupabase(); // Retry initialization
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
                          'Retry 🚀',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
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

    // Keep overlay until retry is tapped
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
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
        child: Center(
          child: Card(
            elevation: AppSizes.cardElevation,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            ),
            color: isDarkMode ? AppColors.darkCard : AppColors.card,
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.padding * 3),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${AppStrings.adminAppName} Portal 🔐',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: isDarkMode ? AppColors.accentDark : AppColors.accentLight,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: isDarkMode ? AppColors.shadowDark : AppColors.shadowLight,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(duration: Duration(milliseconds: AppSizes.cardAnimationDuration))
                      .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.0, 1.0),
                    duration: Duration(milliseconds: AppSizes.fieldAnimationDuration),
                    curve: Curves.bounceOut,
                  )
                      .rotate(
                    begin: -0.1,
                    end: 0.0,
                    duration: Duration(milliseconds: AppSizes.fieldAnimationDuration),
                  ),
                  const SizedBox(height: AppSizes.padding * 2),
                  Text(
                    'Loading your admin dashboard... 🌟',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDarkMode ? AppColors.darkText : AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(duration: Duration(milliseconds: AppSizes.cardAnimationDuration)),
                  const SizedBox(height: AppSizes.padding * 3),
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDarkMode ? AppColors.accentDark : AppColors.accentLight,
                    ),
                  ).animate().scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1.1, 1.1),
                    duration: Duration(milliseconds: AppSizes.buttonAnimationDuration),
                    curve: Curves.easeInOut,
                  ),
                ],
              ),
            ),
          ),
        ),
      ).animate().fadeIn(duration: Duration(milliseconds: AppSizes.cardAnimationDuration)),
    );
  }
}