/// More Menu: navigation to all secondary screens. No login/profile/upload.
library;

import 'package:flutter/material.dart';

import '../services/services.dart';
import '../theme/app_theme.dart';

class MoreMenuScreen extends StatelessWidget {
  const MoreMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _Item(Icons.home_outlined, 'Home', () => Navigator.of(context).pushReplacementNamed('/shell')),
      _Item(Icons.category_outlined, 'Categories', () => Navigator.of(context).pushNamed('/categories')),
      _Item(Icons.trending_up, 'Trending', () => Navigator.of(context).pushNamed('/trending')),
      _Item(Icons.new_releases_outlined, 'Latest Prompts', () => Navigator.of(context).pushNamed('/latest')),
      _Item(Icons.favorite_border, 'Favorites', () => Navigator.of(context).pushNamed('/shell')),
      _Item(Icons.notifications_none, 'Notifications', () => Navigator.of(context).pushNamed('/notifications')),
      _Item(Icons.share_outlined, 'Share App', () => AppServices.shareApp()),
      _Item(Icons.star_outline, 'Rate App', () => _rate(context)),
      _Item(Icons.privacy_tip_outlined, 'Privacy Policy', () => Navigator.of(context).pushNamed('/privacy')),
      _Item(Icons.description_outlined, 'Terms & Conditions', () => Navigator.of(context).pushNamed('/terms')),
      _Item(Icons.mail_outline, 'Contact Us', () => Navigator.of(context).pushNamed('/contact')),
      _Item(Icons.info_outline, 'About App', () => Navigator.of(context).pushNamed('/about')),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('More')),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final item = items[i];
          return Card(
            color: AppColors.surface,
            child: ListTile(
              leading: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: AppColors.brandGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, color: Colors.white, size: 19),
              ),
              title: Text(item.title, style: const TextStyle(fontSize: 15)),
              trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              onTap: item.onTap,
            ),
          );
        },
      ),
    );
  }

  void _rate(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Rate AI PROMPT'),
        content: const Text('Would you like to rate us on Google Play?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Later'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening Play Store...')),
              );
              // Replace with the real store URL once published.
              // launchUrlString('https://play.google.com/store/apps/details?id=com.safisafi.aiprompt');
            },
            child: const Text('Rate'),
          ),
        ],
      ),
    );
  }
}

class _Item {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _Item(this.icon, this.title, this.onTap);
}
