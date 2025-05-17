import 'dart:async';
import 'package:flutter/material.dart';
import 'package:math_champ/home/table_multiplication/quiz_table/quiz_game.dart';
import 'package:math_champ/home/table_multiplication/quiz_table/set_quiz.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '/main.dart';

class QuizTable extends StatefulWidget {
  const QuizTable({super.key});
  @override
  State<QuizTable> createState() => _QuizTableState();
}

class _QuizTableState extends State<QuizTable> {
  @override
  Widget build(BuildContext context) {
    return const QuizIntroPage();
  }
}

class QuizIntroPage extends StatefulWidget {
  const QuizIntroPage({super.key});
  @override
  _QuizIntroPageState createState() => _QuizIntroPageState();
}

class _QuizIntroPageState extends State<QuizIntroPage> with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  bool _controllerInitialized = false;
  late AudioPlayer _audioPlayer;
  int _videoRetryCount = 0;
  static const int _maxVideoRetries = 3;
  bool _isActive = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initializeAudioPlayer();
    _initializeVideoController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _handleAppLifecycle();
  }

  void _handleAppLifecycle() {
    // Listen for route changes
    ModalRoute.of(context)?.addScopedWillPopCallback(() async {
      _isActive = false;
      return true;
    });
  }

  @override
  void dispose() {
    _isActive = false;
    _audioPlayer.dispose();
    if (_controllerInitialized) {
      _controller.dispose();
      debugPrint(' 🗑️  Disposed VideoPlayerController in QuizIntroPage');
    }
    super.dispose();
  }

  Future<void> _initializeAudioPlayer() async {
    try {
      await _audioPlayer.setVolume(1.0);
      debugPrint('🔊 AudioPlayer initialized in QuizIntroPage');
    } catch (e) {
      debugPrint('❌ AudioPlayer initialization error in QuizIntroPage: $e');
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

  void _initializeVideoController() {
    if (!_controllerInitialized && _videoRetryCount < _maxVideoRetries) {
      _controller = VideoPlayerController.asset('videos/quiz.mp4')
        ..initialize().then((_) {
          if (mounted) {
            setState(() {
              _controllerInitialized = true;
              _controller.setLooping(true);
              _controller.play();
              debugPrint('🎥 Video initialized and playing in QuizIntroPage');
            });
          }
        }).catchError((error) {
          debugPrint('❌ Video initialization error in QuizIntroPage: $error');
          if (mounted) {
            setState(() {
              _controllerInitialized = false;
              _videoRetryCount++;
            });
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted && !_controllerInitialized) {
                debugPrint('🔄 Attempting to reinitialize video controller in QuizIntroPage (Retry $_videoRetryCount/$_maxVideoRetries)');
                _initializeVideoController();
              }
            });
          }
        });
    }
  }

  void _restartVideo() {
    if (_controllerInitialized) {
      _controller.seekTo(Duration.zero);
      _controller.play();
      debugPrint('🔄 Restarted video playback in QuizIntroPage');
    } else {
      _initializeVideoController();
    }
  }

  Future<bool> _onWillPop() async {
    _playSound('assets/sounds/submit.wav');
    bool? shouldExit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const StarCollectorGame(score: 0),
    );
    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    // This listener will trigger when the page becomes visible again
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isActive) {
        _restartVideo();
      }
    });

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
          body: NotificationListener<NavigationNotification>(
            onNotification: (notification) {
              if (notification is UserReturnedNotification) {
                setState(() {
                  _isActive = true;
                  _restartVideo();
                });
              }
              return true;
            },
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        color: isDarkMode ? Colors.grey[900] : Colors.white,
                      ),
                      if (_controllerInitialized)
                        SizedBox.expand(
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: _controller.value.size.width,
                              height: _controller.value.size.height,
                              child: VideoPlayer(_controller),
                            ),
                          ),
                        )
                      else
                        Center(
                          child: CircularProgressIndicator(
                            color: isDarkMode ? Colors.cyanAccent : themeProvider.lightPrimaryColor,
                          ),
                        ),
                    ],
                  ),
                ).animate().fadeIn(duration: 800.ms),
                Expanded(
                  child: Container(
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
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            color: isDarkMode ? Colors.grey.shade800 : Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  Text(
                                    "Quiz Time! 🎉",
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode
                                          ? Colors.cyanAccent
                                          : themeProvider.lightPrimaryColor,
                                      fontFamily: 'Comic Sans MS',
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    "Hey, math superstars! 🌟 Ready for a fun quiz adventure? Pick your favorite multiplication tables, choose how many questions, and test your skills against the clock! 🕒 Every correct answer makes you a multiplication champion! 🏆 Let's dive in!",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: isDarkMode
                                          ? Colors.white70
                                          : Colors.black87,
                                      height: 1.5,
                                      fontFamily: 'Comic Sans MS',
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ).animate().fadeIn(duration: 800.ms).slideY(
                              begin: 0.5, end: 0.0),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: () {
                              _playSound('assets/sounds/cliick.wav');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const QuizSetupPage()),
                              ).then((_) {
                                // This callback runs when we return from QuizSetupPage
                                if (mounted) {
                                  setState(() {
                                    _isActive = true;
                                    _restartVideo();
                                  });
                                }
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              elevation: 10,
                              backgroundColor: Colors.transparent,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isDarkMode
                                      ? [Colors.purpleAccent, Colors.cyanAccent]
                                      : [Colors.orangeAccent, Colors.pinkAccent],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDarkMode
                                        ? Colors.cyanAccent.withAlpha(102)
                                        : Colors.black.withAlpha(51),
                                    blurRadius: 12,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              child: const Text(
                                "Let's Take Quiz! 🎉",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Comic Sans MS',
                                ),
                              ),
                            ),
                          ).animate().scale(
                            begin: const Offset(0.8, 0.8),
                            end: const Offset(1.0, 1.0),
                            duration: 600.ms,
                            curve: Curves.bounceOut,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom notification to detect when user returns to this page
class UserReturnedNotification extends Notification {}

// Helper class to send notifications
class NavigationNotification extends Notification {}