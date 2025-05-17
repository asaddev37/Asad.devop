import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'learn_table/choose_table.dart';
import 'widgets.dart';
import '/main.dart';

class LearnTable extends StatefulWidget {
  const LearnTable({super.key});

  @override
  _LearnTableState createState() => _LearnTableState();
}

class _LearnTableState extends State<LearnTable> {
  late VideoPlayerController _controller;
  bool _controllerInitialized = false;
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initializeAudioPlayer();
    _initializeVideoController();
  }

  Future<void> _initializeAudioPlayer() async {
    try {
      await _audioPlayer.setVolume(1.0);
      debugPrint('🔊 AudioPlayer initialized in LearnTable');
    } catch (e) {
      debugPrint('❌ AudioPlayer initialization error in LearnTable: $e');
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
    if (!_controllerInitialized) {
      _controller = VideoPlayerController.asset('videos/learn.mp4')
        ..initialize().then((_) {
          if (mounted) {
            setState(() {
              _controllerInitialized = true;
              _controller.setLooping(true);
              _controller.play();
              debugPrint('🎥 Video initialized and playing in LearnTable');
            });
          }
        }).catchError((error) {
          debugPrint('❌ Video initialization error in LearnTable: $error');
          if (mounted) {
            setState(() {
              _controllerInitialized = false;
            });
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted && !_controllerInitialized) {
                debugPrint('🔄 Attempting to reinitialize video controller in LearnTable');
                _initializeVideoController();
              }
            });
          }
        });
    }
  }

  void _reloadPage() {
    if (mounted) {
      setState(() {
        // Dispose existing controllers
        if (_controllerInitialized) {
          _controller.dispose();
          debugPrint('🗑️ Disposed VideoPlayerController for reload in LearnTable');
        }
        _audioPlayer.dispose();
        debugPrint('🗑️ Disposed AudioPlayer for reload in LearnTable');

        // Reset initialization state
        _controllerInitialized = false;

        // Reinitialize controllers
        _audioPlayer = AudioPlayer();
        _initializeAudioPlayer();
        _initializeVideoController();
      });
    }
  }

  @override
  void dispose() {
    if (_controllerInitialized) {
      _controller.dispose();
      debugPrint('🗑️ Disposed VideoPlayerController in LearnTable');
    }
    _audioPlayer.dispose();
    debugPrint('🗑️ Disposed AudioPlayer in LearnTable');
    super.dispose();
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
          bodyMedium: TextStyle(color: Colors.white70),
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      )
          : ThemeData.light().copyWith(
        primaryColor: themeProvider.lightPrimaryColor,
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black87),
          titleLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      child: Scaffold(
        body: Column(
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
            ),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        color: isDarkMode ? Colors.grey.shade800 : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Text(
                                "Fun with Multiplication! 🎉",
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
                                "Hey kids! Multiplication is like magic! 🪄 Pick a number and see how it grows with a fun table! Tap the button to start learning! 🌟",
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
                      const SizedBox(height: 30),
                      buildButton(
                        label: "Let's Learn! 🎉",
                        onTap: () async {
                          _playSound('assets/sounds/cliick.wav');
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LearnSetupPage()),
                          );
                          _reloadPage();
                        },
                        isDarkMode: isDarkMode,
                        themeProvider: themeProvider,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}