import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'package:targets_cgpa/screens/loading.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: "",
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Loading(),
      routes: {
        '/home': (context) => HomeScreen(),

        '/loading':(context) => Loading(),
      },
    );
  }
}

