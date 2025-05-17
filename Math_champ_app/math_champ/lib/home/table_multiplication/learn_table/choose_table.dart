import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:numberpicker/numberpicker.dart';
import 'reveal_table.dart';
import '../widgets.dart';
import '/main.dart';

class LearnSetupPage extends StatefulWidget {
  const LearnSetupPage({super.key});

  @override
  _LearnSetupPageState createState() => _LearnSetupPageState();
}

class _LearnSetupPageState extends State<LearnSetupPage> with TickerProviderStateMixin {
  int? _selectedTable;
  int _range = 10;
  List<String> _tableResult = [];
  final ScrollController _scrollController = ScrollController();
  late AnimationController _refreshAnimationController;
  late AudioPlayer _audioPlayer;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _refreshAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _audioPlayer = AudioPlayer();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    _initializeAudioPlayer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confettiController.play();
      _playSound('assets/sounds/pop.wav');
    });
  }

  Future<void> _initializeAudioPlayer() async {
    try {
      await _audioPlayer.setVolume(1.0);
      debugPrint('🔊 AudioPlayer initialized in LearnSetupPage');
    } catch (e) {
      debugPrint('❌ AudioPlayer initialization error in LearnSetupPage: $e');
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

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshAnimationController.dispose();
    _audioPlayer.dispose();
    _confettiController.dispose();
    debugPrint('🗑️ Disposed AudioPlayer and ConfettiController in LearnSetupPage');
    super.dispose();
  }

  void _showErrorOverlay(String message) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    OverlayEntry? overlayEntry;
    final animationController = AnimationController(
      vsync: this,
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
                          : [Colors.orangeAccent, Colors.pinkAccent],
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
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Comic Sans MS',
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      buildButton(
                        label: 'Got It! 😊',
                        onTap: () {
                          animationController.reverse().then((_) {
                            overlayEntry?.remove();
                            animationController.dispose();
                          });
                        },
                        isDarkMode: isDarkMode,
                        themeProvider: themeProvider,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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

  void _generateTable(BuildContext context) {
    if (_selectedTable == null) {
      _showErrorOverlay("Oops, pick a number for your table! 😊🌟");
    } else if (_range <= 0) {
      _showErrorOverlay("Hey, choose a range greater than 0! 😊🎉");
    } else {
      _tableResult = List.generate(
        _range,
            (index) => "$_selectedTable x ${index + 1} = ${_selectedTable! * (index + 1)}",
      );
      _playSound('assets/sounds/start.wav');
      _confettiController.play();
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => TableDisplayPage(
            tableResult: _tableResult,
            selectedTable: _selectedTable!,
            range: _range,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(position: offsetAnimation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
  }

  void _refresh() {
    setState(() {
      _selectedTable = null;
      _range = 10;
      _tableResult.clear();
    });
    _refreshAnimationController.forward(from: 0.0);
    _playSound('assets/sounds/refresh.wav');
  }

  Widget _buildTableSelector({required bool isDarkMode, required ThemeProvider themeProvider}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Choose Your Table",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.cyanAccent : themeProvider.lightPrimaryColor,
            fontFamily: 'Comic Sans MS',
          ),
        ),
        const SizedBox(height: 12),
        Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 40),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode
                  ? [Colors.grey.shade800, Colors.grey.shade900]
                  : [Colors.white, Colors.grey.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isDarkMode ? Colors.cyanAccent.withAlpha(51) : Colors.black.withAlpha(26),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: List.generate(20, (index) {
              final table = index + 1;
              final isSelected = _selectedTable == table;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTable = table;
                    _playSound('assets/sounds/cliick.wav');
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isSelected
                          ? isDarkMode
                          ? [Colors.blue.shade700, Colors.cyan.shade700]
                          : [Colors.blue.shade400, Colors.cyan.shade400]
                          : isDarkMode
                          ? [Colors.grey.shade700, Colors.grey.shade600]
                          : [Colors.grey.shade200, Colors.grey.shade100],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? (isDarkMode ? Colors.cyanAccent.withAlpha(102) : Colors.black.withAlpha(51))
                            : Colors.transparent,
                        blurRadius: 6,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$table',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : (isDarkMode ? Colors.white70 : Colors.black87),
                            fontFamily: 'Comic Sans MS',
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 6),
                          const Text('🌟', style: TextStyle(fontSize: 14)),
                        ],
                      ],
                    ),
                  ),
                ).animate().scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1.0, 1.0),
                  duration: 300.ms,
                  curve: Curves.bounceOut,
                ),
              );
            }),
          ),
        ),
      ],
    ).animate()
        .fadeIn(duration: 800.ms)
        .then()
        .rotate(
      begin: -0.1,  // Starts slightly rotated (about 5.7 degrees)
      end: 0.0,     // Ends straight
      duration: 1000.ms,  // Takes 1 second to straighten
      curve: Curves.easeInOut,
    );
  }

  Widget _buildRangePicker({
    required bool isDarkMode,
    required ThemeProvider themeProvider,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.lime.shade400],
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
            "Range (1 to)",
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
            value: _range,
            minValue: 1,
            maxValue: 20,
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
            onChanged: (value) {
              _playSound('assets/sounds/pop.wav');
              setState(() {
                _range = value;
              });
            },
            zeroPad: true,
          ),
        ],
      ),
    ).animate()
        .fadeIn(duration: 600.ms)
        .slideX(begin: 0.5, end: 0.0)
        .then()
        .rotate(begin: -0.1, end: 0.1, duration: 200.ms, curve: Curves.easeInOut)
        .then()
        .rotate(begin: 0.1, end: -0.1, duration: 200.ms, curve: Curves.easeInOut)
        .then()
        .rotate(begin: -0.05, end: 0.05, duration: 100.ms, curve: Curves.easeInOut)
        .then()
        .rotate(begin: 0.05, end: 0.0, duration: 100.ms, curve: Curves.easeInOut);
  }

  Widget _buildRefreshButton({
    required VoidCallback onTap,
    required bool isDarkMode,
    required ThemeProvider themeProvider,
  }) {
    return RotationTransition(
      turns: Tween(begin: 0.0, end: 1.0).animate(_refreshAnimationController),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: isDarkMode
                  ? [Colors.blue.shade700, Colors.green.shade700]
                  : [Colors.blue.shade400, Colors.green.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: isDarkMode ? Colors.cyanAccent.withAlpha(102) : Colors.black.withAlpha(51),
                blurRadius: 10,
                spreadRadius: 3,
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: const Icon(
            Icons.refresh,
            size: 28,
            color: Colors.white,
          ),
        ),
      ),
    ).animate().scale(
      begin: const Offset(0.8, 0.8),
      end: const Offset(1.0, 1.0),
      duration: 400.ms,
      curve: Curves.bounceOut,
    );
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
          title: const Text(
            "Explore Multiplication!",
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
                  ? [Colors.blue.shade700, Colors.green.shade700]
                  : [Colors.blue.shade300.withAlpha(51), Colors.green.shade300.withAlpha(51)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SingleChildScrollView(
            controller: _scrollController,
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
                            "Let’s Learn Tables! 🌟",
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
                            "Pick a table and range to see the magic of multiplication! Tap to reveal your table! 🎉",
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
                  ).animate().fadeIn(duration: 800.ms),
                  const SizedBox(height: 30),
                  _buildTableSelector(isDarkMode: isDarkMode, themeProvider: themeProvider),
                  const SizedBox(height: 30),
                  _buildRangePicker(isDarkMode: isDarkMode, themeProvider: themeProvider),
                  const SizedBox(height: 40),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      ConfettiWidget(
                        confettiController: _confettiController,
                        blastDirectionality: BlastDirectionality.explosive,
                        particleDrag: 0.05,
                        emissionFrequency: 0.05,
                        numberOfParticles: 20,
                        gravity: 0.05,
                        colors: const [Colors.red, Colors.blue, Colors.yellow, Colors.green, Colors.pink],
                      ),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          buildButton(
                            label: "Reveal Table! 🚀",
                            onTap: () => _generateTable(context),
                            isDarkMode: isDarkMode,
                            themeProvider: themeProvider,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            textStyle: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Comic Sans MS',
                            ),
                          ),
                          _buildRefreshButton(
                            onTap: _refresh,
                            isDarkMode: isDarkMode,
                            themeProvider: themeProvider,
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
      ),
    );
  }
}