import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_tracker_shared/task_tracker_shared.dart';
import 'screens/id_entry_screen.dart';
import 'providers/student_provider.dart'; // <-- Import this

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService().initialize(); // Loads .env and initializes Supabase

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()), // <-- Add this
      ],
      child: const TaskStudentApp(),
    ),
  );
}

class TaskStudentApp extends StatelessWidget {
  const TaskStudentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppStrings.studentAppName,
      theme: Provider.of<ThemeProvider>(context).theme,
      home: const IdEntryScreen(),
    );
  }
}
