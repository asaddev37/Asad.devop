import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/supabase_config.dart';
import 'config/theme_data.dart';
import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';
import 'screens/admin_dashboard/admin_dashboard.dart';
import 'screens/student_dashboard.dart';
import 'screens/hod_dashboard.dart';
import 'screens/batch_advisor_dashboard.dart';
import 'screens/home_screen.dart';
import 'screens/loading_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(); // Make sure to load .env file
    await SupabaseConfig.initialize();
    runApp(const MyApp());
  } catch (e) {
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(child: Text('Initialization Error: $e')),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Complaint System',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/loading',
      routes: {
        '/loading': (context) => const LoadingScreen(),
        '/home': (context) => const HomeScreen(),
        '/signup': (context) => const SignupScreen(),
        '/login': (context) => const LoginScreen(),
        '/admin_dashboard': (context) => const AdminDashboard(),
        '/student_dashboard': (context) => const StudentDashboard(),
        '/hod_dashboard': (context) => const HODDashboard(),
        '/batch_advisor_dashboard': (context) => const BatchAdvisorDashboard(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
              child: Text('Route ${settings.name} not found'),
            ),
          ),
        );
      },
    );
  }
}
