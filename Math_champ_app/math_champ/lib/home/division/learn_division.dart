import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../table_multiplication/widgets.dart';
import '/main.dart';
import 'learn_division/choose_division.dart';


class LearnDivision extends StatefulWidget {
  const LearnDivision({super.key});

  @override
  _LearnDivisionState createState() => _LearnDivisionState();
}

class _LearnDivisionState extends State<LearnDivision> with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  bool _controllerInitialized = false;
  late AudioPlayer _audioPlayer;
  int _videoRetryCount = 0;
  static const int _maxVideoRetries = 3;

  @override
  bool get wantKeepAlive => true;

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
      debugPrint('🔊 AudioPlayer initialized in LearnDivision');
    } catch (e) {
      debugPrint('❌ AudioPlayer initialization error in LearnDivision: $e');
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
      _controller = VideoPlayerController.asset('videos/learn.mp4')
        ..initialize().then((_) {
          if (mounted) {
            setState(() {
              _controllerInitialized = true;
              _controller.setLooping(true);
              _controller.play();
              debugPrint('🎥 Video initialized and playing in LearnDivision');
            });
          }
        }).catchError((error) {
          debugPrint('❌ Video initialization error in LearnDivision: $error');
          if (mounted) {
            setState(() {
              _controllerInitialized = false;
              _videoRetryCount++;
            });
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted && !_controllerInitialized) {
                debugPrint('🔄 Attempting to reinitialize video controller in LearnDivision (Retry $_videoRetryCount/$_maxVideoRetries)');
                _initializeVideoController();
              }
            });
          }
        });
    }
  }

  void _resetVideoController() {
    if (_controllerInitialized) {
      _controller.dispose();
      _controllerInitialized = false;
      _videoRetryCount = 0;
      debugPrint('🔄 Resetting video controller in LearnDivision');
      _initializeVideoController();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (mounted && !_controllerInitialized) {
      _initializeVideoController();
    } else {
      _ensureVideoPlaying();
    }
  }

  void _ensureVideoPlaying() {
    if (mounted && _controllerInitialized && !_controller.value.isPlaying) {
      _controller.play();
      debugPrint('▶️ Restarted video playback in LearnDivision');
    }
  }

  Future<bool> _onWillPop() async {
    await _playSound('assets/sounds/cliick.wav');
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Learning? 🚪'),
        content: const Text('Are you sure you want to leave this division adventure? 🌟'),
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
      _controller.dispose();
      debugPrint('🗑️ Disposed VideoPlayerController in LearnDivision');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    _ensureVideoPlaying();

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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          color: isDarkMode ? Colors.grey.shade800 : Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Text(
                                  "Learn Division! 🎉",
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
                                  "Hey, math champs! 🌟 Division is like sharing candies equally among friends—how many does each get? Watch the fun video and start your division adventure to become a superstar! 🚀",
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
                          label: "Let's Learn Division! 🎉",
                          onTap: () {
                            _playSound('assets/sounds/cliick.wav');
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                transitionDuration: const Duration(milliseconds: 800),
                                pageBuilder: (context, animation, secondaryAnimation) => const ChooseDivision(),
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
            ],
          ),
        ),
      ),
    );
  }
}