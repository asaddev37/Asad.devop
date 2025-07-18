import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  final bool isDarkMode;
  final Color lightModeColor;
  final Color darkModeColor;

  const PrivacyPolicyPage({
    Key? key,
    required this.isDarkMode,
    required this.lightModeColor,
    required this.darkModeColor,
  }) : super(key: key);

  Widget _buildSectionCard(String title, String content) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDarkMode ? Colors.grey[850] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = isDarkMode
        ? [darkModeColor, Colors.grey[800]!.withAlpha(78)]
        : [lightModeColor, Colors.white.withAlpha(178)];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? darkModeColor : lightModeColor,
        elevation: 4,
        title: Text(
          'Privacy Policy',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white70 : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back',
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
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionCard(
              'Introduction',
              'The Task Manager app is designed to help you organize your tasks, manage your time, and boost productivity. With features like task categorization, reminders, recurring tasks, and data exports (CSV and PDF), it serves individuals, students, professionals, and teams. We are committed to protecting your privacy and ensuring your data remains secure. This Privacy Policy explains how we handle your information and keep it safe.',
            ),
            _buildSectionCard(
              'Data Collection',
              'We collect only the data necessary to provide the app’s functionality. This includes:\n'
                  '- **Tasks**: Titles, descriptions, due dates, completion status, and categories for non-repeated and repeated tasks.\n'
                  '- **Categories**: Custom category names for task organization.\n'
                  '- **Settings**: User preferences such as theme (light/dark mode), notification settings, and color choices.\n'
                  'No personal information (e.g., name, email, or location) is collected, and we do not use analytics or tracking tools.',
            ),
            _buildSectionCard(
              'Data Storage and Security',
              'All data is stored locally on your device using a secure SQLite database. The Task Manager app operates offline, meaning your data never leaves your device unless you choose to export it (e.g., as a CSV or PDF file). Your data is protected by your device’s security features, such as passcodes or biometrics. We do not store or process your data on external servers.',
            ),
            _buildSectionCard(
              'Data Sharing',
              'We do not share your data with third parties, advertisers, or any external entities. The app does not connect to the internet for data syncing or processing. When you export tasks (e.g., via CSV or PDF), you control where the files are saved or shared using your device’s sharing options.',
            ),
            _buildSectionCard(
              'User Control',
              'You have full control over your data:\n'
                  '- **Tasks**: Create, edit, complete, undo, or delete tasks at any time.\n'
                  '- **Categories**: Add, modify, or remove categories as needed.\n'
                  '- **Exports**: Download completed tasks as beautifully formatted PDFs or export task lists as CSV files for personal use.\n'
                  '- **Settings**: Customize themes, toggle notifications, or reset preferences.\n'
                  'Deleting the app removes all data from your device, as no data is stored externally.',
            ),
            _buildSectionCard(
              'Contact Us',
              'If you have questions or concerns about this Privacy Policy or the Task Manager app, please contact us at support@taskmanagerapp.com. We are here to assist you and ensure your experience is safe and productive.',
            ),
          ],
        ),
      ),
    );
  }
}