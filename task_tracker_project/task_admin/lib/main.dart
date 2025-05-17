import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_tracker_shared/task_tracker_shared.dart';
import 'providers/admin_provider.dart';
import 'screens/loading_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: const TaskAdminApp(),
    ),
  );
}

class TaskAdminApp extends StatelessWidget {
  const TaskAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppStrings.adminAppName,
      theme: Provider.of<ThemeProvider>(context).theme,
      home: const LoadingScreen(), // Start with loading screen
    );
  }
}