/// Privacy Policy Screen.
library;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  static const _sections = [
    _Section('Data Collection',
        'AI PROMPT does not collect any personal data. No account, registration '
        'or login is required. We do not store your name, email or any '
        'identifiable information on our servers.'),
    _Section('Data Usage',
        'Your favorites, recent searches and usage statistics (views/copies) '
        'are stored only on your own device and are never sent to us without '
        'your explicit action.'),
    _Section('Storage Information',
        'The app stores your favorites and search history locally using secure '
        'device storage. Downloaded images are saved to your device gallery or '
        'Downloads folder.'),
    _Section('App Permissions',
        'The app may request storage/media permission only when you choose to '
        'download an image. Internet access is used to load prompt previews. '
        'No unnecessary permissions are requested.'),
    _Section('Third-Party Services',
        'Prompt images are served over the internet from content servers. '
        'If configured, Firebase may be used for content delivery and '
        'notifications. No advertising or tracking SDKs are used.'),
    _Section('Contact Information',
        'For any privacy questions, contact us at support@example.com.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _sections.length,
        itemBuilder: (context, i) {
          final s = _sections[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.security, color: AppColors.accent, size: 20),
                    const SizedBox(width: 8),
                    Text(s.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(s.body, style: const TextStyle(height: 1.6, color: AppColors.textSecondary, fontSize: 14)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Section {
  final String title;
  final String body;

  const _Section(this.title, this.body);
}
