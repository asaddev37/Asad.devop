import 'package:flutter/material.dart';
import 'package:math_champ/home/addition/learn_addition.dart';
import 'package:math_champ/home/addition/practice_addition.dart';
import 'package:math_champ/home/addition/quiz_addition.dart';
import 'package:provider/provider.dart' show Provider;
import 'package:just_audio/just_audio.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '/main.dart';

class Addition extends StatefulWidget {
  const Addition({super.key});

  @override
  _AdditionState createState() => _AdditionState();
}

class _AdditionState extends State<Addition> {
  late AudioPlayer _audioPlayer;
  final List<String> _soundQueue = []; // Queue for sound playback
  bool _isPlayingSound = false; // Flag to prevent concurrent playback

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initializeAudioPlayer();
  }

  Future<void> _initializeAudioPlayer() async {
    try {
      await _audioPlayer.setVolume(1.0);
      debugPrint('🔊 AudioPlayer initialized in Addition');
    } catch (e) {
      debugPrint('❌ AudioPlayer initialization error in Addition: $e');
    }
  }

  Future<void> _playSound(String assetPath) async {
    if (mounted) {
      _soundQueue.add(assetPath);
      if (!_isPlayingSound) {
        _playNextSound();
      }
    }
  }

  Future<void> _playNextSound() async {
    if (_soundQueue.isEmpty || !mounted) return;

    _isPlayingSound = true;
    final assetPath = _soundQueue.removeAt(0);

    try {
      await _audioPlayer.stop(); // Stop any currently playing sound
      await _audioPlayer.setAsset(assetPath); // Load new sound
      await _audioPlayer.play(); // Play the sound
      debugPrint('🔊 Playing sound: $assetPath');
    } catch (e) {
      debugPrint('❌ Error playing sound $assetPath: $e');
    } finally {
      _isPlayingSound = false;
      if (_soundQueue.isNotEmpty && mounted) {
        _playNextSound(); // Play next sound in queue
      }
    }
  }

  @override
  void dispose() {
    _soundQueue.clear(); // Clear sound queue
    _audioPlayer.dispose();
    debugPrint('🗑️ Disposed AudioPlayer in Addition');
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    await _playSound('assets/sounds/cliick.wav');
    Navigator.pop(context, {'showGame': true, 'module': 'addition'});
    return false;
  }

  void _navigateTo(Widget page) {
    _playSound('assets/sounds/cliick.wav');
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (_, animation, secondaryAnimation) => page,
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
      ),
    );
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
    final buttonWidth = (MediaQuery.of(context).size.width - 32 - 12) / 2; // Match home.dart, subtraction.dart, division.dart
    return SizedBox(
      width: buttonWidth,
      child: GestureDetector(
        onTap: onTap,
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
    // Calculate button width to match home.dart: (screenWidth - padding - gap) / 2
    final buttonWidth = (MediaQuery.of(context).size.width - 32 - 12) / 2;

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
            title: const Text(
              'Addition Adventure! 🌟',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
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
                              "Welcome to Addition! 🎉",
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
                              "Hey, math superstars! 🌟 Ready to dive into the world of addition? Pick an activity below and let’s make adding numbers a fun adventure! 🚀",
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
                    Row(
                      children: [
                        Flexible(
                          flex: 1,
                          child: SizedBox(
                            width: buttonWidth,
                            child: _buildSubmoduleCard(
                              title: 'Learn Addition',
                              icon: Icons.book,
                              onTap: () => _navigateTo(const LearnAddition()),
                              isDarkMode: isDarkMode,
                              themeProvider: themeProvider,
                              gradientColors: isDarkMode
                                  ? [Colors.orange.shade700, Colors.red.shade700]
                                  : [Colors.orange.shade400, Colors.red.shade400],
                              iconColor: isDarkMode ? Colors.yellowAccent : Colors.amber,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          flex: 1,
                          child: SizedBox(
                            width: buttonWidth,
                            child: _buildSubmoduleCard(
                              title: 'Practice Addition',
                              icon: Icons.lightbulb_rounded,
                              onTap: () => _navigateTo(const PracticeAddition()),
                              isDarkMode: isDarkMode,
                              themeProvider: themeProvider,
                              gradientColors: isDarkMode
                                  ? [Colors.blue.shade700, Colors.purple.shade700]
                                  : [Colors.blue.shade400, Colors.purple.shade400],
                              iconColor: isDarkMode ? Colors.yellow : Colors.blueAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Spacer(),
                        _buildSubmoduleCard(
                          title: 'Quiz Addition',
                          icon: Icons.star,
                          onTap: () => _navigateTo(const QuizAddition()),
                          isDarkMode: isDarkMode,
                          themeProvider: themeProvider,
                          gradientColors: isDarkMode
                              ? [Colors.green.shade700, Colors.teal.shade700]
                              : [Colors.green.shade400, Colors.teal.shade400],
                          iconColor: isDarkMode ? Colors.yellow : Colors.greenAccent,
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