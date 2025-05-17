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

class _DivisionBalloonPopGameModalState extends State<DivisionBalloonPopGameModal> with TickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
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

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _initializeAudioPlayer();
    _startGame();
  }

  Future<void> _initializeAudioPlayer() async {
    try {
      await _audioPlayer.setVolume(1.0);
      debugPrint('🔊 AudioPlayer initialized in DivisionBalloonPopGameModal');
    } catch (e) {
      debugPrint('❌ AudioPlayer initialization error in DivisionBalloonPopGameModal: $e');
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

  void _startGame() {
    balloons.clear();
    score = 0;
    timeLeft = 30;
    isGameOver = false;
    currentQuestion = '';
    motivationalMessage = '';
    _generateQuestion();
    gameTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        for (var balloon in balloons) {
          balloon.update();
        }
        balloons.removeWhere((balloon) => balloon.y < -50);
        if (random.nextDouble() < 0.03 && balloons.length < 5) _generateBalloons();
        timeLeft -= 50 ~/ 1000;
        if (timeLeft <= 0) {
          timer.cancel();
          isGameOver = true;
          _showGameOverDialog();
        }
      });
    });
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (isGameOver) timer.cancel();
      setState(() {
        _generateQuestion();
      });
    });
    _playSound('assets/sounds/start.wav');
  }

  void _generateQuestion() {
    final divisor = random.nextInt(9) + 1;
    final quotient = random.nextInt(10) + 1;
    final dividend = divisor * quotient;
    setState(() {
      currentQuestion = '$dividend ÷ $divisor = ?';
      correctAnswer = quotient;
      balloons.clear();
      _generateBalloons();
    });
  }

  void _generateBalloons() {
    final numBalloons = random.nextInt(3) + 3;
    final existingAnswers = <int>{};
    balloons.add(Balloon(
      x: random.nextDouble() * 300,
      y: 600,
      text: '$correctAnswer',
      isCorrect: true,
      isTrick: false,
      speed: random.nextDouble() * 2 + 1,
      color: _getRandomColor(),
    ));
    existingAnswers.add(correctAnswer);
    for (int i = 1; i < numBalloons; i++) {
      int wrongAnswer;
      do {
        wrongAnswer = correctAnswer + random.nextInt(21) - 10;
      } while (wrongAnswer == correctAnswer || wrongAnswer < 0 || existingAnswers.contains(wrongAnswer));
      existingAnswers.add(wrongAnswer);
      final isTrick = random.nextDouble() < 0.05;
      balloons.add(Balloon(
        x: random.nextDouble() * 300,
        y: 600,
        text: '$wrongAnswer',
        isCorrect: false,
        isTrick: isTrick,
        speed: isTrick ? random.nextDouble() * 3 + 2 : random.nextDouble() * 2 + 1,
        color: isTrick ? Colors.purple.shade700 : _getRandomColor(),
      ));
    }
  }

  Color _getRandomColor() {
    final colors = [
      Colors.red.shade300,
      Colors.blue.shade300,
      Colors.yellow.shade300,
      Colors.green.shade300,
    ];
    return colors[random.nextInt(colors.length)];
  }

  void _onBalloonTap(Balloon balloon) {
    if (!isGameOver) {
      setState(() {
        if (balloon.isCorrect) {
          score += 10;
          _playSound('assets/sounds/correct.wav');
          _confettiController.play();
          final messages = ['Super Job!', 'You’re a Math Star!', 'Awesome!', 'Keep Going!'];
          motivationalMessage = messages[random.nextInt(messages.length)];
          messageTimer?.cancel();
          messageTimer = Timer(const Duration(seconds: 2), () {
            setState(() {
              motivationalMessage = '';
            });
          });
          balloons.clear();
          _generateQuestion();
        } else {
          score = (score - (balloon.isTrick ? 10 : 5)).clamp(0, score);
          _playSound('assets/sounds/wrong.mp3');
        }
        balloons.remove(balloon);
        _playSound('assets/sounds/pop.mp3');
      });
    }
  }

  void _showGameOverDialog() {
    _playSound('assets/sounds/submit.wav');
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
                    "Your Score: $score 🌟",
                    style: TextStyle(
                      fontSize: 18,
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                      fontFamily: 'Comic Sans MS',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Great job, Math Champ! Want to play again?",
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
                    setState(() {
                      _startGame();
                    });
                  },
                  child: const Text("Play Again! 🚀"),
                ),
                TextButton(
                  onPressed: () {
                    _playSound('assets/sounds/cliick.wav');
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text("Exit! 🌟"),
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
    _audioPlayer.dispose();
    _confettiController.dispose();
    gameTimer?.cancel();
    messageTimer?.cancel();
    debugPrint('🗑️ Disposed AudioPlayer, ConfettiController, and Timers in DivisionBalloonPopGameModal');
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
                ? [Colors.blue.shade900, Colors.blue.shade600]
                : [Colors.blue.shade200, Colors.blue.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            // Animated Clouds
            ...List.generate(3, (index) {
              return AnimatedPositioned(
                duration: Duration(seconds: 20 + index * 5),
                left: (index % 2 == 0 ? -100 : 400) + (random.nextDouble() * 100 - 50),
                top: 100.0 * (index + 1),
                child: Opacity(
                  opacity: 0.7,
                  child: Icon(
                    Icons.cloud,
                    size: 50,
                    color: isDarkMode ? Colors.grey.shade700 : Colors.white,
                  ),
                ).animate().moveX(
                  begin: index % 2 == 0 ? -400 : 400,
                  end: index % 2 == 0 ? 400 : -400,
                  duration: Duration(seconds: 20 + index * 5),
                  curve: Curves.linear,
                ),
              );
            }),
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
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.cyanAccent : Colors.blue.shade800,
                              fontFamily: 'Comic Sans MS',
                            ),
                          ),
                          Text(
                            "Time: ${timeLeft}s",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.cyanAccent : Colors.blue.shade800,
                              fontFamily: 'Comic Sans MS',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        currentQuestion,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.yellowAccent : Colors.blue.shade900,
                          fontFamily: 'Comic Sans MS',
                        ),
                      ),
                      if (motivationalMessage.isNotEmpty)
                        Text(
                          motivationalMessage,
                          style: TextStyle(
                            fontSize: 18,
                            color: isDarkMode ? Colors.cyanAccent : Colors.green.shade600,
                            fontFamily: 'Comic Sans MS',
                          ),
                        ).animate().fadeIn(duration: 500.ms).fadeOut(delay: 1500.ms),
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
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  _playSound('assets/sounds/cliick.wav');
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 800.ms);
  }
}

class Balloon {
  double x;
  double y;
  final String text;
  final bool isCorrect;
  final bool isTrick;
  double speed;
  Color color;

  Balloon({
    required this.x,
    required this.y,
    required this.text,
    required this.isCorrect,
    required this.isTrick,
    required this.speed,
    required this.color,
  });

  void update() {
    y -= speed;
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
        Rect.fromCenter(center: Offset(balloon.x, balloon.y), width: 50, height: 70),
        paint,
      );

      // Draw string
      final stringPaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawLine(
        Offset(balloon.x, balloon.y + 35),
        Offset(balloon.x, balloon.y + 50),
        stringPaint,
      );

      // Draw text
      final textStyle = TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        fontFamily: 'Comic Sans MS',
      );
      final textSpan = TextSpan(text: balloon.text, style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(balloon.x - textPainter.width / 2, balloon.y - 10));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  @override
  bool hitTest(Offset position) {
    for (var balloon in balloons) {
      final rect = Rect.fromCenter(center: Offset(balloon.x, balloon.y), width: 50, height: 70);
      if (rect.contains(position)) {
        onBalloonTap(balloon);
        return true;
      }
    }
    return false;
  }
}