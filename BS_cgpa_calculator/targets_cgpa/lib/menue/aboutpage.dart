import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  final bool isDarkMode;

  const AboutPage({super.key, required this.isDarkMode});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    // Blue theme for professionalism
    final appBarGradient = widget.isDarkMode
        ? LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Colors.grey.shade800, Colors.grey.shade700],
    )
        : LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Colors.blue.shade800, Colors.blue.shade600],
    );
    final backgroundColor = widget.isDarkMode
        ? LinearGradient(colors: [Colors.grey.shade900, Colors.grey.shade800])
        : LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.grey.shade50, Colors.grey.shade100],
    );
    final textColor = widget.isDarkMode ? Colors.white : Colors.blueGrey.shade800;
    final primaryTextColor = widget.isDarkMode ? Colors.amber : Colors.blue.shade900;
    final accentColor = widget.isDarkMode ? Colors.amber : Colors.blue.shade900;
    final shadowColor = widget.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300.withAlpha(128);
    final cardColor = widget.isDarkMode ? Colors.grey.shade800 : Colors.white; // White containers in light mode
    final borderColor = widget.isDarkMode ? Colors.amber : Colors.blue;
    final featureIconColor = widget.isDarkMode ? Colors.blue.shade300 : Colors.blue.shade600;

    // Colorful dots for visual appeal
    final pointColors = [
      Colors.redAccent,
      Colors.greenAccent,
      Colors.yellowAccent,
      Colors.purpleAccent,
      Colors.orangeAccent,
      Colors.tealAccent,
      Colors.pinkAccent,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            shadows: [
              Shadow(
                color: Colors.black26,
                offset: Offset(1, 1),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: appBarGradient),
        ),
      ),
      body: Container(
       decoration: BoxDecoration(gradient: backgroundColor,),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BS CGPA Calculator',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  'Your go-to tool for mastering your academic journey! Designed for BS students, this app helps you calculate, plan, and track your CGPA with ease and precision.',
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                    height: 1.6,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 25),
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: cardColor, // White in light mode
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: 1), // Blue border
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        spreadRadius: 1,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'What You Can Do With This App?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                      SizedBox(height: 15),
                      _buildFeatureItem(
                        icon: Icons.calculate,
                        text: 'Calculate Individual Semester GPA',
                        color: featureIconColor,
                      ),
                      _buildFeatureItem(
                        icon: Icons.trending_up,
                        text: 'Achieve Your Target CGPA',
                        color: Colors.pinkAccent,
                      ),
                      _buildFeatureItem(
                        icon: Icons.compare,
                        text: 'Compare Current & Target CGPA',
                        color: Colors.green,
                      ),
                      _buildFeatureItem(
                        icon: Icons.history,
                        text: 'View Your Calculation History',
                        color: Colors.amber,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 25),
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: cardColor, // White in light mode
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: 1), // Blue border
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        spreadRadius: 1,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How It Works Step-by-Step 🔍',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                      SizedBox(height: 15),
                      _buildDescriptionItem(
                        title: 'Individual Semester GPA',
                        points: [
                          _buildPoint(
                            text: 'Pick your semester (1-8) and choose how many subjects (1-8) to calculate.',
                            color: pointColors[0],
                          ),
                          _buildPoint(
                            text: 'Toggle COMSATS Policy to enter marks (0-100) or stick with GPA (0.0-4.0).',
                            color: pointColors[1],
                          ),
                          _buildPoint(
                            text: 'For each subject, add its name (optional), credit hours (1-6), and marks or GPA.',
                            color: pointColors[2],
                          ),
                          _buildPoint(
                            text: 'Hit "Calculate GPA" to get your semester GPA, weighted by credits.',
                            color: pointColors[3],
                          ),
                          _buildPoint(
                            text: 'Enjoy a motivational message based on your GPA—saved to history for you!',
                            color: pointColors[4],
                          ),
                          _buildPoint(
                            text: 'Reset anytime with the app bar button to start fresh.',
                            color: pointColors[5],
                          ),
                          _buildPoint(
                            text: 'Perfect for tracking your semester success with ease!',
                            color: pointColors[6],
                            isSummary: true,
                          ),
                        ],
                      ),
                      _buildDescriptionItem(
                        title: 'Achieving Target CGPA',
                        points: [
                          _buildPoint(
                            text: 'Input your current semester (1-8) and current CGPA (0.0-4.0), then set your target CGPA.',
                            color: pointColors[0],
                          ),
                          _buildPoint(
                            text: 'Click "Calculate Required GPA" to see what GPA you need next semester (assuming 4 credit hours).',
                            color: pointColors[1],
                          ),
                          _buildPoint(
                            text: 'Add subjects (1-8) for the next semester, including names and credit hours (1-6).',
                            color: pointColors[2],
                          ),
                          _buildPoint(
                            text: 'Hit "Check All Possibilities" to get a smart GPA combo (1.0-4.0) for each subject to hit your target.',
                            color: pointColors[3],
                          ),
                          _buildPoint(
                            text: 'See your next semester GPA and updated CGPA, with a fun success message!',
                            color: pointColors[4],
                          ),
                          _buildPoint(
                            text: 'Reset anytime with the app bar button—your results save to history automatically.',
                            color: pointColors[5],
                          ),
                          _buildPoint(
                            text: 'Plan your path to academic success with confidence!',
                            color: pointColors[6],
                            isSummary: true,
                          ),
                        ],
                      ),
                      _buildDescriptionItem(
                        title: 'Current & Target CGPA',
                        points: [
                          _buildPoint(
                            text: 'Pick your target semester (1-8) from the dropdown.',
                            color: pointColors[0],
                          ),
                          _buildPoint(
                            text: 'Enter GPAs (0.0-4.0) for all previous semesters (4 credit hours each).',
                            color: pointColors[1],
                          ),
                          _buildPoint(
                            text: 'Press "Calculate Current CGPA" to see where you stand.',
                            color: pointColors[2],
                          ),
                          _buildPoint(
                            text: 'Set your target CGPA and click "Calculate Required GPA" for the next semester’s goal.',
                            color: pointColors[3],
                          ),
                          _buildPoint(
                            text: 'Get a motivational message based on your required GPA—saved to history for you!',
                            color: pointColors[4],
                          ),
                          _buildPoint(
                            text: 'Reset easily via the app bar to tweak your plans.',
                            color: pointColors[5],
                          ),
                          _buildPoint(
                            text: 'Stay on top of your academic progress effortlessly!',
                            color: pointColors[6],
                            isSummary: true,
                          ),
                        ],
                      ),
                      _buildDescriptionItem(
                        title: 'Calculation History',
                        points: [
                          _buildPoint(
                            text: 'Explore your past calculations: "Individual Semester GPA", "Target CGPA", or "Current & Target CGPA".',
                            color: pointColors[0],
                          ),
                          _buildPoint(
                            text: 'For "Individual Semester GPA", see semesters, subjects, credits, grades, and GPA details.',
                            color: pointColors[1],
                          ),
                          _buildPoint(
                            text: 'Other modules show CGPA stats and timestamps in neat tables.',
                            color: pointColors[2],
                          ),
                          _buildPoint(
                            text: 'Download your history as CSV or PDF—preserve your journey in a snap!',
                            color: pointColors[3],
                          ),
                          _buildPoint(
                            text: 'Export with ease: CSV for spreadsheets, PDF for sleek reports—right from the app bar!',
                            color: pointColors[4],
                          ),
                          _buildPoint(
                            text: 'History auto-saves (if enabled in settings) using secure SharedPreferences.',
                            color: pointColors[5],
                          ),
                          _buildPoint(
                            text: 'Relive your academic wins and plan smarter—your records, your way!',
                            color: pointColors[6],
                            isSummary: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  'Developed by Asadullah (FA22-BSE-037)',
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: accentColor,
                    shadows: [
                      Shadow(
                        color: accentColor.withAlpha(77),
                        offset: const Offset(1, 1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
      {required IconData icon, required String text, required Color color}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(51),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 28,
              color: color,
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 18,
                color: widget.isDarkMode ? Colors.white : Colors.blueGrey.shade800,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionItem(
      {required String title, required List<Widget> points}) {
    // final textColor = widget.isDarkMode ? Colors.white : Colors.blueGrey.shade800;
    final accentColor = widget.isDarkMode ? Colors.amber : Colors.blue.shade600;
    final shadowColor = widget.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300.withAlpha(128);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: widget.isDarkMode ? Colors.grey.shade800 : Colors.white, // White in light mode
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: widget.isDarkMode ? Colors.amber : Colors.blue, width: 1), // Blue border
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              spreadRadius: 1,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
            SizedBox(height: 12),
            Column(children: points),
          ],
        ),
      ),
    );
  }

  Widget _buildPoint(
      {required String text, required Color color, bool isSummary = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: EdgeInsets.only(top: 5, right: 10),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: isSummary ? 16 : 15,
                color: widget.isDarkMode ? Colors.white : Colors.blueGrey.shade800,
                height: 1.5,
                fontWeight: isSummary ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}