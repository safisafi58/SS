/// Terms & Conditions Screen.
library;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  static const _sections = [
    _Section('App Usage Rules',
        'By using AI PROMPT you agree to use the app only for lawful purposes. '
        'You may browse, search, copy, favorite and share prompts for personal '
        'and commercial creative projects.'),
    _Section('Prompt Usage',
        'All prompts are provided for use with AI image generation tools. '
        'You are responsible for the images you generate and how you use them. '
        'Generated content must comply with the rules of the AI tool you use.'),
    _Section('Copyright Policy',
        'All prompts and preview images in AI PROMPT are owned by the app '
        'publisher. You may copy prompts for generation purposes but may not '
        'republish, resell or redistribute the prompt library as your own product.'),
    _Section('User Responsibilities',
        'Do not attempt to tamper with the app, bypass security rules, scrape '
        'content at scale, or use the app to create harmful, illegal or '
        'misleading content.'),
    _Section('Disclaimer',
        'Prompts are provided "as is" without warranty of any specific result. '
        'We are not responsible for the output of third-party AI tools.'),
    _Section('Terms Updates',
        'These terms may be updated from time to time. Continued use of the '
        'app after an update means you accept the revised terms.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Terms & Conditions')),
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
                    Icon(Icons.gavel, color: AppColors.accent, size: 20),
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
