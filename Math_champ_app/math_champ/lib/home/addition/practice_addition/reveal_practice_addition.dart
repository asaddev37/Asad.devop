import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flip_card/flip_card.dart';
import '../../table_multiplication/widgets.dart';
import '/main.dart';
import 'choose_practice_addition.dart';

class RevealPracticeAddition extends StatefulWidget {
  final int startNumber;
  final int endNumber;
  final int questionCount;
  final Difficulty difficulty;

  const RevealPracticeAddition({
    super.key,
    required this.startNumber,
    required this.endNumber,
    required this.questionCount,
    required this.difficulty,
  });

  @override
  _RevealPracticeAdditionState createState() => _RevealPracticeAdditionState();
}

class _RevealPracticeAdditionState extends State<RevealPracticeAddition> with TickerProviderStateMixin {
  final List<Map<String, dynamic>> _questions = [];
  late AudioPlayer _audioPlayer;
  late ConfettiController _confettiController;
  late AnimationController _refreshAnimationController;
  String _mascotMessage = "Solve the addition problems, champ! 🌟";
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _questionsAnswered = 0;
  bool _isFlipped = false;
  bool _showHint = false;
  int? _selectedAnswer;
  List<int> _answerOptions = [];
  final List<String> _questionHistory = [];

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
    _generateQuestions();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playSound('assets/sounds/start.wav');
      showErrorOverlay(
        context: context,
        message: "Time to practice addition! 🚀 Tap an answer to check! 🌟",
        onDismiss: () => _playSound('assets/sounds/cliick.wav'),
        tickerProvider: this,
      );
    });
  }

  Future<void> _initializeAudioPlayer() async {
    try {
      await _audioPlayer.setVolume(1.0);
      debugPrint('🔊 AudioPlayer initialized in RevealPracticeAddition');
    } catch (e) {
      debugPrint('❌ AudioPlayer initialization error in RevealPracticeAddition: $e');
    }
  }

  Future<void> _playSound(String assetPath) async {
    try {
      unawaited(_audioPlayer.stop());  // Don't await this
      await _audioPlayer.setAsset(assetPath);
      unawaited(_audioPlayer.play());  // Don't await playback
      debugPrint('🔊 Playing sound: $assetPath');
    } catch (e) {
      debugPrint('❌ Error playing sound $assetPath: $e');
    }
  }

  void _generateQuestions() {
    final random = Random();
    _questions.clear();
    _questionHistory.clear();

    List<Map<String, dynamic>> possibleQuestions = [];
    for (int addend1 = widget.endNumber; addend1 <= widget.startNumber; addend1++) {
      for (int addend2 = widget.endNumber; addend2 <= widget.startNumber; addend2++) {
        int sum = addend1 + addend2;
        if (sum <= widget.startNumber && sum >= widget.endNumber) {
          if (widget.difficulty == Difficulty.easy ||
              (widget.difficulty == Difficulty.medium && sum >= 10) ||
              (widget.difficulty == Difficulty.hard && sum >= 20)) {
            possibleQuestions.add({
              'question': '$addend1 + $addend2 = ?',
              'answer': sum,
              'weight': widget.difficulty == Difficulty.hard
                  ? sum / widget.startNumber
                  : widget.difficulty == Difficulty.medium
                  ? sum / 10
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

    if (_questions.isEmpty) {
      showErrorOverlay(
        context: context,
        message: 'No questions available! Try a bigger range! 🌟',
        onDismiss: () => _playSound('assets/sounds/cliick.wav'),
        tickerProvider: this,
      );
    } else {
      _generateAnswerOptions();
    }
  }

  void _generateAnswerOptions() {
    if (_currentQuestionIndex >= _questions.length) return;
    final random = Random();
    final correctAnswer = _questions[_currentQuestionIndex]['answer'] as int;
    setState(() {
      _answerOptions = [correctAnswer];
      while (_answerOptions.length < 4) {
        int deviation = correctAnswer <= 10 ? random.nextInt(3) + 1 : random.nextInt(5) + 2;
        int randomAnswer = random.nextBool() ? correctAnswer + deviation : max(1, correctAnswer - deviation);
        if (!_answerOptions.contains(randomAnswer)) {
          _answerOptions.add(randomAnswer);
        }
      }
      _answerOptions.shuffle();
      _isFlipped = false;
      _selectedAnswer = null;
      _showHint = false;
      _mascotMessage = "Solve this addition, champ! 🌟";
    });
  }

  void _checkAnswer(int selectedAnswer) {
    final correctAnswer = _questions[_currentQuestionIndex]['answer'] as int;
    setState(() {
      _isFlipped = true;
      _selectedAnswer = selectedAnswer;
      _questionsAnswered++;
      if (selectedAnswer == correctAnswer) {
        _score++;
        _mascotMessage = "Great job, champ! 🌟";
        _playSound('assets/sounds/correct.wav');
        _confettiController.play();
      } else {
        _mascotMessage = "Oops, try again next time! 🌟";
        _playSound('assets/sounds/incorrect.wav');
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _currentQuestionIndex++;
          if (_currentQuestionIndex >= _questions.length) {
            _showCompletionDialog();
          } else {
            _generateAnswerOptions();
          }
        });
      }
    });
  }

  void _resetPractice() {
    setState(() {
      _score = 0;
      _questionsAnswered = 0;
      _currentQuestionIndex = 0;
      _mascotMessage = "Solve the addition problems, champ! 🌟";
      _questions.clear();
      _questionHistory.clear();
      _answerOptions.clear();
    });
    _refreshAnimationController.forward(from: 0.0).then((_) {
      if (mounted) {
        _generateQuestions();
      }
    });
    _playSound('assets/sounds/refresh.wav');
  }

  void _showCompletionDialog() {
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
                "You're an Addition Superstar! 🎉",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.cyanAccent : Colors.purple.shade600,
                  fontFamily: 'Comic Sans MS',
                ),
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "You answered $_questionsAnswered questions!\nScore: $_score",
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
                  onPressed: () async {
                    await _playSound('assets/sounds/cliick.wav');
                    if (mounted) {
                      Navigator.pop(context);
                    }
                    _resetPractice();
                  },
                  child: Text(
                    "Restart",
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.cyanAccent : Colors.purple.shade600,
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
                    "Choose New Numbers",
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.cyanAccent : Colors.purple.shade600,
                      fontFamily: 'Comic Sans MS',
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _playSound('assets/sounds/cliick.wav');
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.pop(context, {'showGame': true, 'module': 'addition'});
                  },
                  child: Text(
                    "Back to Addition",
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.cyanAccent : Colors.purple.shade600,
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

  Future<bool> _onWillPop() async {
    await _playSound('assets/sounds/cliick.wav');
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finish Practicing? 🚪'),
        content: const Text('Are you sure you want to leave this addition practice? 🌟'),
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

  Widget _buildProgressTracker({required bool isDarkMode}) {
    return Column(
      children: [
        Text(
          "Progress: $_questionsAnswered/${widget.questionCount}",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.cyanAccent : Colors.purple.shade600,
            fontFamily: 'Comic Sans MS',
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: _questionsAnswered / widget.questionCount,
            backgroundColor: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation(isDarkMode ? Colors.cyanAccent : Colors.purple.shade600),
            minHeight: 10,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildAnswerButton({
    required int answer,
    required bool isDarkMode,
  }) {
    bool isCorrect = answer == (_questions[_currentQuestionIndex]['answer'] as int);
    bool isSelected = _selectedAnswer == answer;
    bool showFeedback = _isFlipped && isSelected;

    return GestureDetector(
      onTap: () {
        if (!_isFlipped) {
          _checkAnswer(answer);
        }
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
                ? [Colors.purple.shade700, Colors.cyan.shade700]
                : [Colors.purple.shade400, Colors.cyan.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? Colors.cyanAccent.withOpacity(0.3) : Colors.black.withOpacity(0.2),
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
                          "Addition Practice Fun! 🚀",
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
                          right: 16,
                          top: 45,
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
                            child: const Icon(Icons.star, color: Colors.yellow, size: 41),
                          ).animate().shake(duration: 200.ms, hz: 1),
                        ),
                        Positioned(
                          left: 16,
                          top: 43,
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.5,
                              minWidth: 120,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDarkMode
                                    ? [Colors.cyanAccent.withOpacity(0.9), Colors.blueAccent.withOpacity(0.9)]
                                    : [Colors.yellow.shade200, Colors.pink.shade200],
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
                                color: isDarkMode ? Colors.cyanAccent : Colors.pink.shade400,
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
                                        : [Colors.purple.shade600, Colors.blue.shade600],
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
                    ).animate().fadeIn(duration: 800.ms),
                    const SizedBox(height: 20),
                    _buildProgressTracker(isDarkMode: isDarkMode),
                    const SizedBox(height: 20),
                    Text(
                      "Score: $_score",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.cyanAccent : Colors.purple.shade600,
                        fontFamily: 'Comic Sans MS',
                      ),
                    ).animate().fadeIn(duration: 600.ms),
                    const SizedBox(height: 20),
                    if (_currentQuestionIndex < _questions.length)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: FlipCard(
                          fill: Fill.fillBack,
                          direction: FlipDirection.HORIZONTAL,
                          flipOnTouch: false,
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
                                    "Question ${_currentQuestionIndex + 1}/${_questions.length}",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode ? Colors.cyanAccent : Colors.white,
                                      fontFamily: 'Comic Sans MS',
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _showHint
                                        ? "Answer: ${_questions[_currentQuestionIndex]['answer']}"
                                        : _questions[_currentQuestionIndex]['question'],
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
                                  const SizedBox(height: 20),
                                  Column(
                                    children: _answerOptions
                                        .asMap()
                                        .entries
                                        .map((entry) => _buildAnswerButton(
                                      answer: entry.value,
                                      isDarkMode: isDarkMode,
                                    ))
                                        .toList(),
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
                                    "Answer ${_currentQuestionIndex + 1}",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode ? Colors.cyanAccent : Colors.white,
                                      fontFamily: 'Comic Sans MS',
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "${_questions[_currentQuestionIndex]['answer']}",
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
                        ).animate().scale(
                          begin: const Offset(0.9, 0.9),
                          end: const Offset(1.0, 1.0),
                          duration: 400.ms,
                          curve: Curves.easeInOut,
                        ),
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
                              onTap: () async {
                                if (_score > 0) {
                                  unawaited(_playSound('assets/sounds/submit.wav'));
                                  if (mounted) {
                                    setState(() {
                                      _score--;
                                      _showHint = true;
                                    });
                                  }
                                } else {
                                  unawaited(_playSound('assets/sounds/start.wav'));
                                  showErrorOverlay(
                                    context: context,
                                    message: "Oops, not enough points for a hint! 😅✨",
                                    onDismiss: () async => unawaited(_playSound('assets/sounds/cliick.wav')),
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
                  ],
                ),
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
                      color: isDarkMode ? Colors.cyanAccent : Colors.purple.shade600,
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
            backgroundColor: isDarkMode ? Colors.cyanAccent : Colors.purple.shade600,
            child: const Icon(Icons.pause, color: Colors.white),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    OverlayEntry? overlayEntry;
    final animationController = AnimationController(
      vsync: tickerProvider,
      duration: const Duration(milliseconds: 600),
    );

    overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          ModalBarrier(
            color: Colors.black.withAlpha(77),
            dismissible: false,
          ),
          Center(
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                CurvedAnimation(parent: animationController, curve: Curves.bounceOut),
              ),
              child: FadeTransition(
                opacity: animationController,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDarkMode
                          ? [Colors.purpleAccent, Colors.cyanAccent]
                          : [Colors.yellow.shade200, Colors.pink.shade200],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode ? Colors.cyanAccent.withAlpha(102) : Colors.black.withAlpha(51),
                        blurRadius: 12,
                        spreadRadius: 3,
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
                          fontWeight: FontWeight.bold,
                          foreground: Paint()
                            ..shader = LinearGradient(
                              colors: isDarkMode
                                  ? [Colors.yellowAccent, Colors.greenAccent]
                                  : [Colors.purple.shade600, Colors.blue.shade600],
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
                          animationController.reverse().then((_) {
                            overlayEntry?.remove();
                            animationController.dispose();
                          });
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
          ),
        ],
      ),
    );

    _playSound('assets/sounds/cliick.wav');
    Overlay.of(context).insert(overlayEntry);
    animationController.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry != null && overlayEntry.mounted) {
        animationController.reverse().then((_) {
          overlayEntry?.remove();
          animationController.dispose();
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _confettiController.dispose();
    _refreshAnimationController.dispose();
    debugPrint('🗑️ Disposed AudioPlayer, ConfettiController, and AnimationController in RevealPracticeAddition');
    super.dispose();
  }
}