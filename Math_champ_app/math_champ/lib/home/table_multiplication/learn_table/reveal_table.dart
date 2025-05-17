import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '/main.dart';

class TableDisplayPage extends StatefulWidget {
  final List<String> tableResult;
  final int selectedTable;
  final int range;

  const TableDisplayPage({
    super.key,
    required this.tableResult,
    required this.selectedTable,
    required this.range,
  });

  @override
  _TableDisplayPageState createState() => _TableDisplayPageState();
}

class _TableDisplayPageState extends State<TableDisplayPage> {
  final ScrollController _scrollController = ScrollController();
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confettiController.play();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Widget _buildTableView() {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return ListView.builder(
      controller: _scrollController,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.tableResult.length,
      itemBuilder: (context, index) {
        final equation = widget.tableResult[index];
        final parts = equation.split(' = ');
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
          child: FlipCard(
            fill: Fill.fillBack,
            direction: FlipDirection.HORIZONTAL,
            front: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDarkMode
                      ? [Colors.blue.shade700, Colors.cyan.shade700]
                      : [Colors.blue.shade400, Colors.cyan.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode ? Colors.cyanAccent.withAlpha(102) : Colors.black.withAlpha(51),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Text(
                parts[0],
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Comic Sans MS',
                ),
                textAlign: TextAlign.center,
              ),
            ),
            back: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDarkMode
                      ? [Colors.green.shade700, Colors.yellow.shade700]
                      : [Colors.green.shade400, Colors.yellow.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode ? Colors.cyanAccent.withAlpha(102) : Colors.black.withAlpha(51),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Text(
                equation,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Comic Sans MS',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ).animate(delay: (100 * index).ms)
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.5, end: 0.0, duration: 400.ms, curve: Curves.bounceOut)
              .then()
              .rotate(begin: -0.1, end: 0.1, duration: 200.ms, curve: Curves.easeInOut)
              .then()
              .rotate(begin: 0.1, end: -0.1, duration: 200.ms, curve: Curves.easeInOut)
              .then()
              .rotate(begin: -0.05, end: 0.05, duration: 100.ms, curve: Curves.easeInOut)
              .then()
              .rotate(begin: 0.05, end: 0.0, duration: 100.ms, curve: Curves.easeInOut),
        );
      },
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
          title: Text(
            "Your Table! 🌟",
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
        body: Stack(
          alignment: Alignment.center,
          children: [
            Container(
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
                                "Table of ${widget.selectedTable} (1 to ${widget.range}) 🎉",
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
                                "Flip the cards to see the answers! Have fun learning! 🌟",
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
                      _buildTableView(),
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
              colors: const [Colors.red, Colors.blue, Colors.yellow, Colors.green, Colors.pink],
            ),
          ],
        ),
      ),
    );
  }
}