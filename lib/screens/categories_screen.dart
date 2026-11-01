/// Categories Screen: browse all 24 categories with search and sorting.
library;

import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/repository.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'app_routes.dart';

class CategoriesScreen extends StatefulWidget {
  final bool embedded;

  const CategoriesScreen({super.key, this.embedded = false});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _repo = DemoPromptRepository();
  List<Category> _categories = [];
  bool _loading = true;
  String _query = '';
  int _sort = 0; // 0 = A-Z, 1 = Z-A, 2 = Most prompts

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final categories = await _repo.getCategories();
    if (!mounted) return;
    setState(() {
      _categories = categories;
      _loading = false;
    });
  }

  List<Category> get _visible {
    var list = _categories
        .where((c) => c.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    switch (_sort) {
      case 1:
        list.sort((a, b) => b.name.compareTo(a.name));
      case 2:
        list.sort((a, b) => b.promptCount.compareTo(a.promptCount));
      default:
        list.sort((a, b) => a.name.compareTo(b.name));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: widget.embedded
          ? AppBar(title: const Text('Categories'))
          : AppBar(title: const Text('Categories'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop())),
      body: _loading
          ? _buildSkeleton()
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Search categories',
                          ),
                          onChanged: (v) => setState(() => _query = v),
                        ),
                      ),
                      const SizedBox(width: 10),
                      PopupMenuButton<int>(
                        icon: const Icon(Icons.sort),
                        onSelected: (v) => setState(() => _sort = v),
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 0, child: Text('A to Z')),
                          PopupMenuItem(value: 1, child: Text('Z to A')),
                          PopupMenuItem(value: 2, child: Text('Most Prompts')),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _visible.isEmpty
                      ? const EmptyState(
                          icon: Icons.category_outlined,
                          title: 'No Categories Found',
                          subtitle: 'Try a different search.',
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 180,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.95,
                          ),
                          itemCount: _visible.length,
                          itemBuilder: (context, i) => CategoryCard(category: _visible[i]),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildSkeleton() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemCount: 9,
      itemBuilder: (context, i) => const PromptCardSkeleton(),
    );
  }
}
