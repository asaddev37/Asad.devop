import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_tracker_shared/task_tracker_shared.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Theme', style: Theme.of(context).textTheme.titleLarge),
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: Provider.of<ThemeProvider>(context).isDarkMode,
              onChanged: (value) {
                Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
              },
            ),
            const SizedBox(height: AppSizes.padding),
            Text('App Info', style: Theme.of(context).textTheme.titleLarge),
            const ListTile(
              title: Text('Version'),
              subtitle: Text('1.0.0'),
            ),
            const SizedBox(height: AppSizes.padding),
            Text('Privacy Policy', style: Theme.of(context).textTheme.titleLarge),
            Expanded(
              child: FutureBuilder(
                future: DefaultAssetBundle.of(context).loadString(AppStrings.privacyPolicyPath),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Markdown(data: snapshot.data!);
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}