import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'home/addition.dart';
import 'home/division.dart';
import 'home/menu/setting.dart';
import 'home/multiplication_game.dart';
import 'home/subtraction.dart';
import 'home/game_subtraction.dart';
import 'home/game_addition.dart';
import 'home/game_division.dart';
import 'home/table_multiplication.dart';
import '../main.dart';
import 'home_animation.dart';
import 'dart:async';

// Home widget, serves as the main screen for the Math Champ app
class Home extends StatefulWidget {
  const Home({super.key});
  @override
  _HomeState createState() => _HomeState();
}

// State class for Home widget, manages UI and audio
class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AudioPlayer _audioPlayer;
  late AnimationController _animationController;
  final List<MathSymbol> _symbols = []; // List of math symbols for light mode animations
  final List<Bubble> _bubbles = []; // List of bubbles for dark mode animations
  final List<Particle> _particles = []; // List of particles for burst effects
  double _symbolTimer = 0; // Timer for controlling symbol animations
  double _bubblePopTimer = 0; // Timer for controlling bubble animations
  final List<String> _soundQueue = []; // Queue for sound playback
  bool _isPlayingSound = false; // Flag to prevent concurrent playback
  bool _hasShownGame = false; // Flag to prevent repeated game modal

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer(); // Initialize audio player for sound effects
    _initializeAudioPlayer(); // Set up audio player
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(); // Start animation loop
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initAnimations(context, _symbols, _bubbles); // Initialize animations
  }

  // Initialize audio player, set volume to maximum
  Future<void> _initializeAudioPlayer() async {
    try {
      await _audioPlayer.setVolume(1.0);
      debugPrint('🔊 AudioPlayer initialized in Home');
    } catch (e) {
      debugPrint('❌ AudioPlayer initialization error in Home, $e');
    }
  }

  // Play sound effect from given asset path, using a queue
  Future<void> _playSound(String assetPath) async {
    if (mounted) {
      _soundQueue.add(assetPath);
      if (!_isPlayingSound) {
        _playNextSound();
      }
    }
  }

  // Process the next sound in the queue
  Future<void> _playNextSound() async {
    if (_soundQueue.isEmpty || !mounted) return;

    _isPlayingSound = true;
    final assetPath = _soundQueue.removeAt(0);
    try {
      await _audioPlayer.stop(); // Stop any currently playing sound
      await _audioPlayer.setAsset(assetPath); // Load new sound
      await _audioPlayer.play(); // Play the sound
      debugPrint('🔊 Playing sound, $assetPath');
    } catch (e) {
      debugPrint('❌ Error playing sound $assetPath, $e');
    } finally {
      _isPlayingSound = false;
      if (_soundQueue.isNotEmpty && mounted) {
        _playNextSound(); // Play next sound in queue
      }
    }
  }

  // Reload screen with game modal if required
  void _reloadScreen(dynamic result) async {
    if (mounted && result is Map && result['showGame'] == true && !_hasShownGame) {
      debugPrint('🎮 Showing game modal after returning from module');
      _hasShownGame = true; // Prevent repeated modals
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (mounted) {
          try {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                switch (result['module']) {
                  case 'subtraction':
                    return const SubtractionBalloonPopGameModal();
                  case 'addition':
                    return const AdditionBalloonPopGameModal();
                  case 'division':
                    return const DivisionBalloonPopGameModal();
                  case 'table_multiplication':
                    return const MultiplicationBalloonPopGameModal();
                  default:
                    return const MultiplicationBalloonPopGameModal();
                }
              },
            ).then((_) {
              if (mounted) {
                setState(() {
                  _hasShownGame = false; // Reset flag after modal closes
                });
              }
            });
          } catch (e) {
            debugPrint('❌ Error showing game modal, $e');
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _soundQueue.clear(); // Clear sound queue
    _audioPlayer.dispose(); // Clean up audio player
    _animationController.dispose(); // Clean up animation controller
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
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              _playSound('assets/sounds/cliick.wav'); // Queue click sound
              _scaffoldKey.currentState?.openDrawer(); // Open drawer
            },
          ),
          title: ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: isDarkMode
                  ? [Colors.cyanAccent, Colors.purpleAccent]
                  : [Colors.yellow.shade600, Colors.pink.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: const Text(
              'Math Champ 🌟',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Comic Sans MS',
                color: Colors.white,
                shadows: [
                  Shadow(blurRadius: 10.0, color: Colors.black45, offset: Offset(2.0, 2.0)),
                ],
              ),
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: Colors.white,
              ),
              onPressed: () {
                _playSound('assets/sounds/cliick.wav'); // Queue click sound
                themeProvider.toggleTheme(); // Switch theme
              },
            ),
          ],
          flexibleSpace: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDarkMode
                        ? [themeProvider.darkPrimaryColor, themeProvider.darkSecondaryColor]
                        : [Colors.yellow.shade300.withAlpha(51), Colors.pink.shade300.withAlpha(51)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: isDarkMode ? AppBarBubblePainter() : AppBarStarPainter(),
                    size: Size.infinite,
                  );
                },
              ),
            ],
          ),
        ),
        drawer: Drawer(
          width: 220,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [themeProvider.darkPrimaryColor, themeProvider.darkSecondaryColor]
                    : [Colors.yellow.shade300.withAlpha(51), Colors.pink.shade300.withAlpha(51)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Math Champ Menu 🌟',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Comic Sans MS',
                          shadows: const [
                            Shadow(blurRadius: 10.0, color: Colors.black45, offset: Offset(2.0, 2.0)),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Ready to shine, math superstar? 🚀',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontFamily: 'Comic Sans MS',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                _buildDrawerItem(
                  icon: Icons.add,
                  title: 'Addition',
                  onTap: () {
                    _playSound('assets/sounds/cliick.wav'); // Queue click sound
                    Navigator.pop(context); // Close drawer
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 800),
                        pageBuilder: (context, animation, secondaryAnimation) => const Addition(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.easeInOut;
                          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                          var offsetAnimation = animation.drive(tween);
                          return SlideTransition(position: offsetAnimation, child: child);
                        },
                      ),
                    ).then((result) => _reloadScreen(result)); // Handle navigation result
                  },
                  isDarkMode: isDarkMode,
                  themeProvider: themeProvider,
                ),
                _buildDrawerItem(
                  icon: Icons.remove,
                  title: 'Subtraction',
                  onTap: () {
                    _playSound('assets/sounds/cliick.wav'); // Queue click sound
                    Navigator.pop(context); // Close drawer
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 800),
                        pageBuilder: (context, animation, secondaryAnimation) => const Subtraction(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.easeInOut;
                          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                          var offsetAnimation = animation.drive(tween);
                          return SlideTransition(position: offsetAnimation, child: child);
                        },
                      ),
                    ).then((result) => _reloadScreen(result)); // Handle navigation result
                  },
                  isDarkMode: isDarkMode,
                  themeProvider: themeProvider,
                ),
                _buildDrawerItem(
                  icon: Icons.close,
                  title: 'Multiplication',
                  onTap: () {
                    _playSound('assets/sounds/cliick.wav'); // Queue click sound
                    Navigator.pop(context); // Close drawer
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 800),
                        pageBuilder: (context, animation, secondaryAnimation) => const TableMultiplication(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.easeInOut;
                          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                          var offsetAnimation = animation.drive(tween);
                          return SlideTransition(position: offsetAnimation, child: child);
                        },
                      ),
                    ).then((result) => _reloadScreen(result)); // Handle navigation result
                  },
                  isDarkMode: isDarkMode,
                  themeProvider: themeProvider,
                ),
                _buildDrawerItem(
                  icon: Icons.percent,
                  title: 'Division',
                  onTap: () {
                    _playSound('assets/sounds/cliick.wav'); // Queue click sound
                    Navigator.pop(context); // Close drawer
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 800),
                        pageBuilder: (context, animation, secondaryAnimation) => const Division(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.easeInOut;
                          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                          var offsetAnimation = animation.drive(tween);
                          return SlideTransition(position: offsetAnimation, child: child);
                        },
                      ),
                    ).then((result) => _reloadScreen(result)); // Handle navigation result
                  },
                  isDarkMode: isDarkMode,
                  themeProvider: themeProvider,
                ),
                _buildDrawerItem(
                  icon: Icons.settings,
                  title: 'Settings',
                  onTap: () {
                    _playSound('assets/sounds/cliick.wav'); // Queue click sound
                    Navigator.pop(context); // Close drawer
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 800),
                        pageBuilder: (context, animation, secondaryAnimation) => const Settings(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.easeInOut;
                          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                          var offsetAnimation = animation.drive(tween);
                          return SlideTransition(position: offsetAnimation, child: child);
                        },
                      ),
                    ).then((result) => _reloadScreen(result)); // Handle navigation result
                  },
                  isDarkMode: isDarkMode,
                  themeProvider: themeProvider,
                ),
              ],
            ),
          ),
        ),
        body: Stack(
          children: [
            // Animated Background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDarkMode
                      ? [themeProvider.darkPrimaryColor, themeProvider.darkSecondaryColor]
                      : [
                    Colors.yellow.shade100.withAlpha(30), // More transparent in light mode
                    Colors.pink.shade100.withAlpha(30),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, _) {
                  _symbolTimer += 0.02; // Update symbol animation timer
                  _bubblePopTimer += 0.02; // Update bubble animation timer
                  return CustomPaint(
                    painter: isDarkMode
                        ? BubblePainter(
                      bubbles: _bubbles,
                      particles: _particles,
                      bubblePopTimer: _bubblePopTimer,
                    )
                        : LightModePainter(
                      symbols: _symbols,
                      particles: _particles,
                      timer: _symbolTimer,
                    ),
                    willChange: true, // Optimize for performance
                    size: Size.infinite,
                  );
                },
              ),
            ),
            // Foreground Content
            SafeArea(
              child: GestureDetector(
                onTapDown: (details) {
                  addBurst(
                    details.localPosition,
                    isDarkMode,
                    _symbols,
                    _bubbles,
                        () => _playSound('assets/sounds/spark.wav'),
                  ); // Add burst effect on tap
                },
                child: Column(
                  children: [
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                        child: Column(
                          children: [
                            WelcomeCard(isDarkMode: isDarkMode, themeProvider: themeProvider),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: _buildTaskCard(
                                    context,
                                    title: 'Addition',
                                    icon: Icons.add,
                                    iconColor: isDarkMode ? Colors.lightGreen : Colors.greenAccent,
                                    gradientColors: isDarkMode
                                        ? [Colors.green.shade700, Colors.teal.shade700]
                                        : [Colors.green.shade400, Colors.teal.shade400],
                                    onTap: () {
                                      _playSound('assets/sounds/cliick.wav'); // Queue click sound
                                      addBurst(
                                        Offset(
                                          Random().nextDouble() * MediaQuery.of(context).size.width,
                                          Random().nextDouble() * MediaQuery.of(context).size.height,
                                        ),
                                        isDarkMode,
                                        _symbols,
                                        _bubbles,
                                            () => _playSound('assets/sounds/spark.wav'),
                                      ); // Add random burst effect
                                      debugPrint('➡ Navigating to Addition from Home');
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          transitionDuration: const Duration(milliseconds: 800),
                                          pageBuilder: (context, animation, secondaryAnimation) => const Addition(),
                                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                            const begin = Offset(1.0, 0.0);
                                            const end = Offset.zero;
                                            const curve = Curves.easeInOut;
                                            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                            var offsetAnimation = animation.drive(tween);
                                            return SlideTransition(position: offsetAnimation, child: child);
                                          },
                                        ),
                                      ).then((result) => _reloadScreen(result)); // Handle navigation result
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTaskCard(
                                    context,
                                    title: 'Subtraction',
                                    icon: Icons.remove,
                                    iconColor: isDarkMode ? Colors.yellowAccent : Colors.amber,
                                    gradientColors: isDarkMode
                                        ? [Colors.orange.shade700, Colors.red.shade700]
                                        : [Colors.orange.shade400, Colors.red.shade400],
                                    onTap: () {
                                      _playSound('assets/sounds/cliick.wav'); // Queue click sound
                                      addBurst(
                                        Offset(
                                          Random().nextDouble() * MediaQuery.of(context).size.width,
                                          Random().nextDouble() * MediaQuery.of(context).size.height,
                                        ),
                                        isDarkMode,
                                        _symbols,
                                        _bubbles,
                                            () => _playSound('assets/sounds/spark.wav'),
                                      ); // Add random burst effect
                                      debugPrint('➡ Navigating to Subtraction from Home');
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          transitionDuration: const Duration(milliseconds: 800),
                                          pageBuilder: (context, animation, secondaryAnimation) => const Subtraction(),
                                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                            const begin = Offset(1.0, 0.0);
                                            const end = Offset.zero;
                                            const curve = Curves.easeInOut;
                                            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                            var offsetAnimation = animation.drive(tween);
                                            return SlideTransition(position: offsetAnimation, child: child);
                                          },
                                        ),
                                      ).then((result) => _reloadScreen(result)); // Handle navigation result
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: _buildTaskCard(
                                    context,
                                    title: 'Multiplication',
                                    icon: Icons.close,
                                    iconColor: isDarkMode ? Colors.cyanAccent : Colors.white,
                                    gradientColors: isDarkMode
                                        ? [Colors.blue.shade700, Colors.purple.shade700]
                                        : [Colors.blue.shade400, Colors.cyan.shade400],
                                    onTap: () {
                                      _playSound('assets/sounds/cliick.wav'); // Queue click sound
                                      addBurst(
                                        Offset(
                                          Random().nextDouble() * MediaQuery.of(context).size.width,
                                          Random().nextDouble() * MediaQuery.of(context).size.height,
                                        ),
                                        isDarkMode,
                                        _symbols,
                                        _bubbles,
                                            () => _playSound('assets/sounds/spark.wav'),
                                      ); // Add random burst effect
                                      debugPrint('➡ Navigating to TableMultiplication from Home');
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          transitionDuration: const Duration(milliseconds: 800),
                                          pageBuilder: (context, animation, secondaryAnimation) => const TableMultiplication(),
                                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                            const begin = Offset(1.0, 0.0);
                                            const end = Offset.zero;
                                            const curve = Curves.easeInOut;
                                            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                            var offsetAnimation = animation.drive(tween);
                                            return SlideTransition(position: offsetAnimation, child: child);
                                          },
                                        ),
                                      ).then((result) => _reloadScreen(result)); // Handle navigation result
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTaskCard(
                                    context,
                                    title: 'Division',
                                    icon: Icons.percent,
                                    iconColor: isDarkMode ? Colors.pinkAccent : Colors.white,
                                    gradientColors: isDarkMode
                                        ? [Colors.pink.shade700, Colors.purple.shade700]
                                        : [Colors.pink.shade400, Colors.purple.shade400],
                                    onTap: () {
                                      _playSound('assets/sounds/cliick.wav'); // Queue click sound
                                      addBurst(
                                        Offset(
                                          Random().nextDouble() * MediaQuery.of(context).size.width,
                                          Random().nextDouble() * MediaQuery.of(context).size.height,
                                        ),
                                        isDarkMode,
                                        _symbols,
                                        _bubbles,
                                            () => _playSound('assets/sounds/spark.wav'),
                                      ); // Add random burst effect
                                      debugPrint('➡ Navigating to Division from Home');
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          transitionDuration: const Duration(milliseconds: 800),
                                          pageBuilder: (context, animation, secondaryAnimation) => const Division(),
                                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                            const begin = Offset(1.0, 0.0);
                                            const end = Offset.zero;
                                            const curve = Curves.easeInOut;
                                            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                            var offsetAnimation = animation.drive(tween);
                                            return SlideTransition(position: offsetAnimation, child: child);
                                          },
                                        ),
                                      ).then((result) => _reloadScreen(result)); // Handle navigation result
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build drawer item with animation
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDarkMode,
    required ThemeProvider themeProvider,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDarkMode ? Colors.cyanAccent : Colors.pink.shade600,
        size: 28,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDarkMode ? Colors.white70 : Colors.black87,
          fontSize: 18,
          fontFamily: 'Comic Sans MS',
        ),
      ),
      trailing: const Text('🌟', style: TextStyle(fontSize: 16)),
      onTap: onTap,
    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.5, end: 0.0); // Animate drawer item
  }

  // Build task card with animation
  Widget _buildTaskCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Color iconColor,
        required List<Color> gradientColors,
        required VoidCallback onTap,
      }) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          height: 150,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isDarkMode ? Colors.cyanAccent.withAlpha(77) : Colors.black.withAlpha(51),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 50,
                color: iconColor,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Comic Sans MS',
                  shadows: [
                    Shadow(
                      blurRadius: 5.0,
                      color: Colors.black45,
                      offset: Offset(1.0, 1.0),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ).animate().scale(
      begin: const Offset(0.9, 0.9),
      end: const Offset(1.0, 1.0),
      duration: 600.ms,
      curve: Curves.bounceOut,
    ); // Animate task card
  }
}

// Welcome card widget, displays greeting with confetti
class WelcomeCard extends StatefulWidget {
  final bool isDarkMode;
  final ThemeProvider themeProvider;

  const WelcomeCard({super.key, required this.isDarkMode, required this.themeProvider});

  @override
  _WelcomeCardState createState() => _WelcomeCardState();
}

// State class for WelcomeCard, manages confetti animation
class _WelcomeCardState extends State<WelcomeCard> with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2)); // Initialize confetti
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _confettiController.play(); // Start confetti animation
        debugPrint('🎉 Started confetti animation in WelcomeCard');
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose(); // Clean up confetti controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Card(
          elevation: 10,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: widget.isDarkMode ? Colors.grey.shade800 : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Text(
                  "Welcome, Math Champ! 🎉",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: widget.isDarkMode ? Colors.cyanAccent : Colors.pink.shade600,
                    fontFamily: 'Comic Sans MS',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  "Get ready for a fun adventure with math! Pick an activity below and become a Math Champ superstar! 🌟",
                  style: TextStyle(
                    fontSize: 18,
                    color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                    height: 1.5,
                    fontFamily: 'Comic Sans MS',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.5, end: 0.0), // Animate card
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
    );
  }
}