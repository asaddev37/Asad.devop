import 'package:flutter/material.dart';
import 'package:math_champ/home/table_multiplication/learn_table.dart';
import 'package:math_champ/home/table_multiplication/practice_table.dart';
import 'package:math_champ/home/table_multiplication/quiz_table.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '/main.dart';

class TableMultiplication extends StatefulWidget {
  const TableMultiplication({super.key});

  @override
  _TableMultiplicationState createState() => _TableMultiplicationState();
}

class _TableMultiplicationState extends State<TableMultiplication> {
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initializeAudioPlayer();
  }

  Future<void> _initializeAudioPlayer() async {
    try {
      await _audioPlayer.setVolume(1.0);
      debugPrint('🔊 AudioPlayer initialized in TableMultiplication');
    } catch (e) {
      debugPrint('❌ AudioPlayer initialization error in TableMultiplication: $e');
    }
  }

  Future<void> _playSound(String assetPath) async {
    try {
      await _audioPlayer.setAsset(assetPath);
      await _audioPlayer.play();
      debugPrint('🔊 Playing sound: $assetPath');
    } catch (e) {
      debugPrint('❌ Error playing sound $assetPath: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    debugPrint('🗑️ Disposed AudioPlayer in TableMultiplication');
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    await _playSound('assets/sounds/cliick.wav');
    Navigator.pop(context, {'showGame': true, 'module': 'table_multiplication'});
    return false;
  }

  Widget _buildTaskCard(
      BuildContext context, {
        required String title,
        IconData? icon,
        required Color iconColor,
        required List<Color> gradientColors,
        required VoidCallback onTap,
      }) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return GestureDetector(
      onTap: () {
        _playSound('assets/sounds/cliick.wav');
        onTap();
      },
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          height: 150,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isDarkMode ? Colors.cyanAccent.withAlpha(77) : Colors.black.withAlpha(51),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 50,
                color: iconColor,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Comic Sans MS',
                  shadows: [
                    Shadow(
                      blurRadius: 5.0,
                      color: Colors.black45,
                      offset: Offset(1.0, 1.0),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ).animate().scale(
      begin: const Offset(0.9, 0.9),
      end: const Offset(1.0, 1.0),
      duration: 600.ms,
      curve: Curves.bounceOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Theme(
        data: isDarkMode
            ? ThemeData.dark().copyWith(
          primaryColor: themeProvider.darkPrimaryColor,
          scaffoldBackgroundColor: Colors.grey[900],
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: Colors.white70, fontFamily: 'Comic Sans MS'),
            titleLarge: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Comic Sans MS',
            ),
          ),
        )
            : ThemeData.light().copyWith(
          primaryColor: themeProvider.lightPrimaryColor,
          scaffoldBackgroundColor: Colors.white,
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: Colors.black87, fontFamily: 'Comic Sans MS'),
            titleLarge: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontFamily: 'Comic Sans MS',
            ),
          ),
        ),
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                _playSound('assets/sounds/cliick.wav');
                Navigator.pop(context, {'showGame': true, 'module': 'table_multiplication'});
              },
            ),
            title: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: isDarkMode
                    ? [Colors.cyanAccent, Colors.purpleAccent]
                    : [themeProvider.lightPrimaryColor, themeProvider.lightSecondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                'Multiplication Tables 🌟',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Comic Sans MS',
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
            centerTitle: true,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDarkMode
                      ? [themeProvider.darkPrimaryColor, themeProvider.darkSecondaryColor]
                      : [themeProvider.lightPrimaryColor, themeProvider.lightSecondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [themeProvider.darkPrimaryColor, themeProvider.darkSecondaryColor]
                    : [
                  themeProvider.lightPrimaryColor.withAlpha(51),
                  themeProvider.lightSecondaryColor.withAlpha(51)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        color: isDarkMode ? Colors.grey.shade800 : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Text(
                                "Welcome to Multplication_Table! 🎉",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.cyanAccent : themeProvider.lightPrimaryColor,
                                  fontFamily: 'Comic Sans MS',
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Master multiplication tables with fun activities! Choose to learn, practice, or test your skills with a quiz. Let's become a multiplication superstar! 🌟",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: isDarkMode ? Colors.white70 : Colors.black87,
                                  height: 1.5,
                                  fontFamily: 'Comic Sans MS',
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                  ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.5, end: 0.0),
                  const SizedBox(height: 20),
                      // First row with two buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: _buildTaskCard(
                              context,
                              title: 'Learn Table',
                              icon: Icons.book,
                              iconColor: isDarkMode ? Colors.yellow : Colors.white,
                              gradientColors: isDarkMode
                                  ? [Colors.blue.shade700, Colors.purple.shade700]
                                  : [Colors.blue.shade400, Colors.cyan.shade400],
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    transitionDuration: const Duration(milliseconds: 800),
                                    pageBuilder: (context, animation, secondaryAnimation) => const LearnTable(),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      const begin = Offset(1.0, 0.0);
                                      const end = Offset.zero;
                                      const curve = Curves.easeInOut;
                                      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                      var offsetAnimation = animation.drive(tween);
                                      return SlideTransition(position: offsetAnimation, child: child);
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTaskCard(
                              context,
                              title: 'Practice Table',
                              icon: Icons.lightbulb_rounded,
                              iconColor: isDarkMode ? Colors.yellow : Colors.greenAccent,
                              gradientColors: isDarkMode
                                  ? [Colors.green.shade700, Colors.teal.shade700]
                                  : [Colors.green.shade400, Colors.teal.shade400],
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    transitionDuration: const Duration(milliseconds: 800),
                                    pageBuilder: (context, animation, secondaryAnimation) => const PracticeTable(),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      const begin = Offset(1.0, 0.0);
                                      const end = Offset.zero;
                                      const curve = Curves.easeInOut;
                                      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                      var offsetAnimation = animation.drive(tween);
                                      return SlideTransition(position: offsetAnimation, child: child);
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Second row with one centered button
                      Row(
                        children: [
                          // This Expanded with Container creates equal spacing on both sides
                          Expanded(
                            child: Container(),
                          ),
                          // The actual button card with fixed width
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 2 - 24, // Half width minus padding
                            child: _buildTaskCard(
                              context,
                              title: 'Quiz Table',
                              icon: Icons.star,
                              iconColor: isDarkMode ? Colors.yellow : Colors.amber,
                              gradientColors: isDarkMode
                                  ? [Colors.orange.shade700, Colors.red.shade700]
                                  : [Colors.orange.shade400, Colors.red.shade400],
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    transitionDuration: const Duration(milliseconds: 800),
                                    pageBuilder: (context, animation, secondaryAnimation) => const QuizTable(),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      const begin = Offset(1.0, 0.0);
                                      const end = Offset.zero;
                                      const curve = Curves.easeInOut;
                                      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                      var offsetAnimation = animation.drive(tween);
                                      return SlideTransition(position: offsetAnimation, child: child);
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                          // This Expanded with Container creates equal spacing on both sides
                          Expanded(
                            child: Container(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}