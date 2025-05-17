import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'package:task_tracker_shared/task_tracker_shared.dart';
import '../providers/admin_provider.dart';
import 'home_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});
  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      _showOverlay(AppStrings.validationError, isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      // Debug log
      print('Attempting login with email: ${_emailController.text.trim()}');
      await adminProvider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      ).timeout(const Duration(seconds: 20)); // Increased timeout
      print('Login successful');
      _showOverlay(AppStrings.loginSuccess, isError: false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on http.ClientException catch (e) {
      print('Network error: $e');
      _showOverlay(AppStrings.networkError, isError: true);
    } on TimeoutException catch (e) {
      print('Timeout error: $e');
      _showOverlay('Request timed out after 20 seconds. Please check server status or try again 😔', isError: true);
    } on http.Response catch (e) {
      print('HTTP error: Status ${e.statusCode}, Body: ${e.body}');
      if (e.statusCode == 401) {
        _showOverlay('Unauthorized: Please check your credentials 😔', isError: true);
      } else if (e.statusCode == 500) {
        _showOverlay('Server error: Please try again later 😔', isError: true);
      } else {
        _showOverlay('HTTP error: ${e.statusCode} 😔', isError: true);
      }
    } catch (e) {
      print('General error: $e');
      String errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('invalid email') || errorMessage.contains('user not found')) {
        _showOverlay(AppStrings.invalidEmailError, isError: true);
      } else if (errorMessage.contains('invalid password') || errorMessage.contains('wrong password')) {
        _showOverlay(AppStrings.invalidPasswordError, isError: true);
      } else {
        _showOverlay(AppStrings.loginError.replaceFirst('%s', e.toString()), isError: true);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showOverlay(String message, {required bool isError}) {
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

    Future.delayed(const Duration(seconds: 2), () {
      if (overlayEntry != null && overlayEntry.mounted) {
        animationController.reverse().then((_) {
          overlayEntry?.remove();
          animationController.dispose();
        });
      }
    });
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDarkMode,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: isDarkMode ? AppColors.accentDark : AppColors.accentLight,
        ),
      ),
    ).animate().fadeIn(
      duration: Duration(milliseconds: AppSizes.fieldAnimationDuration),
    ).slideY(
      begin: 0.5,
      end: 0.0,
      duration: Duration(milliseconds: AppSizes.fieldAnimationDuration),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

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
        ),
        title: Text(
          '${AppStrings.adminAppName} Login 🌟',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            shadows: const [
              Shadow(blurRadius: 10.0, color: Colors.black45, offset: Offset(2.0, 2.0)),
            ],
          ),
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
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.padding * 2,
            vertical: AppSizes.padding * 3,
          ),
          child: Card(
            elevation: AppSizes.cardElevation,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            ),
            color: isDarkMode ? AppColors.darkCard : AppColors.card,
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.padding * 2),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome, Admin! 🔐',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: isDarkMode ? AppColors.accentDark : AppColors.accentLight,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(
                      duration: Duration(milliseconds: AppSizes.cardAnimationDuration),
                    ),
                    const SizedBox(height: AppSizes.padding),
                    Text(
                      'Log in to manage your tasks securely.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(
                      duration: Duration(milliseconds: AppSizes.cardAnimationDuration),
                    ),
                    const SizedBox(height: AppSizes.padding * 3),
                    _buildFormField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'Enter your email',
                      icon: Icons.email,
                      isDarkMode: isDarkMode,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSizes.padding * 2),
                    _buildFormField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: 'Enter your password',
                      icon: Icons.lock,
                      isDarkMode: isDarkMode,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSizes.padding * 4),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                      onPressed: () => _login(context),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDarkMode
                                ? [AppColors.gradientDarkStart, AppColors.gradientDarkEnd]
                                : [AppColors.gradientLightStart, AppColors.gradientLightEnd],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: AppSizes.padding * 1.5),
                        child: Center(
                          child: Text(
                            'Login Now! 🚀',
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
                ),
              ),
            ),
          ).animate().fadeIn(
            duration: Duration(milliseconds: AppSizes.cardAnimationDuration),
          ),
        ),
      ),
    );
  }
}