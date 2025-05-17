import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:numberpicker/numberpicker.dart';
import '../../table_multiplication/widgets.dart';
import '/main.dart';
import 'reveal_quiz_addition.dart';

enum Difficulty { easy, medium, hard }

class QuizSetupAddition extends StatefulWidget {
  const QuizSetupAddition({super.key});

  @override
  _QuizSetupAdditionState createState() => _QuizSetupAdditionState();
}

class _QuizSetupAdditionState extends State<QuizSetupAddition> with TickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  late ConfettiController _confettiController;
  int _largestNumber = 10;
  int _smallestNumber = 5;
  int _questionCount = 5;
  int _timePerQuestion = 5;
  int _maxQuestions = 1;
  Difficulty _difficulty = Difficulty.easy;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _initializeAudioPlayer();
    _updateMaxQuestions();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confettiController.play();
      _playSound('assets/sounds/pop.wav');
    });
  }

  Future<void> _initializeAudioPlayer() async {
    try {
      await _audioPlayer.setVolume(1.0);
      debugPrint('🔊 AudioPlayer initialized in QuizSetupAddition');
    } catch (e) {
      debugPrint('❌ AudioPlayer initialization error in QuizSetupAddition: $e');
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

  void _updateMaxQuestions() {
    int count = 0;
    for (int addend1 = _smallestNumber; addend1 <= _largestNumber; addend1++) {
      for (int addend2 = _smallestNumber; addend2 <= _largestNumber - addend1; addend2++) {
        int sum = addend1 + addend2;
        if (sum <= _largestNumber && sum >= _smallestNumber) {
          if (_difficulty == Difficulty.easy ||
              (_difficulty == Difficulty.medium && sum >= 10) ||
              (_difficulty == Difficulty.hard && sum >= 20)) {
            count++;
          }
        }
      }
    }
    setState(() {
      _maxQuestions = count < 1 ? 1 : count;
      if (_questionCount > _maxQuestions) {
        _questionCount = _maxQuestions;
      }
    });
  }

  void _updateNumberRanges() {
    setState(() {
      if (_difficulty == Difficulty.easy) {
        _largestNumber = _largestNumber.clamp(5, 20);
        _smallestNumber = _smallestNumber.clamp(1, 15);
        _timePerQuestion = _timePerQuestion.clamp(5, 10);
      } else if (_difficulty == Difficulty.medium) {
        _largestNumber = _largestNumber < 20 ? 20 : _largestNumber.clamp(20, 50);
        _smallestNumber = _smallestNumber < 5 ? 5 : _smallestNumber.clamp(5, 45);
        _timePerQuestion = _timePerQuestion.clamp(4, 10);
      } else {
        _largestNumber = _largestNumber < 50 ? 50 : _largestNumber.clamp(50, 100);
        _smallestNumber = _smallestNumber < 10 ? 10 : _smallestNumber.clamp(10, 90);
        _timePerQuestion = _timePerQuestion.clamp(3, 10);
      }
      _questionCount = _questionCount.clamp(1, _maxQuestions);
      _updateMaxQuestions();
    });
  }

  Future<bool> _onWillPop() async {
    await _playSound('assets/sounds/cliick.wav');
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Quiz Setup? 🚪'),
        content: const Text('Are you sure you want to leave without starting your addition quiz? 🌟'),
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

  void _validateAndProceed() {
    if (_largestNumber <= _smallestNumber) {
      _playSound('assets/sounds/cliick.wav');
      showErrorOverlay(
        context: context,
        message: 'The largest number must be greater than the smallest number! 🌟 Try again!',
        onDismiss: () => _playSound('assets/sounds/cliick.wav'),
        tickerProvider: this,
      );
      return;
    }
    if (_smallestNumber < 1) {
      _playSound('assets/sounds/cliick.wav');
      showErrorOverlay(
        context: context,
        message: 'The smallest number must be at least 1! 🌟',
        onDismiss: () => _playSound('assets/sounds/cliick.wav'),
        tickerProvider: this,
      );
      return;
    }
    if (_questionCount > _maxQuestions) {
      _playSound('assets/sounds/cliick.wav');
      showErrorOverlay(
        context: context,
        message: 'Oops! Pick a larger range or fewer questions to continue! 🌟',
        onDismiss: () => _playSound('assets/sounds/cliick.wav'),
        tickerProvider: this,
      );
      return;
    }
    if (_timePerQuestion < 3) {
      _playSound('assets/sounds/cliick.wav');
      showErrorOverlay(
        context: context,
        message: 'Set at least 3 seconds per question! 🌟',
        onDismiss: () => _playSound('assets/sounds/cliick.wav'),
        tickerProvider: this,
      );
      return;
    }
    _playSound('assets/sounds/start.wav');
    _confettiController.play();
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (context, animation, secondaryAnimation) => RevealQuizAddition(
          startNumber: _largestNumber,
          endNumber: _smallestNumber,
          difficulty: _difficulty,
          questionCount: _questionCount,
          timePerQuestion: _timePerQuestion,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _confettiController.dispose();
    debugPrint('🗑️ Disposed AudioPlayer and ConfettiController in QuizSetupAddition');
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
                    ? [Colors.blue.shade700, Colors.green.shade700]
                    : [Colors.blue.shade300.withAlpha(51), Colors.green.shade300.withAlpha(51)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          "Addition Quiz Setup! 🌟",
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.cyanAccent : Colors.blue.shade600,
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
                            child: const Icon(Icons.star, color: Colors.yellow, size: 45),
                          ).animate().shake(duration: 2000.ms, hz: 1),
                        ),
                        Positioned(
                          right: 80,
                          top: 59,
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
                              _difficulty == Difficulty.easy
                                  ? "Easy quiz, 5+ sec per question! 🌟"
                                  : _difficulty == Difficulty.medium
                                  ? "Medium quiz, 4+ sec per question! 🚀"
                                  : "Hard quiz, 3+ sec per question! 💪",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue.shade700,
                                fontFamily: 'Comic Sans MS',
                              ),
                            ),
                          ).animate().fadeIn(duration: 1000.ms),
                        ),
                      ],
                    ).animate().fadeIn(duration: 800.ms),
                    const SizedBox(height: 20),
                    Card(
                      elevation: 12,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      color: isDarkMode ? Colors.grey.shade800 : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              "Pick Your Difficulty!",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.cyanAccent : Colors.blue.shade600,
                                fontFamily: 'Comic Sans MS',
                              ),
                            ),
                            const SizedBox(height: 12),
                            SegmentedButton<Difficulty>(
                              segments: const [
                                ButtonSegment(
                                  value: Difficulty.easy,
                                  label: Text('Easy', style: TextStyle(fontFamily: 'Comic Sans MS')),
                                  icon: Icon(Icons.star_border),
                                ),
                                ButtonSegment(
                                  value: Difficulty.medium,
                                  label: Text('Medium', style: TextStyle(fontFamily: 'Comic Sans MS')),
                                  icon: Icon(Icons.star_half),
                                ),
                                ButtonSegment(
                                  value: Difficulty.hard,
                                  label: Text('Hard', style: TextStyle(fontFamily: 'Comic Sans MS')),
                                  icon: Icon(Icons.star),
                                ),
                              ],
                              selected: {_difficulty},
                              onSelectionChanged: (newSelection) {
                                _playSound('assets/sounds/pop.wav');
                                setState(() {
                                  _difficulty = newSelection.first;
                                  _updateNumberRanges();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ).animate()
                        .fadeIn(duration: 800.ms)
                        .then()
                        .rotate(
                      begin: -0.1,  // Starts slightly rotated (about 5.7 degrees)
                      end: 0.0,     // Ends straight
                      duration: 1000.ms,  // Takes 1 second to straighten
                      curve: Curves.easeInOut,
                    ),
                    const SizedBox(height: 20),
                    Card(
                      elevation: 12,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      color: isDarkMode ? Colors.grey.shade800 : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Text(
                              "Set Up Your Quiz!",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.cyanAccent : Colors.blue.shade600,
                                fontFamily: 'Comic Sans MS',
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Choose your numbers, questions, and time per question. Get ready for a fun addition quiz! 🚀",
                              style: TextStyle(
                                fontSize: 16,
                                color: isDarkMode ? Colors.white70 : Colors.black87,
                                fontFamily: 'Comic Sans MS',
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ).animate()
                        .fadeIn(duration: 800.ms)
                        .then()
                        .rotate(
                      begin: -0.1,  // Starts slightly rotated (about 5.7 degrees)
                      end: 0.0,     // Ends straight
                      duration: 1000.ms,  // Takes 1 second to straighten
                      curve: Curves.easeInOut,
                    ),
                    const SizedBox(height: 20),
                    _buildNumberPicker(
                      label: 'Largest Number',
                      value: _largestNumber,
                      minValue: _difficulty == Difficulty.easy
                          ? 5
                          : _difficulty == Difficulty.medium
                          ? 20
                          : 50,
                      maxValue: _difficulty == Difficulty.easy
                          ? 20
                          : _difficulty == Difficulty.medium
                          ? 50
                          : 100,
                      onChanged: (value) {
                        _playSound('assets/sounds/pop.wav');
                        setState(() {
                          _largestNumber = value;
                          _updateMaxQuestions();
                        });
                      },
                      gradientColors: [Colors.blue.shade400, Colors.cyan.shade400],
                    ),
                    const SizedBox(height: 16),
                    _buildNumberPicker(
                      label: 'Smallest Number',
                      value: _smallestNumber,
                      minValue: _difficulty == Difficulty.easy
                          ? 1
                          : _difficulty == Difficulty.medium
                          ? 5
                          : 10,
                      maxValue: _difficulty == Difficulty.easy
                          ? 15
                          : _difficulty == Difficulty.medium
                          ? 45
                          : 90,
                      onChanged: (value) {
                        _playSound('assets/sounds/pop.wav');
                        setState(() {
                          _smallestNumber = value;
                          _updateMaxQuestions();
                        });
                      },
                      gradientColors: [Colors.green.shade400, Colors.lime.shade400],
                    ),
                    const SizedBox(height: 16),
                    _buildNumberPicker(
                      label: 'Number of Questions',
                      value: _questionCount,
                      minValue: 1,
                      maxValue: _maxQuestions,
                      onChanged: (value) {
                        _playSound('assets/sounds/pop.wav');
                        setState(() {
                          _questionCount = value;
                        });
                      },
                      gradientColors: [Colors.orange.shade400, Colors.red.shade400],
                    ),
                    const SizedBox(height: 16),
                    _buildNumberPicker(
                      label: 'Time per Question (sec)',
                      value: _timePerQuestion,
                      minValue: _difficulty == Difficulty.easy
                          ? 5
                          : _difficulty == Difficulty.medium
                          ? 4
                          : 3,
                      maxValue: 10,
                      onChanged: (value) {
                        _playSound('assets/sounds/pop.wav');
                        setState(() {
                          _timePerQuestion = value;
                        });
                      },
                      gradientColors: [Colors.purple.shade400, Colors.pink.shade400],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.cyanAccent.withOpacity(0.2) : Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDarkMode ? Colors.cyanAccent : Colors.blue.shade600),
                      ),
                      child: Text(
                        'Up to $_maxQuestions questions available!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.cyanAccent : Colors.blue.shade800,
                          fontFamily: 'Comic Sans MS',
                        ),
                      ),
                    ).animate().fadeIn(duration: 600.ms),
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
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: isDarkMode ? Colors.cyanAccent.withOpacity(0.5) : Colors.blue.shade300.withOpacity(0.5),
                                blurRadius: 12,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: buildButton(
                            label: 'Start Quiz! 🚀',
                            onTap: _validateAndProceed,
                            isDarkMode: isDarkMode,
                            themeProvider: themeProvider,
                          ),
                        ).animate().scale(
                          begin: const Offset(0.9, 0.9),
                          end: const Offset(1.0, 1.0),
                          duration: 600.ms,
                          curve: Curves.bounceOut,
                        ),
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

  Widget _buildNumberPicker({
    required String label,
    required int value,
    required int minValue,
    required int maxValue,
    required ValueChanged<int> onChanged,
    required List<Color> gradientColors,
  }) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final safeValue = value.clamp(minValue, maxValue);
    if (value != safeValue) {
      debugPrint('⚠️ NumberPicker value adjusted: $value -> $safeValue for $label');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorOverlay(
          context: context,
          message: 'Oops! Adjusted $label to match the ${_difficulty.toString().split('.').last} difficulty! 🌟 Try again!',
          onDismiss: () => _playSound('assets/sounds/cliick.wav'),
          tickerProvider: this,
        );
      });
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.cyanAccent.withOpacity(0.3) : Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Comic Sans MS',
              shadows: [
                Shadow(
                  blurRadius: 6,
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(1, 1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          NumberPicker(
            value: safeValue,
            minValue: minValue,
            maxValue: maxValue,
            step: 1,
            itemHeight: 60,
            itemWidth: 100,
            textStyle: TextStyle(
              fontSize: 24,
              color: isDarkMode ? Colors.white70 : Colors.black87,
              fontFamily: 'Comic Sans MS',
            ),
            selectedTextStyle: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.yellow.shade300,
              fontFamily: 'Comic Sans MS',
              shadows: [
                Shadow(
                  blurRadius: 8,
                  color: Colors.black.withOpacity(0.4),
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.yellow.shade300, width: 3),
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.1)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            onChanged: onChanged,
            zeroPad: true,
          ),
        ],
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
        .rotate(begin: 0.05, end: 0.0, duration: 100.ms, curve: Curves.easeInOut);
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