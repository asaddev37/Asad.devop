import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../main.dart';
import 'home.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> with SingleTickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  late ConfettiController _confettiController;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  Timer? _navigationTimer;
  bool _isNavigating = false;
  String _mathFact = '';
  final List<String> _mathFacts = [
    'Did you know? 2 + 3 = 5! 🌟',
    'Fun fact: 5 × 4 = 20! 🎉',
    'Guess what? 8 - 2 = 6! 🚀',
    'Cool math: 12 ÷ 3 = 4! 😎',
    'Wow! 6 × 5 = 30! 🌈',
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
    _initializeAudioPlayer();
    _startMathFactCycle();
    _startLoading();
  }
  Future<void> _initializeAudioPlayer() async {
    try {
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.setAsset('assets/sounds/welcome3.mp3');
      await _audioPlayer.play();
      debugPrint('🔊 Playing welcome sound in Loading');
    } catch (e) {
      debugPrint('❌ Error playing welcome sound in Loading: $e');
    }
  }

  Future<void> _playClickSound() async {
    try {
      await _audioPlayer.setAsset('assets/sounds/cliick.wav');
      await _audioPlayer.play();
      debugPrint('🔊 Playing click sound in Loading');
    } catch (e) {
      debugPrint('❌ Error playing click sound in Loading: $e');
    }
  }

  void _startMathFactCycle() {
    setState(() {
      _mathFact = _mathFacts[Random().nextInt(_mathFacts.length)];
    });
    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && !_isNavigating) {
        setState(() {
          _mathFact = _mathFacts[Random().nextInt(_mathFacts.length)];
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _startLoading() {
    _progressController.forward();
    _navigationTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && !_isNavigating) {
        _isNavigating = true;
        _confettiController.play();
        _playClickSound();
        debugPrint('➡️ Navigating to /home from Loading');
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 800),
            pageBuilder: (context, animation, secondaryAnimation) => const Home(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      }
    });
  }

  void _skipLoading() {
    if (!_isNavigating) {
      _isNavigating = true;
      _navigationTimer?.cancel();
      _confettiController.play();
      _playClickSound();
      debugPrint('⏭️ Skip button pressed, navigating to /home from Loading');
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (context, animation, secondaryAnimation) => const Home(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _progressController.dispose();
    _confettiController.dispose();
    _audioPlayer.dispose();
    debugPrint('🗑️ Disposed resources in Loading');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [Colors.purple.shade800, Colors.cyan.shade900]
                    : [Colors.cyan.shade300, Colors.pink.shade300],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDarkMode ? Colors.cyanAccent : Colors.white,
                        width: 5.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode ? Colors.cyanAccent.withAlpha(128) : Colors.white.withAlpha(128),
                          blurRadius: 15,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'images/math_champ.png',
                        width: 220,
                        height: 220,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('❌ Error loading math_champ.png: $error');
                          return Container(
                            color: Colors.grey,
                            child: const Icon(Icons.error, color: Colors.white, size: 100),
                          );
                        },
                      ),
                    ),
                  ).animate().scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.0, 1.0),
                    duration: 800.ms,
                    curve: Curves.bounceOut,
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Math Champ 🌟",
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                      fontFamily: 'Comic Sans MS',
                      shadows: const [
                        Shadow(blurRadius: 10.0, color: Colors.black45, offset: Offset(2.0, 2.0)),
                      ],
                    ),
                  ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.5, end: 0.0),
                  const SizedBox(height: 20),
                  Text(
                    "Master Mathematics with Fun! 🎉",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      fontFamily: 'Comic Sans MS',
                    ),
                  ).animate().fadeIn(duration: 800.ms, delay: 200.ms).slideY(begin: 0.5, end: 0.0),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 5,
                    color: isDarkMode ? Colors.grey.shade800.withAlpha(204) : Colors.white.withAlpha(230),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Text(
                        _mathFact,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                          fontFamily: 'Comic Sans MS',
                          shadows: [
                            Shadow(
                              blurRadius: 12.0,
                              color: isDarkMode ? Colors.cyanAccent.withAlpha(128) : Colors.black54,
                              offset: const Offset(2.0, 2.0),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ).animate().fadeIn(duration: 600.ms).scale(
                    begin: const Offset(0.95, 0.95),
                    end: const Offset(1.0, 1.0),
                    duration: 600.ms,
                    curve: Curves.easeInOut,
                  ),
                  const SizedBox(height: 30),
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 200,
                        height: 10,
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Stack(
                          children: [
                            Container(
                              width: 200 * _progressAnimation.value,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isDarkMode
                                      ? [Colors.cyanAccent, Colors.purpleAccent]
                                      : [themeProvider.lightPrimaryColor, themeProvider.lightSecondaryColor],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ).animate().fadeIn(duration: 800.ms, delay: 400.ms),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _skipLoading,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode ? Colors.cyanAccent : themeProvider.lightPrimaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 5,
                    ),
                    child: Text(
                      'Skip to Fun! 🚀',
                      style: TextStyle(
                        fontSize: 18,
                        color: isDarkMode ? Colors.black87 : Colors.white,
                        fontFamily: 'Comic Sans MS',
                      ),
                    ),
                  ).animate().fadeIn(duration: 800.ms, delay: 600.ms).scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1.0, 1.0),
                    curve: Curves.bounceOut,
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 30,
              gravity: 0.05,
              shouldLoop: false,
              colors: const [
                Colors.cyan,
                Colors.pink,
                Colors.yellow,
                Colors.purple,
                Colors.green,
              ],
            ),
          ),
        ],
      ),
    );
  }
}