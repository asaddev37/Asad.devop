import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/main.dart';

class StarCollectorGame extends StatefulWidget {
  final int score;

  const StarCollectorGame({super.key, required this.score});

  @override
  _StarCollectorGameState createState() => _StarCollectorGameState();
}

class _StarCollectorGameState extends State<StarCollectorGame> with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AudioPlayer _audioPlayer;
  int _starsCollected = 0;
  int _starsToCollect = 3;
  List<Offset> _starPositions = [];
  bool _isGameOver = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _audioPlayer = AudioPlayer();
    _initializeAudioPlayer();
    _setStarsToCollect();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _generateStarPositions();
      _initialized = true;
    }
  }

  Future<void> _initializeAudioPlayer() async {
    try {
      await _audioPlayer.setVolume(1.0);
      debugPrint('🔊 AudioPlayer initialized in StarCollectorGame');
    } catch (e) {
      debugPrint('❌ AudioPlayer initialization error in StarCollectorGame: $e');
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

  void _setStarsToCollect() {
    if (widget.score <= 0) {
      _starsToCollect = 3;
    } else if (widget.score < 50) {
      _starsToCollect = 3;
    } else if (widget.score <= 75) {
      _starsToCollect = 5;
    } else {
      _starsToCollect = 7;
    }
    debugPrint('🌟 Stars to collect: $_starsToCollect based on score: ${widget.score}');
  }

  void _generateStarPositions() {
    final random = Random();
    final size = MediaQuery.of(context).size;
    _starPositions = List.generate(_starsToCollect, (index) {
      return Offset(
        50.0 + random.nextDouble() * (size.width - 100),
        100.0 + random.nextDouble() * (size.height - 300),
      );
    });
  }

  void _collectStar(int index) {
    if (_isGameOver) return;
    setState(() {
      _playSound('assets/sounds/cliick.wav');
      _starsCollected++;
      _starPositions[index] = const Offset(-100, -100);
      if (_starsCollected >= _starsToCollect) {
        _isGameOver = true;
        _confettiController.play();
        _saveStars();
      }
    });
  }

  Future<void> _saveStars() async {
    final prefs = await SharedPreferences.getInstance();
    int totalStars = prefs.getInt('totalStars') ?? 0;
    totalStars += _starsCollected;
    await prefs.setInt('totalStars', totalStars);
    debugPrint('🌟 Saved $totalStars stars to SharedPreferences');
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [themeProvider.darkPrimaryColor, themeProvider.darkSecondaryColor]
                : [themeProvider.lightPrimaryColor, themeProvider.lightSecondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 30,
              gravity: 0.1,
              colors: const [
                Colors.yellow,
                Colors.cyan,
                Colors.pink,
                Colors.green,
                Colors.orange,
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Collect Stars to Save & Exit! 🌟',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Comic Sans MS',
                    color: isDarkMode ? Colors.cyanAccent : themeProvider.lightPrimaryColor,
                    shadows: const [
                      Shadow(blurRadius: 10.0, color: Colors.black45, offset: Offset(2.0, 2.0)),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 800.ms),
                const SizedBox(height: 20),
                Text(
                  'Tap $_starsToCollect stars! ($_starsCollected/$_starsToCollect)',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Comic Sans MS',
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ).animate().fadeIn(duration: 800.ms),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _playSound('assets/sounds/cliick.wav');
                            Navigator.pop(context, false);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 8,
                            backgroundColor: Colors.transparent,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDarkMode
                                    ? [Colors.redAccent, Colors.orangeAccent]
                                    : [Colors.red.shade300, Colors.orange.shade300],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: isDarkMode ? Colors.cyanAccent.withAlpha(102) : Colors.black.withAlpha(51),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: const Text(
                              'Back to Quiz! 🚀',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Comic Sans MS',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ).animate().scale(
                          begin: const Offset(0.8, 0.8),
                          end: const Offset(1.0, 1.0),
                          duration: 600.ms,
                          curve: Curves.bounceOut,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isGameOver
                              ? () {
                            _playSound('assets/sounds/cliick.wav');
                            Navigator.pop(context, true);
                          }
                              : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 8,
                            backgroundColor: Colors.transparent,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _isGameOver
                                    ? (isDarkMode
                                    ? [Colors.greenAccent, Colors.yellowAccent]
                                    : [Colors.green.shade300, Colors.yellow.shade300])
                                    : (isDarkMode
                                    ? [Colors.grey.shade600, Colors.grey.shade800]
                                    : [Colors.grey.shade400, Colors.grey.shade600]),
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: _isGameOver
                                      ? (isDarkMode ? Colors.cyanAccent.withAlpha(102) : Colors.black.withAlpha(51))
                                      : Colors.transparent,
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              _isGameOver ? 'Save & Exit! 🌟' : 'Collect All Stars!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _isGameOver ? Colors.white : Colors.white70,
                                fontFamily: 'Comic Sans MS',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ).animate().scale(
                          begin: const Offset(0.8, 0.8),
                          end: const Offset(1.0, 1.0),
                          duration: 600.ms,
                          curve: Curves.bounceOut,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ..._starPositions.asMap().entries.map((entry) {
              final index = entry.key;
              final position = entry.value;
              if (position.dx < 0) return const SizedBox.shrink();
              return Positioned(
                left: position.dx,
                top: position.dy,
                child: GestureDetector(
                  onTap: () => _collectStar(index),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.yellowAccent,
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode ? Colors.yellowAccent.withAlpha(150) : Colors.yellow.withAlpha(100),
                          blurRadius: 15,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 40,
                    ),
                  ).animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  ).scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1.1, 1.1),
                    duration: 1000.ms,
                    curve: Curves.easeInOut,
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}