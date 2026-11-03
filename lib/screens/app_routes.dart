/// Central route table and bottom navigation shell for the AI PROMPT app.
library;

import 'package:flutter/material.dart';

import 'about_screen.dart';
import 'categories_screen.dart';
import 'category_details_screen.dart';
import 'contact_screen.dart';
import 'favorites_screen.dart';
import 'fullscreen_image_screen.dart';
import 'home_screen.dart';
import 'latest_prompts_screen.dart';
import 'more_menu.dart';
import 'notifications_screen.dart';
import 'privacy_screen.dart';
import 'prompt_details_screen.dart';
import 'search_screen.dart';
import 'splash_screen.dart';
import 'terms_screen.dart';
import 'trending_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const SplashScreen(),
  '/shell': (context) => const HomeShell(),
  '/categories': (context) => const CategoriesScreen(),
  '/category-details': (context) => const CategoryDetailsScreen(),
  '/prompt-details': (context) => const PromptDetailsScreen(),
  '/fullscreen-image': (context) => const FullscreenImageScreen(),
  '/trending': (context) => const TrendingScreen(),
  '/latest': (context) => const LatestPromptsScreen(),
  '/notifications': (context) => const NotificationsScreen(),
  '/more': (context) => const MoreMenuScreen(),
  '/about': (context) => const AboutScreen(),
  '/contact': (context) => const ContactScreen(),
  '/privacy': (context) => const PrivacyScreen(),
  '/terms': (context) => const TermsScreen(),
};

/// Screens with the bottom navigation bar (Home, Categories, Favorites, Search).
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  final _tabs = const [
    _TabData('Home', Icons.home, Icons.home_outlined),
    _TabData('Categories', Icons.category, Icons.category_outlined),
    _TabData('Favorites', Icons.favorite, Icons.favorite_border),
    _TabData('Search', Icons.search),
  ];

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeTab(),
      const CategoriesScreen(embedded: true),
      const FavoritesScreen(embedded: true),
      const SearchScreen(embedded: true),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: _tabs
            .map((t) => NavigationDestination(
                  icon: Icon(t.outlined ?? t.icon),
                  selectedIcon: Icon(t.icon),
                  label: t.label,
                ))
            .toList(),
      ),
    );
  }
}

class _TabData {
  final String label;
  final IconData icon;
  final IconData? outlined;

  const _TabData(this.label, this.icon, [this.outlined]);
}
