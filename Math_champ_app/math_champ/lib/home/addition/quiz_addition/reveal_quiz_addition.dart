import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '/main.dart';
import '../../subtraction/quiz_subtraction/quiz_game.dart';
import '../../table_multiplication/widgets.dart';
import 'set_quiz_addition.dart';

class RevealQuizAddition extends StatefulWidget {
  final int startNumber;
  final int endNumber;
  final Difficulty difficulty;
  final int questionCount;
  final int timePerQuestion;

  const RevealQuizAddition({
    super.key,
    required this.startNumber,
    required this.endNumber,
    required this.difficulty,
    required this.questionCount,
    required this.timePerQuestion,
  });

  @override
  _RevealQuizAdditionState createState() => _RevealQuizAdditionState();
}

class _RevealQuizAdditionState extends State<RevealQuizAddition> with TickerProviderStateMixin {
  final List<Map<String, dynamic>> _quizQuestions = [];
  List<int?> _userAnswers = [];
  bool _quizStarted = false;
  bool _quizEnded = false;
  int _remainingTime = 0;
  Timer? _timer;
  late AudioPlayer _audioPlayer;
  late ConfettiController _confettiController;
  final List<String> _questionHistory = [];
  String _mascotMessage = "Time to add, champ! 🚀";

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    _initializeAudioPlayer();
    _generateQuiz();
  }

  Future<void> _initializeAudioPlayer() async {
    try {
      await _audioPlayer.setVolume(1.0);
      debugPrint('🔊 AudioPlayer initialized in RevealQuizAddition');
    } catch (e) {
      debugPrint('❌ AudioPlayer initialization error in RevealQuizAddition: $e');
    }
  }

  Future<void> _playSound(String assetPath) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setAsset(assetPath);
      await _audioPlayer.play();
      debugPrint('🔊 Playing sound: $assetPath');
    } catch (e) {
      debugPrint('❌ Error playing sound $assetPath: $e');
    }
  }

  void _generateQuiz() {
    final random = Random();
    _quizQuestions.clear();
    _questionHistory.clear();
    _userAnswers = List.filled(widget.questionCount, null);

    List<Map<String, dynamic>> possibleQuestions = [];
    for (int addend1 = widget.endNumber; addend1 <= widget.startNumber; addend1++) {
      for (int addend2 = widget.endNumber; addend2 <= widget.startNumber - addend1; addend2++) {
        int sum = addend1 + addend2;
        if (sum <= widget.startNumber && sum >= widget.endNumber) {
          if (widget.difficulty == Difficulty.easy ||
              (widget.difficulty == Difficulty.medium && sum >= 10) ||
              (widget.difficulty == Difficulty.hard && sum >= 20)) {
            possibleQuestions.add({
              'question': '$addend1 + $addend2 = ?',
              'addend1': addend1,
              'addend2': addend2,
              'correct': sum,
              'weight': widget.difficulty == Difficulty.hard
                  ? sum * (addend1 / widget.startNumber)
                  : widget.difficulty == Difficulty.medium
                  ? sum
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
        if (currentWeight >= randomWeight && !_questionHistory.contains(question['question'])) {
          _questionHistory.add(question['question']);
          List<int> options = [question['correct']];
          while (options.length < 4) {
            int deviation = question['correct'] <= 10 ? random.nextInt(3) + 1 : random.nextInt(5) + 2;
            int wrongAnswer = random.nextBool()
                ? question['correct'] + deviation
                : max(1, question['correct'] - deviation);
            if (!options.contains(wrongAnswer)) {
              options.add(wrongAnswer);
            }
          }
          options.shuffle();
          _quizQuestions.add({
            'addend1': question['addend1'],
            'addend2': question['addend2'],
            'question': question['question'],
            'options': options,
            'correct': question['correct'],
          });
          possibleQuestions.remove(question);
          selected++;
          break;
        }
      }
    }

    if (_quizQuestions.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorOverlay(
          context: context,
          message: "No questions available! Try a larger range! 🌟",
          onDismiss: () => _playSound('assets/sounds/cliick.wav'),
          tickerProvider: this,
        );
      });
      return;
    }

    setState(() {
      _quizStarted = true;
      _quizEnded = false;
      _startTimer();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playSound('assets/sounds/submit.wav');
      showErrorOverlay(
        context: context,
        message: "Your addition quiz adventure starts now! 🚀",
        onDismiss: () => _playSound('assets/sounds/cliick.wav'),
        tickerProvider: this,
      );
    });
  }

  void _startTimer() {
    _remainingTime = widget.questionCount * widget.timePerQuestion;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
          _mascotMessage = _remainingTime <= 10
              ? "Hurry, only $_remainingTime seconds left! ⏰"
              : "Keep adding, champ! 🚀";
        } else {
          _timer?.cancel();
          _completeSubmission();
        }
      });
    });
  }

  void _submitQuiz() {
    if (_remainingTime > 0) {
      int unansweredCount = _userAnswers.where((answer) => answer == null).length;
      String confirmationMessage = "Ready to submit your quiz, champ? 😊";
      if (unansweredCount > 0) {
        confirmationMessage +=
        "\n\nYou haven’t answered $unansweredCount question${unansweredCount > 1 ? 's' : ''} yet! Want to try those or submit now? 🌟";
      }
      showDialog(
        context: context,
        builder: (context) {
          final themeProvider = Provider.of<ThemeProvider>(context);
          final isDarkMode = themeProvider.isDarkMode;
          return AlertDialog(
            backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              "Finish Your Quiz? 🚀",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.cyanAccent : Colors.blue.shade600,
                fontFamily: 'Comic Sans MS',
              ),
              textAlign: TextAlign.center,
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              child: Text(
                confirmationMessage,
                style: TextStyle(
                  fontSize: 18,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                  height: 1.5,
                  fontFamily: 'Comic Sans MS',
                ),
                textAlign: TextAlign.center,
              ),
            ),
            actions: [
              buildButton(
                label: "Keep Going! 🌟",
                onTap: () {
                  _playSound('assets/sounds/cliick.wav');
                  Navigator.pop(context);
                },
                isDarkMode: isDarkMode,
                themeProvider: themeProvider,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              buildButton(
                label: "Yes, Submit! 🚀",
                onTap: () {
                  _playSound('assets/sounds/submit.wav');
                  Navigator.pop(context);
                  _completeSubmission();
                },
                isDarkMode: isDarkMode,
                themeProvider: themeProvider,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ],
          );
        },
      );
    } else {
      _completeSubmission();
    }
  }

  void _completeSubmission() {
    _timer?.cancel();
    int correct = 0;
    for (int i = 0; i < _quizQuestions.length; i++) {
      if (_userAnswers[i] == _quizQuestions[i]["correct"]) {
        correct++;
      }
    }
    setState(() {
      _quizEnded = true;
    });
    _showQuizResults(correct);
  }

  void _showQuizResults(int correct) {
    _playSound(correct >= widget.questionCount * 0.5 ? 'assets/sounds/submit.wav' : 'assets/sounds/start.wav');
    _confettiController.play();
    String message = correct >= widget.questionCount * 0.8
        ? "Wow, you’re an addition superstar! Keep shining! 🌟"
        : correct >= widget.questionCount * 0.5
        ? "Great job, champ! Practice makes perfect! 🚀"
        : "Awesome try! Let’s keep practicing! 💪";
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
                "Your Quiz Results! 🎉",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..shader = LinearGradient(
                      colors: isDarkMode
                          ? [Colors.cyanAccent, Colors.yellowAccent]
                          : [Colors.blue.shade600, Colors.green.shade600],
                    ).createShader(const Rect.fromLTWH(0, 0, 100, 20)),
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
                      "$correct/${widget.questionCount} Correct!",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                        fontFamily: 'Comic Sans MS',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 18,
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                        fontFamily: 'Comic Sans MS',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              actions: [
                buildButton(
                  label: "OK, Back to Setup! 🌟",
                  onTap: () {
                    _playSound('assets/sounds/cliick.wav');
                    Navigator.pop(context);
                    Navigator.pop(context);
                    setState(() {
                      _quizStarted = false;
                      _quizEnded = false;
                    });
                  },
                  isDarkMode: isDarkMode,
                  themeProvider: themeProvider,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                buildButton(
                  label: "See Details! 📊",
                  onTap: () {
                    _playSound('assets/sounds/cliick.wav');
                    Navigator.pop(context);
                    _showDetailedResults();
                  },
                  isDarkMode: isDarkMode,
                  themeProvider: themeProvider,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                buildButton(
                  label: "Back to Addition! 🏠",
                  onTap: () {
                    _playSound('assets/sounds/cliick.wav');
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.pop(context, {'showGame': true, 'module': 'addition'});
                  },
                  isDarkMode: isDarkMode,
                  themeProvider: themeProvider,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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

  void _showDetailedResults() {
    showDialog(
      context: context,
      builder: (context) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        final isDarkMode = themeProvider.isDarkMode;
        return AlertDialog(
          backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            "Your Quiz Details! 📊",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.cyanAccent : Colors.blue.shade600,
              fontFamily: 'Comic Sans MS',
            ),
            textAlign: TextAlign.center,
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _quizQuestions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final question = entry.value;
                  final userAnswer = _userAnswers[index];
                  final correctAnswer = question["correct"];
                  final isCorrect = userAnswer == correctAnswer;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isCorrect
                              ? isDarkMode
                              ? [Colors.green.shade700, Colors.green.shade900]
                              : [Colors.green.shade400, Colors.green.shade600]
                              : isDarkMode
                              ? [Colors.red.shade700, Colors.red.shade900]
                              : [Colors.red.shade400, Colors.red.shade600],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: isDarkMode ? Colors.cyanAccent.withAlpha(51) : Colors.black.withAlpha(26),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Q${index + 1}: ${question["question"]}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Comic Sans MS',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Your Answer: ${userAnswer ?? "Not answered"}",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                              fontFamily: 'Comic Sans MS',
                            ),
                          ),
                          if (!isCorrect) ...[
                            const SizedBox(height: 8),
                            Text(
                              "Correct Answer: $correctAnswer",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Comic Sans MS',
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            buildButton(
              label: "Back to Results! 🌟",
              onTap: () {
                _playSound('assets/sounds/cliick.wav');
                Navigator.pop(context);
                int correct = 0;
                for (int i = 0; i < _quizQuestions.length; i++) {
                  if (_userAnswers[i] == _quizQuestions[i]["correct"]) {
                    correct++;
                  }
                }
                _showQuizResults(correct);
              },
              isDarkMode: isDarkMode,
              themeProvider: themeProvider,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _onWillPop() async {
    if (_quizEnded) {
      return true;
    }
    _timer?.cancel();
    await _playSound('assets/sounds/cliick.wav');
    int correct = 0;
    for (int i = 0; i < _quizQuestions.length; i++) {
      if (_userAnswers[i] == _quizQuestions[i]["correct"]) {
        correct++;
      }
    }
    int score = (_quizQuestions.isNotEmpty ? correct / _quizQuestions.length * 100 : 0).toInt();
    bool? shouldExit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StarCollectorGame(score: score),
    );
    if (shouldExit == true) {
      setState(() {
        _quizStarted = false;
        _quizEnded = false;
      });
    }
    return shouldExit ?? false;
  }

  Widget _buildAnswerChip({
    required int option,
    required int index,
    required bool isDarkMode,
    required ThemeProvider themeProvider,
  }) {
    final isSelected = _userAnswers[index] == option;
    return GestureDetector(
      onTap: _quizEnded
          ? null
          : () {
        setState(() {
          _userAnswers[index] = option;
          _playSound('assets/sounds/cliick.wav');
          _mascotMessage = "Great choice! Keep going! 🌟";
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? isDarkMode
                ? [Colors.blue.shade700, Colors.blue.shade900]
                : [Colors.blue.shade300, Colors.blue.shade500]
                : isDarkMode
                ? [Colors.grey.shade700, Colors.grey.shade900]
                : [Colors.grey.shade200, Colors.grey.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? (isDarkMode ? Colors.cyanAccent.withAlpha(102) : Colors.black.withAlpha(51))
                  : Colors.transparent,
              blurRadius: 6,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Text(
          "$option",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : (isDarkMode ? Colors.white70 : Colors.black87),
            fontFamily: 'Comic Sans MS',
          ),
        ),
      ).animate().scale(
        begin: const Offset(0.9, 0.9),
        end: const Offset(1.0, 1.0),
        duration: 400.ms,
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
                      ? [Colors.blue.shade700, Colors.green.shade700]
                      : [Colors.blue.shade400, Colors.green.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            title: Text(
              "Addition Quiz Fun! 🎉",
              style: TextStyle(
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.bold,
                fontFamily: 'Comic Sans MS',
                shadows: [
                  Shadow(blurRadius: 10.0, color: Colors.black.withOpacity(0.4), offset: const Offset(2.0, 2.0)),
                ],
              ),
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [Colors.blue.shade700, Colors.green.shade700]
                    : [Colors.blue.shade300.withAlpha(51), Colors.green.shade300.withAlpha(51)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 80, bottom: 20),
                  child: Column(
                    children: [
                      ..._quizQuestions.map((question) {
                        final index = _quizQuestions.indexOf(question);
                        return Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          color: isDarkMode ? Colors.grey.shade800 : Colors.white,
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Question ${index + 1}/${_quizQuestions.length}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode ? Colors.cyanAccent : Colors.blue.shade600,
                                    fontFamily: 'Comic Sans MS',
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  question["question"],
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    foreground: Paint()
                                      ..shader = LinearGradient(
                                        colors: isDarkMode
                                            ? [Colors.yellowAccent, Colors.greenAccent]
                                            : [Colors.blue.shade400, Colors.green.shade400],
                                      ).createShader(const Rect.fromLTWH(0, 0, 100, 20)),
                                    fontFamily: 'Comic Sans MS',
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  alignment: WrapAlignment.center,
                                  children: question["options"].map<Widget>((option) {
                                    return _buildAnswerChip(
                                      option: option,
                                      index: index,
                                      isDarkMode: isDarkMode,
                                      themeProvider: themeProvider,
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(duration: 600.ms).then().rotate(
                          begin: -0.1,
                          end: 0.0,
                          duration: 1000.ms,
                          curve: Curves.easeInOut,
                        );
                      }).toList(),
                      const SizedBox(height: 24),
                      Stack(
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
                            label: "Submit Quiz! 🚀",
                            onTap: _quizEnded ? () {} : _submitQuiz,
                            isDarkMode: isDarkMode,
                            themeProvider: themeProvider,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            textStyle: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Comic Sans MS',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDarkMode
                            ? [Colors.blue.shade700, Colors.green.shade700]
                            : [Colors.blue.shade400, Colors.green.shade400],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode ? Colors.cyanAccent.withAlpha(51) : Colors.black.withAlpha(26),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.timer,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Time Left: $_remainingTime sec",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Comic Sans MS',
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 600.ms),
                ),
                Positioned(
                  right: 16,
                  top: 80,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.6,
                      minWidth: 120,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDarkMode
                            ? [Colors.cyanAccent.withOpacity(0.9), Colors.blueAccent.withOpacity(0.9)]
                            : [Colors.blue.shade200, Colors.green.shade200],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: isDarkMode ? Colors.cyanAccent : Colors.blue.shade400,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      _mascotMessage,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        foreground: Paint()
                          ..shader = LinearGradient(
                            colors: isDarkMode
                                ? [Colors.yellowAccent, Colors.greenAccent]
                                : [Colors.blue.shade600, Colors.green.shade600],
                          ).createShader(const Rect.fromLTWH(0, 0, 150, 30)),
                        fontFamily: 'Comic Sans MS',
                        shadows: [
                          Shadow(
                            blurRadius: 4,
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(1, 1),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ).animate()
                      .fadeIn(duration: 800.ms)
                      .then()
                      .scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1.0, 1.0),
                    duration: 300.ms,
                    curve: Curves.bounceOut,
                  ),
                ),
              ],
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
              gradient: LinearGradient(
                colors: [Colors.yellow.shade200, Colors.green.shade200],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 6,
                ),
              ],
              border: Border.all(color: Colors.blue.shade400, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..shader = LinearGradient(
                        colors: [Colors.blue.shade600, Colors.green.shade600],
                      ).createShader(const Rect.fromLTWH(0, 0, 150, 30)),
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
                    if (message.contains("No questions available")) {
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade400,
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
          ).animate().scale(
            begin: const Offset(0.9, 0.9),
            end: const Offset(1.0, 1.0),
            duration: 300.ms,
            curve: Curves.bounceOut,
          ),
        ),
      ),
    );
    Overlay.of(context).insert(overlayEntry);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    _confettiController.dispose();
    debugPrint('🗑️ Disposed AudioPlayer and ConfettiController in RevealQuizAddition');
    super.dispose();
  }
}