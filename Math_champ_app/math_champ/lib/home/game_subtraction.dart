import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '/main.dart';

class SubtractionBalloonPopGameModal extends StatefulWidget {
  const SubtractionBalloonPopGameModal({super.key});

  @override
  _SubtractionBalloonPopGameModalState createState() => _SubtractionBalloonPopGameModalState();
}

class _SubtractionBalloonPopGameModalState extends State<SubtractionBalloonPopGameModal> with SingleTickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  late ConfettiController _confettiController;
  int _score = 0;
  int _correctPops = 0;
  final int _maxCorrectPops = 5;
  Map<String, dynamic>? _currentQuestion;
  List<Map<String, dynamic>> _balloons = [];
  bool _gameOver = false;
  final Random _random = Random();
  final List<String> _questionHistory = []; // Track questions to avoid redundancy
  final List<String> _soundQueue = []; // Queue for sound playback
  bool _isPlayingSound = false; // Flag to prevent concurrent playback
  bool _isDisposing = false; // Flag to block sound queue during disposal
  bool _isMounted = false; // Flag to track widget mounting

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _audioPlayer = AudioPlayer();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _initializeAudioPlayer();
    _generateQuestionAndBalloons();
    _playSound('assets/sounds/submit.wav');
    _startBalloonAnimation();
  }

  Future<void> _initializeAudioPlayer() async {
    try {
      await _audioPlayer.setVolume(1.0);
      debugPrint('🔊 AudioPlayer initialized in SubtractionBalloonPopGameModal');
    } catch (e) {
      debugPrint('❌ AudioPlayer initialization error in SubtractionBalloonPopGameModal: $e');
    }
  }

  Future<void> _playSound(String assetPath) async {
    if (_isMounted && !_isDisposing) {
      _soundQueue.add(assetPath);
      if (!_isPlayingSound) {
        _playNextSound();
      }
    }
  }

  Future<void> _playNextSound() async {
    if (_soundQueue.isEmpty || !_isMounted || _isDisposing) return;

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
      if (_soundQueue.isNotEmpty && _isMounted && !_isDisposing) {
        _playNextSound(); // Play next sound in queue
      }
    }
  }

  void _generateQuestionAndBalloons() {
    if (!_isMounted) return;
    int minuend, subtrahend, correctAnswer;
    String questionText;

    // Generate unique question
    do {
      minuend = _random.nextInt(10) + 1; // 1 to 10
      subtrahend = _random.nextInt(minuend) + 1; // 1 to minuend
      correctAnswer = minuend - subtrahend;
      questionText = '$minuend - $subtrahend = ?';
    } while (_questionHistory.contains(questionText) && _questionHistory.length < 100);

    _questionHistory.add(questionText);
    if (_questionHistory.length > 100) _questionHistory.removeAt(0); // Limit history size

    setState(() {
      _currentQuestion = {
        'question': questionText,
        'answer': correctAnswer,
      };
      _balloons = [
        {'answer': correctAnswer, 'color': Colors.red, 'xPosition': 0.2, 'yPosition': 0.8},
        {'answer': correctAnswer + _random.nextInt(3) + 1, 'color': Colors.blue, 'xPosition': 0.5, 'yPosition': 0.8},
        {'answer': correctAnswer - _random.nextInt(3) - 1, 'color': Colors.yellow, 'xPosition': 0.8, 'yPosition': 0.8},
      ]..shuffle();
    });
  }

  void _startBalloonAnimation() {
    if (_gameOver || !_isMounted) return;
    setState(() {
      for (var balloon in _balloons) {
        balloon['yPosition'] -= 0.005; // Slow upward drift
        if (balloon['yPosition'] < 0.2) {
          balloon['yPosition'] = 0.2; // Stop at top
        }
      }
    });
    Future.delayed(const Duration(milliseconds: 50), _startBalloonAnimation);
  }

  void _popBalloon(int answer) {
    if (_gameOver || _currentQuestion == null || !_isMounted) return;
    _playSound('assets/sounds/clii.wav');
    if (answer == _currentQuestion!['answer']) {
      setState(() {
        _score += 10;
        _correctPops++;
        _confettiController.play();
        _playSound('assets/sounds/correct.wav');
      });
      if (_correctPops >= _maxCorrectPops) {
        _endGame();
      } else {
        setState(() {
          _generateQuestionAndBalloons();
        });
      }
    }
  }

  void _endGame() {
    if (!_isMounted) return;
    _playSound('assets/sounds/submit.wav');
    _confettiController.play();
    setState(() {
      _gameOver = true;
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        final isDarkMode = themeProvider.isDarkMode;
        return Stack(
          alignment: Alignment.center,
          children: [
            AlertDialog(
              backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                "Awesome Job! 🎉",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.cyanAccent : themeProvider.lightPrimaryColor,
                  fontFamily: 'Comic Sans MS',
                ),
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "You popped $_score points worth of balloons! 🌟",
                    style: TextStyle(
                      fontSize: 18,
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                      fontFamily: 'Comic Sans MS',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "You're a subtraction hero! 🚀",
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                      fontFamily: 'Comic Sans MS',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _playSound('assets/sounds/cliick.wav');
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDarkMode
                            ? [Colors.greenAccent, Colors.yellowAccent]
                            : [Colors.green.shade300, Colors.yellow.shade300],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "Back to Home! 🌟",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Comic Sans MS',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.05,
              shouldLoop: false,
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _isDisposing = true; // Block sound queue
    _isMounted = false; // Stop animations
    _soundQueue.clear(); // Clear sound queue
    _audioPlayer.stop().then((_) {
      _audioPlayer.dispose(); // Dispose after stopping
      debugPrint('🗑️ Disposed AudioPlayer in SubtractionBalloonPopGameModal');
    }).catchError((e) {
      debugPrint('❌ Error disposing AudioPlayer: $e');
    });
    _confettiController.dispose();
    debugPrint('🗑️ Disposed ConfettiController in SubtractionBalloonPopGameModal');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('images/sky_background.jpg'),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          "Subtraction Balloon Pop! 🎈",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.cyanAccent : themeProvider.lightPrimaryColor,
                            fontFamily: 'Comic Sans MS',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        if (_currentQuestion != null)
                          Text(
                            _currentQuestion!['question'],
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              foreground: Paint()
                                ..shader = LinearGradient(
                                  colors: isDarkMode
                                      ? [Colors.blue, Colors.blue]
                                      : [Colors.red, Colors.pink],
                                ).createShader(const Rect.fromLTWH(0, 0, 150, 30)),
                              fontFamily: 'Comic Sans MS',
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    height: 350,
                    width: double.infinity,
                    child: Stack(
                      children: _balloons.map((balloon) {
                        return Positioned(
                          left: balloon['xPosition'] * MediaQuery.of(context).size.width,
                          top: balloon['yPosition'] * 350,
                          child: GestureDetector(
                            onTap: () => _popBalloon(balloon['answer']),
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: balloon['color'].withOpacity(0.9),
                                boxShadow: [
                                  BoxShadow(
                                    color: balloon['color'].withOpacity(0.5),
                                    blurRadius: 10,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  "${balloon['answer']}",
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'Comic Sans MS',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ).animate().scale(
                          begin: const Offset(0.9, 0.9),
                          end: const Offset(1.0, 1.0),
                          duration: 600.ms,
                          curve: Curves.bounceOut,
                        ).rotate(
                          begin: -0.05,
                          end: 0.05,
                          duration: 2000.ms,
                          curve: Curves.easeInOut,
                          alignment: Alignment.center,
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Score: $_score",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                      fontFamily: 'Comic Sans MS',
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            particleDrag: 0.05,
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            gravity: 0.05,
            shouldLoop: false,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.5, end: 0.0);
  }
}