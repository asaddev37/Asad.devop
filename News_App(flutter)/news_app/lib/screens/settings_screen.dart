import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../services/database_helper.dart';
import '../services/news_service.dart';
import '../widgets/custom_loading.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  String _selectedTopic = 'Dragon Ball';
  final List<String> _topics = ['Dragon Ball', 'Anime', 'Sports', 'Finance', 'Entertainment'];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    _nicknameController.text = settingsProvider.nickname;
    _selectedTopic = settingsProvider.carouselTopic;
    print('SettingsScreen init: nickname=${_nicknameController.text}, topic=$_selectedTopic');
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.secondaryGradient),
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nickname',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nicknameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter your nickname',
                    hintStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: AppColors.midnightBlack.withOpacity(0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Carousel News Topic',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedTopic,
                  onChanged: (value) {
                    setState(() {
                      _selectedTopic = value!;
                    });
                  },
                  items: _topics.map((topic) {
                    return DropdownMenuItem(
                      value: topic,
                      child: Text(topic, style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.midnightBlack.withOpacity(0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  dropdownColor: AppColors.midnightBlack,
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _isSaving
                        ? null
                        : () async {
                      setState(() {
                        _isSaving = true;
                      });
                      print('Saving settings: nickname=${_nicknameController.text}, topic=$_selectedTopic');
                      await settingsProvider.updateSettings(_nicknameController.text, _selectedTopic);
                      await context.read<NewsService>().fetchNews(_selectedTopic, isCarousel: true);
                      print('Settings saved, carousel fetched');
                      setState(() {
                        _isSaving = false;
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neonPink,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
            if (_isSaving)
              const Center(
                child: CustomLoading(),
              ),
          ],
        ),
      ),
    );
  }
}