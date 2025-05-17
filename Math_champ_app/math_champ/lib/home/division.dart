import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '/main.dart';
import 'division/learn_division.dart';
import 'division/practice_division.dart';
import 'division/quiz_division.dart';

class Division extends StatefulWidget {
  const Division({super.key});

  @override
  _DivisionState createState() => _DivisionState();
}

class _DivisionState extends State<Division> {
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
      debugPrint('🔊 AudioPlayer initialized in Division');
    } catch (e) {
      debugPrint('❌ AudioPlayer initialization error in Division: $e');
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
    debugPrint('🗑️ Disposed AudioPlayer in Division');
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    await _playSound('assets/sounds/cliick.wav');
    Navigator.pop(context, {'showGame': true, 'module': 'division'});
    return false;
  }

  Widget _buildSubmoduleCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    required bool isDarkMode,
    required ThemeProvider themeProvider,
    required List<Color> gradientColors,
    required Color iconColor,
  }) {
    final buttonWidth = (MediaQuery.of(context).size.width - 32 - 12) / 2; // Match home.dart, addition.dart, subtraction.dart
    return SizedBox(
      width: buttonWidth,
      child: GestureDetector(
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
      ),
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
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                _playSound('assets/sounds/cliick.wav');
                Navigator.pop(context, {'showGame': true, 'module': 'division'});
              },
            ),
            title: const Text(
              'Division Adventure! 🌟',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Comic Sans MS',
                shadows: [
                  Shadow(blurRadius: 10.0, color: Colors.black45, offset: Offset(2.0, 2.0)),
                ],
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
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: Column(
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
                              "Welcome to Division! 🎉",
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
                              "Hey, math champs! 🌟 Division is like sharing candies equally among friends. Choose an activity below to learn, practice, or quiz your division skills and become a division superstar! 🚀",
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
                        _buildSubmoduleCard(
                          title: 'Learn Division',
                          icon: Icons.book_rounded,
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                transitionDuration: const Duration(milliseconds: 800),
                                pageBuilder: (context, animation, secondaryAnimation) => const LearnDivision(),
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
                          isDarkMode: isDarkMode,
                          themeProvider: themeProvider,
                          gradientColors: isDarkMode
                              ? [Colors.blue.shade700, Colors.purple.shade700]
                              : [Colors.blue.shade400, Colors.cyan.shade400],
                          iconColor: isDarkMode ? Colors.yellow : Colors.white,
                        ),
                        const SizedBox(width: 12),
                        _buildSubmoduleCard(
                          title: 'Practice Division',
                          icon: Icons.lightbulb_rounded,
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                transitionDuration: const Duration(milliseconds: 800),
                                pageBuilder: (context, animation, secondaryAnimation) => const PracticeDivision(),
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
                          isDarkMode: isDarkMode,
                          themeProvider: themeProvider,
                          gradientColors: isDarkMode
                              ? [Colors.green.shade700, Colors.teal.shade700]
                              : [Colors.green.shade400, Colors.teal.shade400],
                          iconColor: isDarkMode ? Colors.yellow : Colors.greenAccent,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Second row with one centered button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Spacer(),
                        _buildSubmoduleCard(
                          title: 'Quiz Division',
                          icon: Icons.star_rounded,
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                transitionDuration: const Duration(milliseconds: 800),
                                pageBuilder: (context, animation, secondaryAnimation) => const QuizDivision(),
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
                          isDarkMode: isDarkMode,
                          themeProvider: themeProvider,
                          gradientColors: isDarkMode
                              ? [Colors.orange.shade700, Colors.red.shade700]
                              : [Colors.orange.shade400, Colors.red.shade400],
                          iconColor: isDarkMode ? Colors.yellowAccent : Colors.amber,
                        ),
                        Spacer(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}