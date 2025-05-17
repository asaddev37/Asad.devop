import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../table_multiplication/widgets.dart';
import '/main.dart';
import 'practice_division/choose_practice_division.dart';

class PracticeDivision extends StatefulWidget {
  const PracticeDivision({super.key});

  @override
  _PracticeDivisionState createState() => _PracticeDivisionState();
}

class _PracticeDivisionState extends State<PracticeDivision> {
  late AudioPlayer _audioPlayer;
  late VideoPlayerController _videoController;
  bool _controllerInitialized = false;
  int _videoRetryCount = 0;
  static const int _maxVideoRetries = 3;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initializeAudioPlayer();
    _initializeVideoPlayer();
  }

  Future<void> _initializeAudioPlayer() async {
    try {
      await _audioPlayer.setVolume(1.0);
      debugPrint('🔊 AudioPlayer initialized in PracticeDivision');
    } catch (e) {
      debugPrint('❌ AudioPlayer initialization error in PracticeDivision: $e');
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

  void _initializeVideoPlayer() {
    if (!_controllerInitialized && _videoRetryCount < _maxVideoRetries) {
      _videoController = VideoPlayerController.asset('videos/practice.mp4')
        ..initialize().then((_) {
          if (mounted) {
            setState(() {
              _controllerInitialized = true;
              _videoController.setLooping(true);
              _videoController.play();
              debugPrint('🎥 VideoPlayer initialized in PracticeDivision');
            });
          }
        }).catchError((e) {
          debugPrint('❌ VideoPlayer initialization error in PracticeDivision: $e');
          if (mounted) {
            setState(() {
              _controllerInitialized = false;
              _videoRetryCount++;
            });
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted && !_controllerInitialized) {
                debugPrint('🔄 Attempting to reinitialize video controller in PracticeDivision (Retry $_videoRetryCount/$_maxVideoRetries)');
                _initializeVideoPlayer();
              }
            });
          }
        });
    }
  }

  void _resetVideoController() {
    if (_controllerInitialized) {
      _videoController.dispose();
      _controllerInitialized = false;
      _videoRetryCount = 0;
      debugPrint('🔄 Resetting video controller in PracticeDivision');
      _initializeVideoPlayer();
    }
  }

  Future<bool> _onWillPop() async {
    await _playSound('assets/sounds/cliick.wav');
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Practice? 🚪'),
        content: const Text('Are you sure you want to leave your division practice adventure? 🌟'),
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

  @override
  void dispose() {
    _audioPlayer.dispose();
    if (_controllerInitialized) {
      _videoController.dispose();
      debugPrint('🗑️ Disposed VideoPlayerController in PracticeDivision');
    }
    debugPrint('🗑️ Disposed AudioPlayer in PracticeDivision');
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
              onPressed: () async {
                if (await _onWillPop()) {
                  _playSound('assets/sounds/cliick.wav');
                  Navigator.pop(context);
                }
              },
            ),
            title: const Text(
              'Practice Division! 🌟',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Comic Sans MS',
                shadows: [
                  Shadow(blurRadius: 10.0, color: Colors.black45, offset: Offset(2.0, 2.0)),
                ],
              ),
            ),
          ),
          body: Container(
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: Column(
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
                              "Get Ready to Practice Division! 🎉",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.cyanAccent : themeProvider.lightPrimaryColor,
                                fontFamily: 'Comic Sans MS',
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            _controllerInitialized
                                ? AspectRatio(
                              aspectRatio: _videoController.value.aspectRatio,
                              child: VideoPlayer(_videoController),
                            )
                                : Container(
                              height: 200,
                              color: Colors.grey.shade300,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: isDarkMode ? Colors.cyanAccent : themeProvider.lightPrimaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Watch the video above to refresh your division skills! Then, tap the button below to choose your numbers and start solving fun division problems. Let’s become division superstars! 🌟",
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
                    buildButton(
                      label: "Choose Numbers! 🌟",
                      onTap: () {
                        _playSound('assets/sounds/cliick.wav');
                        if (_controllerInitialized) {
                          _videoController.pause();
                        }
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: const Duration(milliseconds: 800),
                            pageBuilder: (context, animation, secondaryAnimation) => const ChoosePracticeDivision(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.easeInOut;
                              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                              var offsetAnimation = animation.drive(tween);
                              return SlideTransition(position: offsetAnimation, child: child);
                            },
                          ),
                        ).then((_) => _resetVideoController());
                      },
                      isDarkMode: isDarkMode,
                      themeProvider: themeProvider,
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
}