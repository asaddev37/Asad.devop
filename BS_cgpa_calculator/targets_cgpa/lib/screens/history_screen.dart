import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../history_pages/achieving_target_cgpa_history.dart';
import '../history_pages/current_and_target_cgpa_history.dart';
import '../history_pages/individual_semester_gpa_history.dart';

class HistoryScreen extends StatefulWidget {
  final bool isDarkMode;

  const HistoryScreen({super.key, required this.isDarkMode});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final appBarColor = widget.isDarkMode ? Colors.grey.shade800 : Color(0xFFD35400);
    final backgroundGradient = widget.isDarkMode
        ? LinearGradient(
      colors: [Colors.grey.shade900, Colors.grey.shade800],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    )
        : LinearGradient(
      colors: [Color(0xFFF39C12).withAlpha(25), Color(0xFFFFF3E0)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    final textColor = widget.isDarkMode ? Colors.white : Color(0xFF7F8C8D);
    final buttonColor = widget.isDarkMode ? Colors.amberAccent : Color(0xFFF39C12);
    final shadowColor = widget.isDarkMode ? Colors.amberAccent.withAlpha(77) : Color(0xFFE74C3C).withAlpha(77);
    final pressedColor = widget.isDarkMode ? Colors.amberAccent.withAlpha(51) : Color(0xFFE74C3C).withAlpha(51);
    final hoverColor = widget.isDarkMode ? Colors.amberAccent.withAlpha(25) : Color(0xFFF39C12).withAlpha(25);
    final progressColor = widget.isDarkMode ? Colors.amberAccent : Color(0xFFE74C3C);

    return Scaffold(
      appBar: AppBar(
        title: Text('Calculation History', style: TextStyle(color: Colors.white)),
        backgroundColor: appBarColor,
        elevation: 2,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: FutureBuilder<bool>(
            future: _isHistoryEnabled(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: progressColor));
              }
              final isHistoryEnabled = snapshot.data ?? false;

              if (!isHistoryEnabled) {
                return Center(
                  child: Text(
                    'History saving is disabled.\nEnable it in settings to view past calculations.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                );
              }

              return _buildModuleSelection(context, buttonColor, shadowColor, pressedColor, hoverColor);
            },
          ),
        ),
      ),
    );
  }

  Future<bool> _isHistoryEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isHistoryEnabled') ?? true;
  }

  Widget _buildModuleSelection(
      BuildContext context,
      Color buttonColor,
      Color shadowColor,
      Color pressedColor,
      Color hoverColor,
      ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildModuleButton(
          context,
          title: 'Semester GPA History',
          tooltip: 'View your past semester GPA calculations',
          onPressed: () => _navigateWithSlideTransition(
            context,
            IndividualSemesterGpaHistory(isDarkMode: widget.isDarkMode),
          ),
          buttonColor: buttonColor,
          shadowColor: shadowColor,
          pressedColor: pressedColor,
          hoverColor: hoverColor,
        ),
        SizedBox(height: 25),
        _buildModuleButton(
          context,
          title: 'Target CGPA History',
          tooltip: 'Check your previous target CGPA plans',
          onPressed: () => _navigateWithSlideTransition(
            context,
            AchievingTargetCgpaHistory(isDarkMode: widget.isDarkMode,), // No isDarkMode until updated
          ),
          buttonColor: buttonColor,
          shadowColor: shadowColor,
          pressedColor: pressedColor,
          hoverColor: hoverColor,
        ),
        SizedBox(height: 25),
        _buildModuleButton(
          context,
          title: 'CGPA Progress History',
          tooltip: 'See your current vs target CGPA history',
          onPressed: () => _navigateWithSlideTransition(
            context,
            CurrentAndTargetCgpaHistory(isDarkMode: widget.isDarkMode,), // No isDarkMode until updated
          ),
          buttonColor: buttonColor,
          shadowColor: shadowColor,
          pressedColor: pressedColor,
          hoverColor: hoverColor,
        ),
      ],
    );
  }

  void _navigateWithSlideTransition(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  Widget _buildModuleButton(
      BuildContext context, {
        required String title,
        required String tooltip,
        required VoidCallback onPressed,
        required Color buttonColor,
        required Color shadowColor,
        required Color pressedColor,
        required Color hoverColor,
      }) {
    return Tooltip(
      message: tooltip,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 35, vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 4,
          shadowColor: shadowColor,
          textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
              if (states.contains(WidgetState.pressed)) {
                return pressedColor;
              }
              if (states.contains(WidgetState.hovered)) {
                return hoverColor;
              }
              return null;
            },
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}


