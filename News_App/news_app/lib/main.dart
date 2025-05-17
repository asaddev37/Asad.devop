import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:news_app/screens/favourite_screen.dart';
import 'package:provider/provider.dart';
import 'constants/colors.dart';
import 'models/news_model.dart';
import 'screens/loading_screen.dart';
import 'screens/home_screen.dart';
import 'screens/news_view_screen.dart';
import 'screens/settings_screen.dart';
import 'services/news_service.dart';
import 'services/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Perform initialization tasks in parallel
  await Future.wait([
    dotenv.load(fileName: ".env"),
    Hive.initFlutter().then((_) async {
      Hive.registerAdapter(NewsModelAdapter());
      await Hive.openBox<NewsModel>('newsBox');
    }),
    DatabaseHelper().initDatabase(),
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NewsService()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AK News',
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.electricBlue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.midnightBlack,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      initialRoute: '/loading',
      routes: {
        '/loading': (context) => const LoadingScreen(),
        '/home': (context) => const HomeScreen(),
        '/news_view': (context) => const NewsViewScreen(url: ''),
        '/favorites': (context) => const FavoritesScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}