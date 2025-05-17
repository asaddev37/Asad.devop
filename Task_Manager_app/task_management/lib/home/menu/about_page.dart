import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  final bool isDarkMode;
  final Color lightModeColor;
  final Color darkModeColor;

  const AboutPage({
    super.key,
    required this.isDarkMode,
    required this.lightModeColor,
    required this.darkModeColor,
  });

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  bool _showFeatures = true; // Toggle between features and how it works

  @override
  Widget build(BuildContext context) {
    final gradientColors = widget.isDarkMode
        ? [widget.darkModeColor, Colors.grey[800]!.withAlpha(179)]
        : [widget.lightModeColor, Colors.white.withAlpha(179)];
    final textColor = widget.isDarkMode ? Colors.white70 : Colors.black87;
    final primaryTextColor = widget.isDarkMode ? Colors.white : Colors.black87;
    final accentColor = widget.isDarkMode ? Colors.white : Colors.black87;
    final shadowColor = widget.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300.withAlpha(128);
    final cardColor = widget.isDarkMode ? Colors.grey.shade800 : Colors.white;
    final borderColor = widget.isDarkMode ? widget.darkModeColor : widget.lightModeColor;
    final pointColors = [
      Colors.redAccent,
      Colors.greenAccent,
      Colors.green,
      Colors.purpleAccent,
      Colors.orangeAccent,
      Colors.blueAccent,
      Colors.pinkAccent,
    ];

    Widget _buildFeatureIcon(IconData icon, String text, Color color) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 8),
            Container(
              width: 80,
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget _buildNumberedPoint({required int number, required String text, required Color color}) {
      return Padding(
        padding: EdgeInsets.only(bottom: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24,
              alignment: Alignment.center,
              child: Text(
                '$number.',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            SizedBox(width: 4),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget _buildSubSectionHeader(String text) {
      return Padding(
        padding: EdgeInsets.only(top: 12, bottom: 8),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: widget.isDarkMode ? Colors.white : Colors.black87,
            decoration: TextDecoration.underline,
          ),
        ),
      );
    }

    Widget _buildSectionItem(
        {required String title, required List<Widget> points}) {
      final accentColor = widget.isDarkMode ? Colors.white : Colors.black87;
      final shadowColor = widget.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300.withAlpha(128);

      return Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: widget.isDarkMode ? Colors.grey.shade800 : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: widget.isDarkMode ? widget.darkModeColor : widget.lightModeColor, width: 1),
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
                  color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                  height: 1.5,
                  fontWeight: isSummary ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      );
    }
    Widget _buildIconPoint({
      required IconData icon,
      required String text,
      required Color color,
      bool isSummary = false,
    }) {
      return Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: 2, right: 10),
              child: Icon(
                icon,
                size: 20,
                color: color,
              ),
            ),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: isSummary ? 16 : 15,
                  color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                  height: 1.5,
                  fontWeight: isSummary ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About Task Manager',
          style: TextStyle(
            color: primaryTextColor,
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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: textColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: Padding(
          padding: EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  children: [
                    // Features Button
                    Tooltip(
                      message: 'Show app features',
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _showFeatures = true;
                          });
                        },
                        icon: Icon(
                          Icons.star,
                          color: _showFeatures
                              ? (widget.isDarkMode ? Colors.white : Colors.black87)
                              : (widget.isDarkMode ? Colors.white70 : Colors.black54),
                        ),
                        label: Text(
                          'Features',
                          style: TextStyle(
                            color: _showFeatures
                                ? (widget.isDarkMode ? Colors.white : Colors.black87)
                                : (widget.isDarkMode ? Colors.white70 : Colors.black54),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _showFeatures
                              ? (widget.isDarkMode ? widget.darkModeColor : widget.lightModeColor)
                              : (widget.isDarkMode ? Colors.grey[800]! : Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: _showFeatures
                                  ? (widget.isDarkMode ? Colors.white70 : Colors.black54)
                                  : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          elevation: _showFeatures ? 6 : 2,
                          shadowColor: widget.isDarkMode ? Colors.black54 : Colors.grey[400],
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),

                    // Spacer pushes text to center
                    Spacer(),

                    // Center Text
                    Text(
                      _showFeatures ? 'App Features' : 'How It Works',
                      style: TextStyle(
                        color: widget.isDarkMode ? Colors.white : Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // Spacer pushes guide button to end
                    Spacer(),

                    // Guide Button
                    Tooltip(
                      message: 'Show how the app works',
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _showFeatures = false;
                          });
                        },
                        icon: Icon(
                          Icons.help_outline,
                          color: !_showFeatures
                              ? (widget.isDarkMode ? Colors.white : Colors.black87)
                              : (widget.isDarkMode ? Colors.white70 : Colors.black54),
                        ),
                        label: Text(
                          'Guide',
                          style: TextStyle(
                            color: !_showFeatures
                                ? (widget.isDarkMode ? Colors.white : Colors.black87)
                                : (widget.isDarkMode ? Colors.white70 : Colors.black54),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: !_showFeatures
                              ? (widget.isDarkMode ? widget.darkModeColor : widget.lightModeColor)
                              : (widget.isDarkMode ? Colors.grey[800]! : Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: !_showFeatures
                                  ? (widget.isDarkMode ? Colors.white70 : Colors.black54)
                                  : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          elevation: !_showFeatures ? 6 : 2,
                          shadowColor: widget.isDarkMode ? Colors.black54 : Colors.grey[400],
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),


                SizedBox(height: 25),

                if (_showFeatures) ...[
                  Text(
                    'Welcome to Task Manager',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'A productivity app designed to help you manage your tasks efficiently with a clean and customizable interface.',
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
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor, width: 1),
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
                        // Hint text about scrollability
                        Row(
                          children: [
                            Icon(Icons.swipe, color: Colors.grey, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Swipe to see more features',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        // Scrollable icons section
                        Container(
                          height: 140, // Fixed height for consistent layout
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: BouncingScrollPhysics(),
                            child: Row(
                              children: [
                                _buildFeatureIcon(Icons.add_task, 'Add Tasks', Colors.greenAccent),
                                _buildFeatureIcon(Icons.notifications_active, 'Reminders', Colors.orangeAccent),
                                _buildFeatureIcon(Icons.upcoming, 'Upcoming Tasks', Colors.red),
                                _buildFeatureIcon(Icons.repeat, 'Repeating Tasks', Colors.purpleAccent),
                                _buildFeatureIcon(Icons.check_circle, 'Track Progress', Colors.blueAccent),
                                _buildFeatureIcon(Icons.category, 'Categories', Colors.pinkAccent),
                                _buildFeatureIcon(Icons.palette, 'Custom Themes', Colors.green),
                                _buildFeatureIcon(Icons.share_rounded, 'Share Tasks', Colors.tealAccent),
                                _buildFeatureIcon(Icons.picture_as_pdf_rounded, 'Download Tasks',Colors.amber),
                                _buildFeatureIcon(Icons.edit, 'Quick Edit', Colors.redAccent),
                                _buildFeatureIcon(Icons.search, 'Smart Search', Colors.lightBlueAccent),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Manage all your tasks with these powerful features. Swipe left to discover more!',
                          style: TextStyle(
                            fontSize: 15,
                            color: textColor,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 25),
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor, width: 1),
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
                          'Purpose & Features',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                        SizedBox(height: 15),
                        _buildSectionItem(
                          title: 'Purpose & Features',
                          points: [
                            _buildIconPoint(
                              icon: Icons.checklist,
                              text: 'Manage all tasks in one place - simple to-dos or complex projects',
                              color: pointColors[0],
                            ),
                            _buildIconPoint(
                              icon: Icons.notifications,
                              text: 'Smart reminders ensure you never miss important deadlines',
                              color: pointColors[1],
                            ),
                            _buildIconPoint(
                              icon: Icons.upcoming,
                              text: 'Plan ahead with dedicated future tasks view and sorting options',
                              color: pointColors[2],
                            ),
                            _buildIconPoint(
                              icon: Icons.timeline,
                              text: 'Visual timeline of upcoming tasks for better long-term planning',
                              color: pointColors[3],
                            ),
                            _buildIconPoint(
                              icon: Icons.repeat,
                              text: 'Handle recurring tasks with flexible scheduling options',
                              color: pointColors[2],
                            ),
                            _buildIconPoint(
                              icon: Icons.category,
                              text: 'Organize with customizable categories and filters',
                              color: pointColors[3],
                            ),
                            _buildIconPoint(
                              icon: Icons.insights,
                              text: 'Track progress with visual completion metrics',
                              color: pointColors[4],
                            ),
                            _buildIconPoint(
                              icon: Icons.palette,
                              text: 'Personalize with theme colors to match your style',
                              color: pointColors[5],
                            ),
                            _buildIconPoint(
                              icon: Icons.share,
                              text: 'Share task lists via CSV exports for collaboration',
                              color: pointColors[3],
                            ),
                            _buildIconPoint(
                              icon: Icons.picture_as_pdf,
                              text: 'Download today’s completed tasks as a beautifully formatted PDF',
                              color: pointColors[4],
                            ),
                            _buildIconPoint(
                              icon: Icons.edit,
                              text: 'Quick-edit functionality for fast task updates',
                              color: pointColors[4],
                            ),
                            _buildIconPoint(
                              icon: Icons.search,
                              text: 'Smart search to instantly find any task',
                              color: pointColors[5],
                            ),
                            _buildIconPoint(
                              icon: Icons.people,
                              text: 'Perfect for individuals, students, professionals and teams',
                              color: pointColors[6],
                              isSummary: true,
                            ),
                          ],
                        ),
                        _buildSectionItem(
                          title: 'Version',
                          points: [
                            _buildPoint(
                              text: '1.0.0',
                              color: pointColors[0],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor, width: 1),
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
                        _buildSectionItem(
                          title: 'Home Screen Overview',
                          points: [
                            _buildSubSectionHeader('1. Task Navigation'),
                            _buildNumberedPoint(
                              number: 1,
                              text: 'Non-Repeated: View all current and upcoming tasks',
                              color: pointColors[0],
                            ),
                            _buildNumberedPoint(
                              number: 2,
                              text: 'Completed: Review finished tasks',
                              color: pointColors[1],
                            ),
                            _buildNumberedPoint(
                              number: 3,
                              text: 'Repeated: Manage recurring tasks',
                              color: pointColors[2],
                            ),
                            SizedBox(height: 8),
                            _buildSubSectionHeader('2. App Settings'),
                            _buildPoint(
                              text: 'Theme toggle: Switch between light/dark mode',
                              color: pointColors[3],
                            ),
                            _buildPoint(
                              text: 'Color customization: Choose from presets or custom colors',
                              color: pointColors[4],
                            ),
                            _buildPoint(
                              text: 'Notification control: Enable/disable reminders',
                              color: pointColors[5],
                            ),
                            SizedBox(height: 8),
                            _buildSubSectionHeader('3. Categories System'),
                            _buildPoint(
                              text: 'Add: Create new categories via FAB',
                              color: pointColors[0],
                            ),
                            _buildPoint(
                              text: 'Edit: Modify names with pencil icon',
                              color: pointColors[1],
                            ),
                            _buildPoint(
                              text: 'Delete: Remove via swipe or trash icon',
                              color: pointColors[2],
                            ),
                            _buildPoint(
                              text: 'Sync: Changes apply across all views instantly',
                              color: pointColors[3],
                            ),
                          ],
                        ),
                        _buildSectionItem(
                          title: 'Non-Repeated Tasks Management',
                          points: [
                            // Viewing Tasks
                            _buildSubSectionHeader('Viewing Tasks'),
                            _buildPoint(
                              text: 'See all today\'s tasks in a clean, categorized list',
                              color: pointColors[0],
                            ),
                            _buildPoint(
                              text: 'View upcoming future tasks with sort options (by date or title)',
                              color: pointColors[1],
                            ),
                            _buildPoint(
                              text: 'Filter tasks by category for focused work in both today and future views',
                              color: pointColors[2],
                            ),
                            _buildPoint(
                              text: 'Quickly identify overdue tasks and upcoming deadlines',
                              color: pointColors[3],
                            ),
                            _buildPoint(
                              text: 'Toggle between today and future tasks with a single tap',
                              color: pointColors[4],
                            ),

                            // Adding Tasks
                            _buildSubSectionHeader('Adding Tasks'),
                            _buildPoint(
                              text: 'One-tap access to add new tasks',
                              color: pointColors[3],
                            ),
                            _buildPoint(
                              text: 'Comprehensive form with title, description, date/time',
                              color: pointColors[4],
                            ),
                            _buildPoint(
                              text: 'Set date/time to schedule automatic notifications',
                              color: pointColors[1],
                            ),
                            _buildPoint(
                              text: 'Add multiple subtasks for complex tasks',
                              color: pointColors[5],
                            ),
                            _buildPoint(
                              text: 'Auto-save drafts protect your work',
                              color: pointColors[6],
                            ),

                            // Task Details
                            _buildSubSectionHeader('Task Details'),
                            _buildPoint(
                              text: 'Tap any task to view complete details',
                              color: pointColors[0],
                            ),
                            _buildPoint(
                              text: 'See all subtasks in checklist format',
                              color: pointColors[1],
                            ),
                            _buildPoint(
                              text: 'Share tasks as CSV files for backup/collaboration',
                              color: pointColors[2],
                            ),
                            _buildPoint(
                              text: 'Quick actions: complete, edit, or delete',
                              color: pointColors[3],
                            ),

                            // Editing Tasks
                            _buildSubSectionHeader('Editing Tasks'),
                            _buildPoint(
                              text: 'Modify all task fields with auto-save',
                              color: pointColors[4],
                            ),
                            _buildPoint(
                              text: 'Intuitive date/time picker prevents errors',
                              color: pointColors[5],
                            ),
                            _buildPoint(
                              text: 'Confirmation dialogs prevent accidental changes',
                              color: pointColors[6],
                            ),
                            _buildPoint(
                              text: 'Notifications auto-update when dates change',
                              color: pointColors[0],
                            ),

                            // Notifications
                            _buildSubSectionHeader('Notifications'),
                            _buildPoint(
                              text: 'Automatic reminders for upcoming tasks',
                              color: pointColors[1],
                            ),
                            _buildPoint(
                              text: 'Dedicated notifications management screen',
                              color: pointColors[2],
                            ),
                            _buildPoint(
                              text: 'Swipe or tap to cancel individual reminders',
                              color: pointColors[3],
                            ),
                            _buildPoint(
                              text: 'Bulk clear all notifications when needed',
                              color: pointColors[4],
                            ),
                            _buildPoint(
                              text: 'Persistent across app restarts',
                              color: pointColors[5],
                            ),
                          ],
                        ),
                        _buildSectionItem(
                          title: 'Completed Tasks',
                          points: [
                            _buildSubSectionHeader('Non-Repeated Tasks'),
                            _buildPoint(
                              text: 'View today\'s completed tasks',
                              color: pointColors[0],
                            ),
                            _buildPoint(
                              text: 'Quick undo or delete options',
                              color: pointColors[1],
                            ),

                            _buildSubSectionHeader('Repeated Tasks'),
                            _buildPoint(
                              text: 'See past completed instances',
                              color: pointColors[2],
                            ),
                            _buildPoint(
                              text: 'Organized by parent task',
                              color: pointColors[3],
                            ),
                            _buildPoint(
                              text: 'Manage individual instances',
                              color: pointColors[4],
                            ),

                            _buildSubSectionHeader('Features'),
                            _buildPoint(
                              text: 'Confirmation for important actions',
                              color: pointColors[5],
                            ),
                            _buildPoint(
                              text: 'Works in light/dark mode',
                              color: pointColors[0],
                            ),
                          ],
                        ),
                        _buildSectionItem(
                          title: 'Repeated Tasks',
                          points: [
                            _buildSubSectionHeader('View & Organize'),
                            _buildPoint(
                              text: 'Filter tasks by categories',
                              color: pointColors[0],
                            ),
                            _buildPoint(
                              text: 'See task details at a glance',
                              color: pointColors[1],
                            ),
                            _buildPoint(
                              text: 'Clear display of next due date',
                              color: pointColors[2],
                            ),

                            _buildSubSectionHeader('Create Tasks'),
                            _buildPoint(
                              text: 'Set time and repeat days',
                              color: pointColors[3],
                            ),
                            _buildPoint(
                              text: 'Add multiple subtasks',
                              color: pointColors[4],
                            ),
                            _buildPoint(
                              text: 'Preview upcoming dates',
                              color: pointColors[5],
                            ),

                            _buildSubSectionHeader('Task Details'),
                            _buildPoint(
                              text: 'View all task information',
                              color: pointColors[0],
                            ),
                            _buildPoint(
                              text: 'See subtasks checklist',
                              color: pointColors[1],
                            ),
                            _buildPoint(
                              text: 'Export task data',
                              color: pointColors[2],
                            ),

                            _buildSubSectionHeader('Edit Tasks'),
                            _buildPoint(
                              text: 'Modify any task details',
                              color: pointColors[3],
                            ),
                            _buildPoint(
                              text: 'Update repeat schedule',
                              color: pointColors[4],
                            ),
                            _buildPoint(
                              text: 'Manage subtasks easily',
                              color: pointColors[5],
                            ),

                            _buildSubSectionHeader('Notifications'),
                            _buildPoint(
                              text: 'View all scheduled reminders',
                              color: pointColors[0],
                            ),
                            _buildPoint(
                              text: 'Swipe to cancel notifications',
                              color: pointColors[1],
                            ),
                            _buildPoint(
                              text: 'Clear all with one tap',
                              color: pointColors[2],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: 30),
                Text(
                  'Developed by: AK~~37\nContact: support@taskmanager.com',
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: textColor,
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
}






