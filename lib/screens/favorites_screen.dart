/// Favorites Screen: locally saved prompts with search and sorting.
library;

import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/repository.dart';
import '../services/services.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class FavoritesScreen extends StatefulWidget {
  final bool embedded;

  const FavoritesScreen({super.key, this.embedded = false});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _repo = DemoPromptRepository();
  List<Prompt> _all = [];
  List<Category> _categories = [];
  bool _loading = true;
  String _query = '';
  int _sort = 0; // 0 newest saved, 1 title A-Z, 2 most viewed, 3 most copied

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prompts = await _repo.getPrompts(limit: 50);
    final categories = await _repo.getCategories();
    if (!mounted) return;
    setState(() {
      _all = prompts;
      _categories = categories;
      _loading = false;
    });
  }

  String _categoryName(String id) => _categories
      .where((c) => c.id == id)
      .map((c) => c.name)
      .followedBy(['Unknown'])
      .first;

  List<Prompt> get _favorites {
    final favIds = AppServices.state.favorites;
    var list = _all.where((p) => favIds.contains(p.id)).toList();
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((p) => p.title.toLowerCase().contains(q)).toList();
    }
    switch (_sort) {
      case 1:
        list.sort((a, b) => a.title.compareTo(b.title));
      case 2:
        list.sort((a, b) => b.views.compareTo(a.views));
      case 3:
        list.sort((a, b) => b.copies.compareTo(a.copies));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final favorites = _favorites;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Favorites (${favorites.length})'),
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort',
            onSelected: (v) => setState(() => _sort = v),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 0, child: Text('Recently Saved')),
              PopupMenuItem(value: 1, child: Text('Title A-Z')),
              PopupMenuItem(value: 2, child: Text('Most Viewed')),
              PopupMenuItem(value: 3, child: Text('Most Copied')),
            ],
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search favorites',
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
                Expanded(
                  child: favorites.isEmpty
                      ? const EmptyState(
                          icon: Icons.favorite_border,
                          title: 'No Favorites Yet',
                          subtitle: 'Start Saving Your Favorite Prompts.',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: favorites.length,
                          itemBuilder: (context, i) {
                            final p = favorites[i];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Card(
                                clipBehavior: Clip.antiAlias,
                                child: SizedBox(
                                  height: 100,
                                  child: Row(
                                    children: [
                                      SizedBox(width: 110, child: PromptImage(url: p.imageUrl)),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(p.title,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                                              Text(_categoryName(p.categoryId),
                                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                              const Spacer(),
                                              Row(
                                                children: [
                                                  IconButton(
                                                    visualDensity: VisualDensity.compact,
                                                    icon: const Icon(Icons.copy, color: AppColors.accent, size: 20),
                                                    tooltip: 'Copy prompt',
                                                    onPressed: () => AppServices.copyPrompt(context, p.id, p.promptText),
                                                  ),
                                                  IconButton(
                                                    visualDensity: VisualDensity.compact,
                                                    icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
                                                    tooltip: 'Remove favorite',
                                                    onPressed: () async {
                                                      await AppServices.state.removeFavorite(p.id);
                                                      setState(() {});
                                                    },
                                                  ),
                                                  const Spacer(),
                                                  TextButton(
                                                    onPressed: () => Navigator.of(context)
                                                        .pushNamed('/prompt-details', arguments: p),
                                                    child: const Text('Details', style: TextStyle(color: AppColors.accent, fontSize: 12)),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
