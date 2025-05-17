import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player/video_player.dart';
import 'package:confetti/confetti.dart';
import '/main.dart';
import 'quiz_division/choose_quiz_division.dart';

class QuizDivision extends StatefulWidget {
  const QuizDivision({super.key});

  @override
  _QuizDivisionState createState() => _QuizDivisionState();
}

class _QuizDivisionState extends State<QuizDivision> with TickerProviderStateMixin {
  late VideoPlayerController _videoController;
  late AudioPlayer _audioPlayer;
  late ConfettiController _confettiController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _initializeAudioPlayer();
    _initializeVideoPlayer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confettiController.play();
    });
  }

  Future<void> _initializeAudioPlayer() async {
    try {
      await _audioPlayer.setVolume(1.0);
      debugPrint('🔊 AudioPlayer initialized in QuizDivision');
    } catch (e) {
      debugPrint('❌ AudioPlayer initialization error in QuizDivision: $e');
    }
  }

  Future<void> _initializeVideoPlayer() async {
    _videoController = VideoPlayerController.asset('videos/quiz.mp4')
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
          });
          _videoController.setLooping(true);
          _videoController.play();
          debugPrint('🎥 VideoPlayer initialized in QuizDivision');
        }
      }).catchError((e) {
        debugPrint('❌ VideoPlayer initialization error in QuizDivision: $e');
      });
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

  @override
  void dispose() {
    _videoController.dispose();
    _audioPlayer.dispose();
    _confettiController.dispose();
    debugPrint('🗑️ Disposed VideoPlayer, AudioPlayer, and ConfettiController in QuizDivision');
    super.dispose();
  }

  void _startQuizSetup() {
    _playSound('assets/sounds/cliick.wav');
    _confettiController.play();
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (context, animation, secondaryAnimation) => const ChooseQuizDivision(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    ).then((value) {
      if (value != null && value is Map && value['showGame'] == true && value['module'] == 'division') {
        Navigator.pop(context, value);
      }
      setState(() {
        _isVideoInitialized = false;
        _initializeVideoPlayer();
      });
    });
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
                    ? [themeProvider.darkPrimaryColor, themeProvider.darkSecondaryColor]
                    : [themeProvider.lightPrimaryColor, themeProvider.lightSecondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              _playSound('assets/sounds/cliick.wav');
              Navigator.pop(context, {'showGame': true, 'module': 'division'});
            },
          ),
          title: const Text(
            'Division Quiz Adventure! 🌟',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
              fontFamily: 'Comic Sans MS',
              shadows: [
                Shadow(blurRadius: 10.0, color: Colors.black45, offset: Offset(2.0, 2.0)),
              ],
            ),
          ),
        ),
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDarkMode
                      ? [themeProvider.darkPrimaryColor, themeProvider.darkSecondaryColor]
                      : [
                    themeProvider.lightPrimaryColor.withAlpha(51),
                    themeProvider.lightSecondaryColor.withAlpha(51)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        color: isDarkMode ? Colors.grey.shade800 : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Text(
                                "Get Ready for the Quiz! 🚀",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.cyanAccent : themeProvider.lightPrimaryColor,
                                  fontFamily: 'Comic Sans MS',
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Watch this fun video to learn about division quizzes! Then, set up your quiz by choosing numbers, difficulty, and time. Ready to be a division superstar? Let’s go! 🎉",
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
                      ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.5, end: 0.0),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: isDarkMode ? Colors.cyanAccent.withAlpha(51) : Colors.black.withAlpha(26),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _isVideoInitialized
                              ? AspectRatio(
                            aspectRatio: _videoController.value.aspectRatio,
                            child: VideoPlayer(_videoController),
                          )
                              : Container(
                            height: 200,
                            color: Colors.grey.shade300,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                      ).animate().fadeIn(duration: 600.ms),
                      const SizedBox(height: 40),
                      GestureDetector(
                        onTap: _startQuizSetup,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDarkMode
                                  ? [Colors.green.shade700, Colors.teal.shade700]
                                  : [Colors.green.shade400, Colors.teal.shade400],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: isDarkMode ? Colors.cyanAccent.withAlpha(51) : Colors.black.withAlpha(26),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Text(
                            "Start Quiz Setup! 🌟",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Comic Sans MS',
                            ),
                          ),
                        ),
                      ).animate().fadeIn(duration: 600.ms),
                    ],
                  ),
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
      ),
    );
  }
}