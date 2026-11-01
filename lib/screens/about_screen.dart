/// About Screen.
library;

import 'package:flutter/material.dart';

import '../services/services.dart';
import '../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('About App')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: AppColors.brandGradient,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 40),
            ),
          ),
          const SizedBox(height: 16),
          const Center(child: Text('AI PROMPT', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
          const Center(child: Text('Version 1.0.0', style: TextStyle(color: AppColors.textSecondary, fontSize: 13))),
          const SizedBox(height: 24),
          const Text(
            'AI PROMPT is a curated library of high-quality AI image prompts. '
            'Browse categories, discover trending prompts, copy them with one tap '
            'and save your favorites for quick access.',
            style: TextStyle(height: 1.6, color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 20),
          _row(Icons.person_outline, 'Developer', 'Safisafi'),
          _row(Icons.copyright, 'Copyright', '© 2026 AI PROMPT. All rights reserved.'),
          const SizedBox(height: 20),
          _btn(context, Icons.privacy_tip_outlined, 'Privacy Policy', () => Navigator.of(context).pushNamed('/privacy')),
          _btn(context, Icons.description_outlined, 'Terms & Conditions', () => Navigator.of(context).pushNamed('/terms')),
          _btn(context, Icons.mail_outline, 'Contact Us', () => Navigator.of(context).pushNamed('/contact')),
          _btn(context, Icons.share_outlined, 'Share App', () => AppServices.shareApp()),
          _btn(context, Icons.star_outline, 'Rate App', () => Navigator.of(context).pop()),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _btn(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        color: AppColors.surface,
        child: ListTile(
          leading: Icon(icon, color: AppColors.accent),
          title: Text(label, style: const TextStyle(fontSize: 15)),
          trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          onTap: onTap,
        ),
      ),
    );
  }
}
