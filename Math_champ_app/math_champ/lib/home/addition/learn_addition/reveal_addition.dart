import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flip_card/flip_card.dart';
import '../../table_multiplication/widgets.dart';
import '/main.dart';
import 'choose_addition.dart';

class RevealAddition extends StatefulWidget {
  final int startNumber;
  final int endNumber;
  final int questionCount;
  final Difficulty difficulty;

  const RevealAddition({
    super.key,
    required this.startNumber,
    required this.endNumber,
    required this.questionCount,
    required this.difficulty,
  });

  @override
  _RevealAdditionState createState() => _RevealAdditionState();
}

class _RevealAdditionState extends State<RevealAddition> with TickerProviderStateMixin {
  final List<Map<String, dynamic>> _questions = [];
  late AudioPlayer _audioPlayer;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _initializeAudioPlayer();
    _generateQuestions();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playSound('assets/sounds/submit.wav');
      showErrorOverlay(
        context: context,
        message: "Let’s learn addition, champ! 🚀 Flip each card to see the question and answer! 🌟",
        onDismiss: () => _playSound('assets/sounds/cliick.wav'),
        tickerProvider: this,
      );
    });
  }

  Future<void> _initializeAudioPlayer() async {
    try {
      await _audioPlayer.setVolume(1.0);
      debugPrint('🔊 AudioPlayer initialized in RevealAddition');
    } catch (e) {
      debugPrint('❌ AudioPlayer initialization error in RevealAddition: $e');
    }
  }

  Future<void> _playSound(String assetPath) async {
    try {
      await _audioPlayer.stop(); // Stop any ongoing sound
      await _audioPlayer.setAsset(assetPath);
      await _audioPlayer.play();
      debugPrint('🔊 Playing sound: $assetPath');
    } catch (e) {
      debugPrint('❌ Error playing sound $assetPath: $e');
    }
  }

  void _generateQuestions() {
    final random = Random();
    final Set<String> questionSet = {};
    _questions.clear();

    List<Map<String, dynamic>> possibleQuestions = [];
    for (int a = widget.endNumber; a <= widget.startNumber; a++) {
      for (int b = widget.endNumber; b <= widget.startNumber - a; b++) {
        int sum = a + b;
        if (sum <= widget.startNumber) {
          if (widget.difficulty == Difficulty.easy ||
              (widget.difficulty == Difficulty.medium && sum >= 10) ||
              (widget.difficulty == Difficulty.hard && sum >= 20)) {
            possibleQuestions.add({
              'question': '$a + $b = ?',
              'answer': sum,
              'weight': widget.difficulty == Difficulty.hard
                  ? sum / widget.startNumber
                  : widget.difficulty == Difficulty.medium
                  ? sum >= 10 ? 2.0 : 1.0
                  : 1.0,
            });
          }
        }
      }
    }

    possibleQuestions.sort((a, b) => b['weight'].compareTo(a['weight']));
    int selected = 0;
    while (selected < widget.questionCount && possibleQuestions.isNotEmpty) {
      double totalWeight = possibleQuestions.fold(0, (sum, q) => sum + q['weight']);
      double randomWeight = random.nextDouble() * totalWeight;
      double currentWeight = 0;
      for (var question in possibleQuestions.toList()) {
        currentWeight += question['weight'];
        if (currentWeight >= randomWeight && !questionSet.contains(question['question'])) {
          questionSet.add(question['question']);
          _questions.add({
            'question': question['question'],
            'answer': question['answer'],
          });
          possibleQuestions.remove(question);
          selected++;
          break;
        }
      }
    }

    if (_questions.length < widget.questionCount) {
      debugPrint('⚠️ Not enough unique questions: ${_questions.length}/${widget.questionCount}');
      _questions.add({
        'question': '1 + 1 = ?',
        'answer': 2,
      });
    } else {
      _playSound('assets/sounds/correct.wav');
    }
  }

  Future<bool> _onWillPop() async {
    await _playSound('assets/sounds/cliick.wav');
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finish Learning? 🚪'),
        content: const Text('Are you sure you want to leave this addition adventure? 🌟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Stay! 😊'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Leave! 🚀'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _finishLearning() {
    _playSound('assets/sounds/submit.wav');
    _confettiController.play();
    showDialog(
      context: context,
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
                "Awesome Job, Math Champ! 🎉",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.cyanAccent : Colors.purple.shade600,
                  fontFamily: 'Comic Sans MS',
                ),
                textAlign: TextAlign.center,
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "You learned ${widget.questionCount} addition questions! You're an addition superstar! 🌟",
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
                            ? [Colors.cyanAccent, Colors.blueAccent]
                            : [Colors.yellow.shade300.withAlpha(51), Colors.pink.shade300.withAlpha(51)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "Back to Setup! 🌟",
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
              emissionFrequency: 0.02,
              numberOfParticles: 30,
              gravity: 0.1,
              colors: const [Colors.red, Colors.blue, Colors.yellow, Colors.green, Colors.pink],
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
    debugPrint('🗑️ Disposed AudioPlayer and ConfettiController in RevealAddition');
    super.dispose();
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
            titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Comic Sans MS'),
          ),
        )
            : ThemeData.light().copyWith(
          primaryColor: themeProvider.lightPrimaryColor,
          scaffoldBackgroundColor: Colors.white,
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: Colors.black87, fontFamily: 'Comic Sans MS'),
            titleLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontFamily: 'Comic Sans MS'),
          ),
        ),
        child: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [Colors.purple.shade700, Colors.pink.shade700]
                    : [Colors.yellow.shade300.withAlpha(51), Colors.pink.shade300.withAlpha(51)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          "Addition Adventure! 🚀",
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.cyanAccent : Colors.pink.shade600,
                            fontFamily: 'Comic Sans MS',
                            shadows: [
                              Shadow(
                                blurRadius: 12,
                                color: Colors.black.withOpacity(0.4),
                                offset: const Offset(3, 3),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Positioned(
                          right: 0,
                          top: 43,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'images/math_mascot.jpg',
                              height: 40,
                              width: 50,
                              errorBuilder: (context, error, stackTrace) {
                                debugPrint('❌ Error loading math_mascot.jpg: $error');
                                return const Icon(
                                  Icons.star,
                                  size: 45,
                                  color: Colors.yellow,
                                );
                              },
                            ),
                          ).animate().shake(duration: 2000.ms, hz: 1),
                        ),
                        Positioned(
                          right: 80,
                          top: 55,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              widget.difficulty == Difficulty.easy
                                  ? "Easy adding, champ! 🌟"
                                  : widget.difficulty == Difficulty.medium
                                  ? "Medium adding fun! 🚀"
                                  : "Hard adding, superstar! 💪",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.purple.shade700,
                                fontFamily: 'Comic Sans MS',
                              ),
                            ),
                          ).animate().fadeIn(duration: 1000.ms),
                        ),
                      ],
                    ).animate().fadeIn(duration: 800.ms),
                    const SizedBox(height: 20),
                    if (_questions.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _questions.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: FlipCard(
                              fill: Fill.fillBack,
                              direction: FlipDirection.HORIZONTAL,
                              onFlip: () {
                                _playSound('assets/sounds/correct.wav');
                                _confettiController.play();
                                setState(() {});
                              },
                              front: Card(
                                elevation: 8,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                color: isDarkMode ? Colors.grey.shade800 : Colors.white,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20.0),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isDarkMode
                                          ? [Colors.pink.shade700, Colors.purple.shade700]
                                          : [Colors.pink.shade300.withAlpha(51), Colors.purple.shade300.withAlpha(51)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Question ${index + 1}",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: isDarkMode ? Colors.cyanAccent : Colors.white,
                                          fontFamily: 'Comic Sans MS',
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        _questions[index]['question'],
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w600,
                                          foreground: Paint()
                                            ..shader = LinearGradient(
                                              colors: isDarkMode
                                                  ? [Colors.yellowAccent, Colors.greenAccent]
                                                  : [Colors.yellow.shade400, Colors.green.shade400],
                                            ).createShader(const Rect.fromLTWH(0, 0, 150, 30)),
                                          fontFamily: 'Comic Sans MS',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              back: Card(
                                elevation: 8,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                color: isDarkMode ? Colors.grey.shade800 : Colors.white,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20.0),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isDarkMode
                                          ? [Colors.green.shade700, Colors.teal.shade700]
                                          : [Colors.green.shade300.withAlpha(51), Colors.teal.shade300.withAlpha(51)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Answer ${index + 1}",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: isDarkMode ? Colors.cyanAccent : Colors.white,
                                          fontFamily: 'Comic Sans MS',
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        "${_questions[index]['answer']}",
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: isDarkMode ? Colors.greenAccent : Colors.green.shade700,
                                          fontFamily: 'Comic Sans MS',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ).animate()
                                .fadeIn(duration: 600.ms)
                                .then()
                                .rotate(begin: -0.1, end: 0.1, duration: 200.ms, curve: Curves.easeInOut)
                                .then()
                                .rotate(begin: 0.1, end: -0.1, duration: 200.ms, curve: Curves.easeInOut)
                                .then()
                                .rotate(begin: -0.05, end: 0.05, duration: 100.ms, curve: Curves.easeInOut)
                                .then()
                                .rotate(begin: 0.05, end: 0.0, duration: 100.ms, curve: Curves.easeInOut),
                          );
                        },
                      )
                    else
                      Center(
                        child: Text(
                          "No questions available! Try a bigger range! 🌟",
                          style: TextStyle(
                            fontSize: 18,
                            color: isDarkMode ? Colors.white70 : Colors.black87,
                            fontFamily: 'Comic Sans MS',
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ConfettiWidget(
                            confettiController: _confettiController,
                            blastDirectionality: BlastDirectionality.explosive,
                            particleDrag: 0.05,
                            emissionFrequency: 0.02,
                            numberOfParticles: 30,
                            gravity: 0.1,
                            colors: const [Colors.red, Colors.blue, Colors.yellow, Colors.green, Colors.pink],
                          ),
                          buildButton(
                            label: "Finish Learning! 🎉",
                            onTap: _finishLearning,
                            isDarkMode: isDarkMode,
                            themeProvider: themeProvider,
                          ).animate()
                              .fadeIn(duration: 600.ms)
                              .then()
                              .rotate(begin: -0.1, end: 0.1, duration: 200.ms, curve: Curves.easeInOut)
                              .then()
                              .rotate(begin: 0.1, end: -0.1, duration: 200.ms, curve: Curves.easeInOut)
                              .then()
                              .rotate(begin: -0.05, end: 0.05, duration: 100.ms, curve: Curves.easeInOut)
                              .then()
                              .rotate(begin: 0.05, end: 0.0, duration: 100.ms, curve: Curves.easeInOut),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showErrorOverlay({
    required BuildContext context,
    required String message,
    required Future<void> Function() onDismiss,
    required TickerProvider tickerProvider,
  }) {
    OverlayEntry? overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 6,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.purple.shade700,
                    fontFamily: 'Comic Sans MS',
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await onDismiss();
                    overlayEntry?.remove();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink.shade400,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text(
                    'Got it! 🌟',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontFamily: 'Comic Sans MS',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(overlayEntry);
  }
}