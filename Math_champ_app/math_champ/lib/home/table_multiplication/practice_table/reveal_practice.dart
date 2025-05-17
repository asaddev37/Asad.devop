import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import '/main.dart';
import '../widgets.dart';
import 'choose_practice_table.dart';

class PracticePage extends StatefulWidget {
  final List<int> selectedTables;
  final int range;
  final Difficulty difficulty;
  final int questionGoal;

  const PracticePage({
    super.key,
    required this.selectedTables,
    required this.range,
    required this.difficulty,
    required this.questionGoal,
  });

  @override
  _PracticePageState createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> with TickerProviderStateMixin {
  int? _currentTable;
  int _currentMultiplier = 1;
  int _correctAnswer = 0;
  String _feedback = '';
  int _score = 0;
  int _questionsAnswered = 0;
  DateTime? _lastRefreshTime;
  bool _showHint = false;
  int? _selectedAnswer;
  late AudioPlayer _audioPlayer;
  late ConfettiController _confettiController;
  late AnimationController _refreshAnimationController;
  List<int> _answerOptions = [];
  final List<String> _questionHistory = [];
  String _mascotMessage = "Let’s multiply, champ! 🚀";

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    _refreshAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _initializeAudioPlayer();
    _generateQuestion();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showErrorOverlay(
        context: context,
        message: "Your multiplication practice starts now! 🚀",
        onDismiss: () => _playSound('assets/sounds/cliick.wav'),
        tickerProvider: this,
      );
    });
  }

  Future<void> _initializeAudioPlayer() async {
    try {
      await _audioPlayer.setVolume(1.0);
      debugPrint('🔊 AudioPlayer initialized in PracticePage');
    } catch (e) {
      debugPrint('❌ AudioPlayer initialization error in PracticePage: $e');
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

  void _generateQuestion() {
    final random = Random();
    List<Map<String, dynamic>> possibleQuestions = [];
    for (int table in widget.selectedTables) {
      for (int multiplier = 1; multiplier <= widget.range; multiplier++) {
        int product = table * multiplier;
        String questionKey = '$table x $multiplier';
        if (!_questionHistory.contains(questionKey) &&
            (widget.difficulty == Difficulty.easy ||
                (widget.difficulty == Difficulty.medium && product >= 10) ||
                (widget.difficulty == Difficulty.hard && product >= 20))) {
          possibleQuestions.add({
            'table': table,
            'multiplier': multiplier,
            'product': product,
            'weight': widget.difficulty == Difficulty.hard
                ? product * (table / widget.selectedTables.length)
                : widget.difficulty == Difficulty.medium
                ? product
                : 1.0,
          });
        }
      }
    }

    if (possibleQuestions.isEmpty) {
      _showCompletionDialog();
      return;
    }

    possibleQuestions.sort((a, b) => b['weight'].compareTo(a['weight']));
    double totalWeight = possibleQuestions.fold(0, (sum, q) => sum + q['weight']);
    double randomWeight = random.nextDouble() * totalWeight;
    double currentWeight = 0;
    Map<String, dynamic> selectedQuestion = possibleQuestions.first;

    for (var question in possibleQuestions) {
      currentWeight += question['weight'];
      if (currentWeight >= randomWeight) {
        selectedQuestion = question;
        break;
      }
    }

    setState(() {
      _currentTable = selectedQuestion['table'];
      _currentMultiplier = selectedQuestion['multiplier'];
      _correctAnswer = selectedQuestion['product'];
      _questionHistory.add('$_currentTable x $_currentMultiplier');
      _feedback = '';
      _showHint = false;
      _selectedAnswer = null;

      _answerOptions = [_correctAnswer];
      while (_answerOptions.length < 4) {
        int deviation;
        if (_correctAnswer <= 20) {
          deviation = random.nextInt(3) + 1;
        } else if (_correctAnswer <= 100) {
          deviation = random.nextInt(4) + 2;
        } else {
          deviation = (_correctAnswer * (random.nextInt(21) + 10) ~/ 100);
        }
        int randomAnswer = random.nextBool() ? _correctAnswer + deviation : max(1, _correctAnswer - deviation);
        if (!_answerOptions.contains(randomAnswer)) {
          _answerOptions.add(randomAnswer);
        }
      }
      _answerOptions.shuffle();
      _mascotMessage = "What’s $_currentTable x $_currentMultiplier? You got this! 🌟";
    });
  }

  void _checkAnswer(int selectedAnswer) {
    setState(() {
      _questionsAnswered++;
      _selectedAnswer = selectedAnswer;
      if (selectedAnswer == _correctAnswer) {
        _feedback = '🎉 Correct! Great job!';
        _score++;
        _confettiController.play();
        _playSound('assets/sounds/correct.wav');
        _mascotMessage = "Awesome job! Keep it up! 🚀";
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            setState(() {
              _selectedAnswer = null;
              if (_questionsAnswered >= widget.questionGoal) {
                _showCompletionDialog();
              } else {
                _generateQuestion();
              }
            });
          }
        });
      } else {
        _feedback = '❌ Oops! The answer is $_correctAnswer. Try again!';
        _playSound('assets/sounds/incorrect.wav');
        _mascotMessage = "No worries, try the next one! 💪";
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            setState(() {
              _feedback = '';
              _selectedAnswer = null;
            });
          }
        });
      }
    });
  }

  void _resetPractice() {
    final now = DateTime.now();
    if (_lastRefreshTime != null && now.difference(_lastRefreshTime!).inSeconds < 2) {
      return;
    }
    setState(() {
      _score = 0;
      _questionsAnswered = 0;
      _currentTable = null;
      _currentMultiplier = 1;
      _correctAnswer = 0;
      _feedback = '';
      _showHint = false;
      _lastRefreshTime = now;
      _answerOptions.clear();
      _questionHistory.clear();
      _mascotMessage = "Fresh start, let’s multiply! 🚀";
    });
    _refreshAnimationController.forward(from: 0.0).then((_) {
      if (mounted) {
        _generateQuestion();
      }
    });
    _playSound('assets/sounds/refresh.wav');
  }

  void _showCompletionDialog() {
    _playSound('assets/sounds/submit.wav');
    _confettiController.play();
    String message = _score >= widget.questionGoal * 0.8
        ? "Wow, you’re a multiplication superstar! Keep shining! 🌟"
        : _score >= widget.questionGoal * 0.5
        ? "Great job, champ! Practice makes perfect! 🚀"
        : "Awesome try! Let’s do it again and score big! 💪";
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
                "Your Practice Results! 🎉",
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
                      "Score: $_score/${widget.questionGoal}",
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
                  label: "Restart Practice! 🌟",
                  onTap: () {
                    _playSound('assets/sounds/cliick.wav');
                    Navigator.pop(context);
                    _resetPractice();
                  },
                  isDarkMode: isDarkMode,
                  themeProvider: themeProvider,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                buildButton(
                  label: "Choose New Tables! 🚀",
                  onTap: () {
                    _playSound('assets/sounds/cliick.wav');
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  isDarkMode: isDarkMode,
                  themeProvider: themeProvider,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                buildButton(
                  label: "Back to Multiplication! 🏠",
                  onTap: () {
                    _playSound('assets/sounds/cliick.wav');
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.pop(context, {'showGame': true, 'module': 'multiplication'});
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
    ).then((_) {
      _confettiController.stop();
    });
  }

  Widget _buildAnswerButton({
    required int answer,
    required bool isDarkMode,
    required ThemeProvider themeProvider,
  }) {
    bool isCorrect = answer == _correctAnswer;
    bool isSelected = _selectedAnswer == answer;
    bool showFeedback = _feedback.isNotEmpty && isSelected;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAnswer = answer;
          _checkAnswer(answer);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: showFeedback
                ? (isCorrect
                ? isDarkMode
                ? [Colors.green.shade700, Colors.green.shade900]
                : [Colors.green.shade500, Colors.green.shade700]
                : isDarkMode
                ? [Colors.red.shade700, Colors.red.shade900]
                : [Colors.red.shade500, Colors.red.shade700])
                : isDarkMode
                ? [Colors.blue.shade700, Colors.cyan.shade700]
                : [Colors.blue.shade400, Colors.cyan.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? Colors.cyanAccent.withAlpha(102) : Colors.black.withAlpha(51),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: Text(
            '$answer',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Comic Sans MS',
            ),
          ),
        ),
      ).animate().scale(
        begin: const Offset(0.9, 0.9),
        end: const Offset(1.0, 1.0),
        duration: 400.ms,
        curve: Curves.bounceOut,
      ).then().shake(
        duration: showFeedback && !isCorrect ? 300.ms : 0.ms,
      ),
    );
  }

  Widget _buildProgressTracker({required bool isDarkMode, required ThemeProvider themeProvider}) {
    return Column(
      children: [
        Text(
          "Progress: $_questionsAnswered/${widget.questionGoal}",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..shader = LinearGradient(
                colors: isDarkMode
                    ? [Colors.cyanAccent, Colors.yellowAccent]
                    : [Colors.blue.shade600, Colors.green.shade600],
              ).createShader(const Rect.fromLTWH(0, 0, 100, 20)),
            fontFamily: 'Comic Sans MS',
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: _questionsAnswered / widget.questionGoal,
            backgroundColor: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation(isDarkMode ? Colors.cyanAccent : Colors.blue.shade600),
            minHeight: 10,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Theme(
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
          leading: Tooltip(
            message: 'Back',
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          title: Text(
            "Multiplication Practice Fun! 🎉",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildProgressTracker(isDarkMode: isDarkMode, themeProvider: themeProvider),
                const SizedBox(height: 20),
                Text(
                  "Score: $_score",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..shader = LinearGradient(
                        colors: isDarkMode
                            ? [Colors.cyanAccent, Colors.yellowAccent]
                            : [Colors.blue.shade600, Colors.green.shade600],
                      ).createShader(const Rect.fromLTWH(0, 0, 100, 20)),
                    fontFamily: 'Comic Sans MS',
                  ),
                ).animate().fadeIn(duration: 600.ms),
                const SizedBox(height: 30),
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  color: isDarkMode ? Colors.grey.shade800 : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      _showHint ? "Answer: $_correctAnswer" : "What is $_currentTable x $_currentMultiplier?",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        foreground: Paint()
                          ..shader = LinearGradient(
                            colors: isDarkMode
                                ? [Colors.yellowAccent, Colors.greenAccent]
                                : [Colors.blue.shade400, Colors.green.shade400],
                          ).createShader(const Rect.fromLTWH(0, 0, 100, 20)),
                        fontFamily: 'Comic Sans MS',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ).animate().scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1.0, 1.0),
                  duration: 400.ms,
                  curve: Curves.easeInOut,
                ),
                const SizedBox(height: 30),
                Column(
                  children: _answerOptions
                      .asMap()
                      .entries
                      .map((entry) => _buildAnswerButton(
                    answer: entry.value,
                    isDarkMode: isDarkMode,
                    themeProvider: themeProvider,
                  ))
                      .toList(),
                ),
                const SizedBox(height: 30),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildHintButton(
                          onTap: () {
                            if (_score > 0) {
                              setState(() {
                                _score--;
                                _showHint = true;
                                _playSound('assets/sounds/cliick.wav');
                                _mascotMessage = "Hint used! Now nail it! 🌟";
                              });
                            } else {
                              showErrorOverlay(
                                context: context,
                                message: "Oops, not enough points for a hint! 😅✨",
                                onDismiss: () => _playSound('assets/sounds/cliick.wav'),
                                tickerProvider: this,
                              );
                            }
                          },
                          isDarkMode: isDarkMode,
                          themeProvider: themeProvider,
                        ),
                        const SizedBox(width: 30),
                        buildRefreshButton(
                          onTap: _resetPractice,
                          isDarkMode: isDarkMode,
                          themeProvider: themeProvider,
                          animationController: _refreshAnimationController,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                if (_feedback.isNotEmpty)
                  Text(
                    _feedback,
                    style: TextStyle(
                      fontSize: 22,
                      color: _feedback.contains('Correct')
                          ? (isDarkMode ? Colors.greenAccent : Colors.green.shade700)
                          : (isDarkMode ? Colors.redAccent : Colors.red.shade700),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Comic Sans MS',
                    ),
                    textAlign: TextAlign.center,
                  ).animate().then(delay: 100.ms).shake(
                    duration: _feedback.contains('Correct') ? 0.ms : 300.ms,
                  ).scale(
                    begin: Offset(_feedback.contains('Correct') ? 0.8 : 1.0, _feedback.contains('Correct') ? 0.8 : 1.0),
                    end: const Offset(1.0, 1.0),
                    duration: _feedback.contains('Correct') ? 200.ms : 0.ms,
                  ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey.shade800 : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode ? Colors.cyanAccent.withAlpha(51) : Colors.black.withAlpha(26),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    _mascotMessage,
                    style: TextStyle(
                      fontSize: 18,
                      color: isDarkMode ? Colors.cyanAccent : Colors.blue.shade600,
                      fontFamily: 'Comic Sans MS',
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ).animate().fadeIn(duration: 600.ms),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _playSound('assets/sounds/cliick.wav');
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: Text(
                  "Pause Practice? ⏸️",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.cyanAccent : Colors.blue.shade600,
                    fontFamily: 'Comic Sans MS',
                  ),
                ),
                content: Text(
                  "Want to take a break or end your practice? Your progress: $_score/$_questionsAnswered!",
                  style: TextStyle(
                    fontSize: 18,
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                    fontFamily: 'Comic Sans MS',
                  ),
                ),
                actions: [
                  buildButton(
                    label: "Continue! 🌟",
                    onTap: () {
                      _playSound('assets/sounds/cliick.wav');
                      Navigator.pop(context);
                    },
                    isDarkMode: isDarkMode,
                    themeProvider: themeProvider,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  buildButton(
                    label: "End Practice! 🚪",
                    onTap: () {
                      _playSound('assets/sounds/cliick.wav');
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    isDarkMode: isDarkMode,
                    themeProvider: themeProvider,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ],
              ),
            );
          },
          backgroundColor: isDarkMode ? Colors.cyanAccent : Colors.blue.shade600,
          child: const Icon(Icons.pause, color: Colors.white),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
}