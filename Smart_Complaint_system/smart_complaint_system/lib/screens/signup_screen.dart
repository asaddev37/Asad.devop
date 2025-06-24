import 'package:flutter/material.dart';
import '../services/email_service.dart';
import '../services/supabase_service.dart';
import '../utils/validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_card.dart';
import '../config/admin_theme.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() => _isDarkMode = !_isDarkMode);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _checkAdminExists() async {
    if (!mounted) return;
    try {
      final adminExists = await SupabaseService.checkAdminExists();
      if (!mounted) return;
      if (adminExists) {
        setState(() => _errorMessage = 'Sorry admin already created.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking admin: ${e.toString()}')),
      );
    }
  }

  Future<void> _signup() async {
    if (!mounted) return;
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'Passwords do not match');
      return;
    }

    if (!Validators.validateForm(
      context,
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      role: 'admin',
    )) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check if email is already registered
      final emailExists =
          await SupabaseService.isEmailRegistered(_emailController.text.trim());
      if (emailExists) {
        throw Exception(
            'A user with this email address already exists. Please use a different email.');
      }

      final adminExists = await SupabaseService.checkAdminExists();
      if (adminExists) {
        throw Exception('Sorry admin already created.');
      }

      // Create the user first
      final userId = await SupabaseService.addUser(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        role: 'admin',
      );

      if (!mounted) return;

      // Try to send email, but don't block signup if it fails
      try {
        await EmailService.sendCredentials(
          context: context,
          toEmail: _emailController.text,
          name: _nameController.text,
          role: 'Admin',
          username: _emailController.text,
          password: _passwordController.text,
          isDarkMode: Theme.of(context).brightness == Brightness.dark,
        );
      } catch (emailError) {
        print('Failed to send email: $emailError');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Account created successfully, but failed to send email. Please note down your credentials.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 5),
          ),
        );
      }

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Account created successfully! Please proceed to login.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // Navigate to login screen
      _navigateToLogin(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const LoginScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(-1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end)
            .chain(CurveTween(curve: Curves.easeInOut));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    ));
  }

  @override
  void initState() {
    super.initState();
    _checkAdminExists();
  }

  @override
  Widget build(BuildContext context) {
    final theme = _isDarkMode ? AdminTheme.darkTheme : AdminTheme.lightTheme;
    final bool adminExists = _errorMessage == 'Sorry admin already created.';
    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Sign Up'),
          actions: [
            IconButton(
              icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
              tooltip: 'Toggle Theme',
              onPressed: _toggleTheme,
            ),
          ],
          elevation: 0,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: adminExists
                ? Container(
                    width: 370,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_outline,
                            size: 48, color: Colors.redAccent),
                        const SizedBox(height: 24),
                        Text(
                          'Sorry admin already created.',
                          style: theme.textTheme.titleLarge
                              ?.copyWith(color: Colors.redAccent),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Please contact your administrator for access.',
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 40,),
                        CustomButton(
                          text: 'Back to Login',
                          onPressed: () => _navigateToLogin(context),
                          width: double.infinity,
                          borderRadius: 16,
                          padding: const EdgeInsets.all(6),
                        ),
                      ],
                    ),
                  )
                : Container(
                    width: 370,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Create Admin Account',
                          style: theme.textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Confirm Password',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_errorMessage != null && !adminExists)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        CustomButton(
                          text: 'Sign Up',
                          onPressed: _isLoading ? null : _signup,
                          isLoading: _isLoading,
                          width: double.infinity,
                          borderRadius: 16,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Already have an account?'),
                            TextButton(
                              onPressed: () {
                                _navigateToLogin(context);
                              },
                              child: const Text('Login'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
