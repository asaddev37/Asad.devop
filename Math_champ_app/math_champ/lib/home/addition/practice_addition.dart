import 'package:flutter/material.dart';
import 'package:math_champ/home/addition/practice_addition/choose_practice_addition.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player/video_player.dart';
import '/main.dart';


class PracticeAddition extends StatefulWidget {
  const PracticeAddition({super.key});

  @override
  _PracticeAdditionState createState() => _PracticeAdditionState();
}

class _PracticeAdditionState extends State<PracticeAddition> {
  late AudioPlayer _audioPlayer;
  late VideoPlayerController _videoController;

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
      debugPrint('🔊 AudioPlayer initialized in PracticeAddition');
    } catch (e) {
      debugPrint('❌ AudioPlayer initialization error in PracticeAddition: $e');
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
    _videoController = VideoPlayerController.asset('videos/practice.mp4')
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _videoController.setLooping(true);
            _videoController.play();
            debugPrint('🎥 VideoPlayer initialized in PracticeAddition');
          });
        }
      }).catchError((e) {
        debugPrint('❌ VideoPlayer initialization error in PracticeAddition: $e');
      });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _videoController.dispose();
    debugPrint('🗑️ Disposed AudioPlayer and VideoPlayer in PracticeAddition');
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
              Navigator.pop(context);
            },
          ),
          title: const Text(
            'Practice Addition! 🌟',
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
                            "Get Ready to Practice Addition! 🎉",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.cyanAccent : themeProvider.lightPrimaryColor,
                              fontFamily: 'Comic Sans MS',
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          _videoController.value.isInitialized
                              ? AspectRatio(
                            aspectRatio: _videoController.value.aspectRatio,
                            child: VideoPlayer(_videoController),
                          )
                              : Container(
                            height: 200,
                            color: Colors.grey.shade300,
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Watch the video above to refresh your addition skills! Then, tap the button below to choose your practice numbers and start solving fun addition problems. Let’s become addition superstars! 🌟",
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
                  GestureDetector(
                    onTap: () {
                      _playSound('assets/sounds/cliick.wav');
                      _videoController.pause();
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 800),
                          pageBuilder: (context, animation, secondaryAnimation) => const ChoosePracticeAddition(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.easeInOut;
                            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                            var offsetAnimation = animation.drive(tween);
                            return SlideTransition(position: offsetAnimation, child: child);
                          },
                        ),
                      ).then((_) {
                        setState(() {
                          _initializeVideoPlayer();
                        });
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDarkMode
                              ? [Colors.blue.shade700, Colors.purple.shade700]
                              : [Colors.blue.shade400, Colors.purple.shade400],
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
                        "Choose Numbers! 🌟",
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
      ),
    );
  }
}