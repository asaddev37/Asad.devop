import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '/main.dart';

class DivisionBalloonPopGameModal extends StatefulWidget {
  const DivisionBalloonPopGameModal({super.key});

  @override
  _DivisionBalloonPopGameModalState createState() => _DivisionBalloonPopGameModalState();
}

class _DivisionBalloonPopGameModalState extends State<DivisionBalloonPopGameModal> with SingleTickerProviderStateMixin {
  late AudioPlayer _sfxPlayer; // For sound effects
  late AudioPlayer _bgmPlayer; // For background music
  late ConfettiController _confettiController;
  List<Balloon> balloons = [];
  int score = 0;
  int timeLeft = 30;
  Timer? gameTimer;
  bool isGameOver = false;
  final Random random = Random();
  String currentQuestion = '';
  int correctAnswer = 0;
  String motivationalMessage = '';
  Timer? messageTimer;
  double difficulty = 1.0; // Increases with score
  final List<String> _questionHistory = []; // Track questions to avoid redundancy
  final List<String> _soundQueue = []; // Queue for sound playback
  bool _isPlayingSound = false; // Flag to prevent concurrent playback
  bool _isDisposing = false; // Flag to block sound queue during disposal
  bool _isMounted = false; // Flag to track widget mounting

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _sfxPlayer = AudioPlayer();
    _bgmPlayer = AudioPlayer();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _initializeAudioPlayers();
    _startGame();
  }

  Future<void> _initializeAudioPlayers() async {
    try {
      await _sfxPlayer.setVolume(1.0);
      await _bgmPlayer.setVolume(0.5); // Lower volume for background music
      // Enable background music if asset exists
      try {
        await _bgmPlayer.setAsset('assets/sounds/background_music.mp3');
        await _bgmPlayer.setLoopMode(LoopMode.all);
        if (_isMounted && !_isDisposing) {
          await _bgmPlayer.play();
          debugPrint('🔊 Background music initialized in DivisionBalloonPopGameModal');
        }
      } catch (e) {
        debugPrint('⚠️ Background music not available: $e');
      }
      debugPrint('🔊 AudioPlayers initialized in DivisionBalloonPopGameModal');
    } catch (e) {
      debugPrint('❌ AudioPlayer initialization error: $e');
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
      await _sfxPlayer.stop(); // Stop any currently playing sound
      await _sfxPlayer.setAsset(assetPath); // Load new sound
      await _sfxPlayer.play(); // Play the sound
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

  void _startGame() {
    if (!_isMounted) return;
    setState(() {
      balloons.clear();
      score = 0;
      timeLeft = 30;
      isGameOver = false;
      difficulty = 1.0;
      currentQuestion = '';
      motivationalMessage = '';
    });
    _generateQuestion();
    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!_isMounted) {
        timer.cancel();
        return;
      }
      setState(() {
        for (var balloon in balloons) {
          balloon.update();
        }
        balloons.removeWhere((balloon) => balloon.y < -50);
        if (random.nextDouble() < 0.05 && balloons.length < 6) _generateBalloons();
        timeLeft -= 50 ~/ 1000;
        if (timeLeft <= 0) {
          timer.cancel();
          isGameOver = true;
          _showGameOverDialog();
        }
      });
    });
    _playSound('assets/sounds/submit.wav');
  }

  void _generateQuestion() {
    if (!_isMounted) return;
    int divisor, quotient, dividend;
    String questionText;

    // Generate unique question
    do {
      final maxDivisor = (9 * difficulty).clamp(1, 9).toInt();
      final maxQuotient = (10 * difficulty).clamp(1, 12).toInt();
      divisor = random.nextInt(maxDivisor) + 1;
      quotient = random.nextInt(maxQuotient) + 1;
      dividend = divisor * quotient;
      questionText = '$dividend ÷ $divisor = ?';
    } while (_questionHistory.contains(questionText) && _questionHistory.length < 100);

    _questionHistory.add(questionText);
    if (_questionHistory.length > 100) _questionHistory.removeAt(0); // Limit history size

    setState(() {
      currentQuestion = questionText;
      correctAnswer = quotient;
      balloons.clear();
      _generateBalloons();
    });
  }

  void _generateBalloons() {
    if (!_isMounted) return;
    final numBalloons = random.nextInt(3) + 4; // 4-6 balloons
    final existingAnswers = <int>{};
    balloons.add(Balloon(
      x: random.nextDouble() * 280 + 10,
      y: 600,
      text: '$correctAnswer',
      isCorrect: true,
      isStar: false,
      speed: random.nextDouble() * 2 + 1.5,
      color: _getRandomColor(),
      angle: random.nextDouble() * 0.1 - 0.05,
    ));
    existingAnswers.add(correctAnswer);
    // Add star balloon (10% chance)
    if (random.nextDouble() < 0.1 && balloons.length < 6) {
      balloons.add(Balloon(
        x: random.nextDouble() * 280 + 10,
        y: 600,
        text: '★',
        isCorrect: false,
        isStar: true,
        speed: random.nextDouble() * 3 + 2,
        color: Colors.yellow.shade600,
        angle: random.nextDouble() * 0.2 - 0.1,
      ));
    }
    // Add incorrect balloons
    for (int i = balloons.length; i < numBalloons; i++) {
      int wrongAnswer;
      do {
        wrongAnswer = correctAnswer + random.nextInt(21) - 10;
      } while (wrongAnswer == correctAnswer || wrongAnswer <= 0 || existingAnswers.contains(wrongAnswer));
      existingAnswers.add(wrongAnswer);
      balloons.add(Balloon(
        x: random.nextDouble() * 280 + 10,
        y: 600,
        text: '$wrongAnswer',
        isCorrect: false,
        isStar: false,
        speed: random.nextDouble() * 2 + 1.5,
        color: _getRandomColor(),
        angle: random.nextDouble() * 0.1 - 0.05,
      ));
    }
  }

  Color _getRandomColor() {
    final colors = [
      Colors.red.shade400,
      Colors.blue.shade400,
      Colors.green.shade400,
      Colors.yellow.shade400,
    ];
    return colors[random.nextInt(colors.length)];
  }

  void _onBalloonTap(Balloon balloon) {
    if (!isGameOver && _isMounted) {
      setState(() {
        if (balloon.isStar) {
          score += 20;
          _playSound('assets/sounds/start.wav');
          _confettiController.play();
          motivationalMessage = 'Bonus Star! 🌟';
        } else if (balloon.isCorrect) {
          score += 10;
          difficulty += 0.1; // Increase difficulty
          _playSound('assets/sounds/correct.wav');
          _confettiController.play();
          final messages = ['Division Hero!', 'Math Superstar!', 'Fantastic!', 'You Rock!'];
          motivationalMessage = messages[random.nextInt(messages.length)];
          balloons.clear();
          _generateQuestion();
        } else {
          score = (score - 5).clamp(0, score);
          _playSound('assets/sounds/submit.wav');
          motivationalMessage = 'Oops, Try Again!';
        }
        messageTimer?.cancel();
        messageTimer = Timer(const Duration(seconds: 2), () {
          if (_isMounted) {
            setState(() {
              motivationalMessage = '';
            });
          }
        });
        balloons.remove(balloon);
        _playSound('assets/sounds/cliick.wav');
      });
    }
  }

  void _showGameOverDialog() {
    if (!_isMounted) return;
    _playSound('assets/sounds/start.wav');
    _confettiController.play();
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
                "Game Over! 🎉",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.cyanAccent : Colors.blue.shade700,
                  fontFamily: 'Comic Sans MS',
                ),
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Score: $score 🌟",
                    style: TextStyle(
                      fontSize: 22,
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                      fontFamily: 'Comic Sans MS',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "You're a Division Champ! Play again?",
                    style: TextStyle(
                      fontSize: 18,
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
                    if (_isMounted) {
                      _startGame();
                    }
                  },
                  child: Text(
                    "Play Again! 🚀",
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.cyanAccent : Colors.blue.shade700,
                      fontFamily: 'Comic Sans MS',
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _playSound('assets/sounds/cliick.wav');
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Exit! 🌟",
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.cyanAccent : Colors.blue.shade700,
                      fontFamily: 'Comic Sans MS',
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
              numberOfParticles: 30,
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
    _isMounted = false; // Stop timers
    _soundQueue.clear(); // Clear sound queue
    _sfxPlayer.stop().then((_) {
      _sfxPlayer.dispose();
      debugPrint('🗑️ Disposed SFX AudioPlayer in DivisionBalloonPopGameModal');
    }).catchError((e) {
      debugPrint('❌ Error disposing SFX AudioPlayer: $e');
    });
    _bgmPlayer.stop().then((_) {
      _bgmPlayer.dispose();
      debugPrint('🗑️ Disposed BGM AudioPlayer in DivisionBalloonPopGameModal');
    }).catchError((e) {
      debugPrint('❌ Error disposing BGM AudioPlayer: $e');
    });
    _confettiController.dispose();
    gameTimer?.cancel();
    messageTimer?.cancel();
    debugPrint('🗑️ Disposed ConfettiController and Timers in DivisionBalloonPopGameModal');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [Colors.blue.shade900, Colors.blue.shade700]
                : [Colors.blue.shade100, Colors.yellow.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            // Animated Clouds
            ...List.generate(4, (index) {
              return AnimatedPositioned(
                duration: Duration(seconds: 15 + index * 5),
                left: (index % 2 == 0 ? -100 : 400) + (random.nextDouble() * 50),
                top: 80.0 * (index + 1),
                child: Opacity(
                  opacity: 0.8,
                  child: Icon(
                    Icons.cloud,
                    size: 60,
                    color: isDarkMode ? Colors.grey.shade600 : Colors.white,
                  ),
                ).animate().moveX(
                  begin: index % 2 == 0 ? -400 : 400,
                  end: index % 2 == 0 ? 400 : -400,
                  duration: Duration(seconds: 15 + index * 5),
                  curve: Curves.linear,
                ),
              );
            }),
            // Rainbow
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: 0.3,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.red,
                        Colors.orange,
                        Colors.yellow,
                        Colors.green,
                        Colors.blue,
                        Colors.purple,
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: Duration(seconds: 2), delay: Duration(seconds: 1)).fadeOut(delay: Duration(seconds: 4)),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Score: $score",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.cyanAccent : Colors.blue.shade800,
                              fontFamily: 'Comic Sans MS',
                            ),
                          ),
                          Text(
                            "Time: ${timeLeft}s",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.cyanAccent : Colors.blue.shade800,
                              fontFamily: 'Comic Sans MS',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.blue.shade800 : Colors.yellow.shade200,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          currentQuestion,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.yellowAccent : Colors.blue.shade900,
                            fontFamily: 'Comic Sans MS',
                          ),
                        ),
                      ).animate().scale(
                        begin: const Offset(0.95, 0.95),
                        end: const Offset(1.05, 1.05),
                        duration: Duration(seconds: 1),
                        curve: Curves.easeInOut,
                      ).then().scale(
                        begin: const Offset(1.05, 1.05),
                        end: const Offset(0.95, 0.95),
                        duration: Duration(seconds: 1),
                        curve: Curves.easeInOut,
                      ),
                      if (motivationalMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            motivationalMessage,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.cyanAccent : Colors.green.shade600,
                              fontFamily: 'Comic Sans MS',
                            ),
                          ).animate().fadeIn(duration: Duration(milliseconds: 500)).fadeOut(delay: Duration(milliseconds: 1500)),
                        ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 400,
                  width: 300,
                  child: CustomPaint(
                    painter: BalloonPainter(balloons, isDarkMode, themeProvider, _onBalloonTap),
                    child: Container(),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () {
                  _playSound('assets/sounds/cliick.wav');
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: Duration(milliseconds: 800));
  }
}

class Balloon {
  double x;
  double y;
  final String text;
  final bool isCorrect;
  final bool isStar;
  double speed;
  Color color;
  double angle; // For zig-zag movement

  Balloon({
    required this.x,
    required this.y,
    required this.text,
    required this.isCorrect,
    required this.isStar,
    required this.speed,
    required this.color,
    required this.angle,
  });

  void update() {
    y -= speed;
    x += sin(y / 50) * angle * 10; // Zig-zag effect
    if (x < 0) x = 0;
    if (x > 300) x = 300;
  }
}

class BalloonPainter extends CustomPainter {
  final List<Balloon> balloons;
  final bool isDarkMode;
  final ThemeProvider themeProvider;
  final Function(Balloon) onBalloonTap;

  BalloonPainter(this.balloons, this.isDarkMode, this.themeProvider, this.onBalloonTap);

  @override
  void paint(Canvas canvas, Size size) {
    for (var balloon in balloons) {
      final paint = Paint()
        ..color = balloon.color
        ..style = PaintingStyle.fill;

      // Draw balloon
      canvas.drawOval(
        Rect.fromCenter(center: Offset(balloon.x, balloon.y), width: 60, height: 80),
        paint,
      );

      // Draw string
      final stringPaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawLine(
        Offset(balloon.x, balloon.y + 40),
        Offset(balloon.x, balloon.y + 60),
        stringPaint,
      );

      // Draw text
      final textStyle = TextStyle(
        color: Colors.white,
        fontSize: balloon.isStar ? 24 : 18,
        fontWeight: FontWeight.bold,
        fontFamily: 'Comic Sans MS',
      );
      final textSpan = TextSpan(text: balloon.text, style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(balloon.x - textPainter.width / 2, balloon.y - textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  @override
  bool hitTest(Offset position) {
    for (var balloon in balloons) {
      final rect = Rect.fromCenter(center: Offset(balloon.x, balloon.y), width: 60, height: 80);
      if (rect.contains(position)) {
        onBalloonTap(balloon);
        return true;
      }
    }
    return false;
  }
}