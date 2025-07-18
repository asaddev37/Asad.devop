import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:math_champ/loading.dart';
import 'home.dart';
import 'home/table_multiplication/learn_table.dart';
import 'home/table_multiplication/practice_table.dart';
import 'home/table_multiplication/quiz_table.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Table Quiz',
            theme: ThemeData.light().copyWith(
              primaryColor: themeProvider.lightPrimaryColor,
              scaffoldBackgroundColor: Colors.white,
            ),
            darkTheme: ThemeData.dark().copyWith(
              primaryColor: themeProvider.darkPrimaryColor,
              scaffoldBackgroundColor: Colors.grey[900],
            ),
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const Loading(),
            routes: {
              '/home': (context) => const Home(),
              '/loading': (context) => const Loading(),
              '/assignments': (context) => const PracticeTable(),
              '/quiz': (context) => const QuizTable(),
              '/learn_table': (context) => const LearnTable(),
            },
          );
        },
      ),
    );
  }
}

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = true;
  Color _lightPrimaryColor = Colors.indigo!;
  Color _lightSecondaryColor = Colors.teal!;
  // Color _darkPrimaryColor = Colors.indigo[900]!;
  // Color _darkSecondaryColor = Colors.teal[800]!;
  Color _darkPrimaryColor = Colors.teal[800]!;
  Color _darkSecondaryColor = Colors.orangeAccent!;

  bool get isDarkMode => _isDarkMode;
  Color get lightPrimaryColor => _lightPrimaryColor;
  Color get lightSecondaryColor => _lightSecondaryColor;
  Color get darkPrimaryColor => _darkPrimaryColor;
  Color get darkSecondaryColor => _darkSecondaryColor;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setCustomColors({
    required Color lightPrimary,
    required Color lightSecondary,
    required Color darkPrimary,
    required Color darkSecondary,
  }) {
    _lightPrimaryColor = lightPrimary;
    _lightSecondaryColor = lightSecondary;
    _darkPrimaryColor = darkPrimary;
    _darkSecondaryColor = darkSecondary;
    notifyListeners();
  }
}