/// Category Details Screen: banner, description, search, grid/list toggle,
/// sorting (newest, popular, most viewed, most copied).
library;

import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/repository.dart';
import '../services/services.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class CategoryDetailsScreen extends StatefulWidget {
  const CategoryDetailsScreen({super.key});

  @override
  State<CategoryDetailsScreen> createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
  final _repo = DemoPromptRepository();
  List<Prompt> _all = [];
  bool _loading = true;
  String _query = '';
  bool _isGrid = true;
  int _sort = 0; // 0 newest, 1 popular, 2 most viewed, 3 most copied
  final _searchCtrl = TextEditingController();
  late Category category;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_all.isEmpty) {
      category = ModalRoute.of(context)!.settings.arguments as Category;
      _load();
    }
  }

  Future<void> _load() async {
    final prompts = await _repo.getPrompts(limit: 50);
    if (!mounted) return;
    setState(() {
      _all = prompts.where((p) => p.categoryId == category.id).toList();
      _loading = false;
    });
  }

  List<Prompt> get _visible {
    var list = _all.where((p) {
      final q = _query.toLowerCase();
      return p.title.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q) ||
          p.promptText.toLowerCase().contains(q);
    }).toList();
    switch (_sort) {
      case 1:
        list.sort((a, b) => (b.views + b.copies).compareTo(a.views + a.copies));
      case 2:
        list.sort((a, b) => (b.views + AppServices.state.localViews(b.id))
            .compareTo(a.views + AppServices.state.localViews(a.id)));
      case 3:
        list.sort((a, b) => (b.copies + AppServices.state.localCopies(b.id))
            .compareTo(a.copies + AppServices.state.localCopies(a.id)));
      default:
        list.sort((a, b) => b.publishedDate.compareTo(a.publishedDate));
    }
    return list;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(category.name),
        actions: [
          IconButton(
            icon: Icon(_isGrid ? Icons.view_list : Icons.grid_view),
            tooltip: 'Toggle view',
            onPressed: () => setState(() => _isGrid = !_isGrid),
          ),
          PopupMenuButton<int>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort',
            onSelected: (v) => setState(() => _sort = v),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 0, child: Text('Newest')),
              PopupMenuItem(value: 1, child: Text('Popular')),
              PopupMenuItem(value: 2, child: Text('Most Viewed')),
              PopupMenuItem(value: 3, child: Text('Most Copied')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 160,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                PromptImage(url: category.imageUrl),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [AppColors.background.withOpacity(0.95), Colors.transparent],
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  bottom: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(category.name,
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('${_all.length} prompts in this category',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category.description,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search within ${category.name}',
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _query = '');
                            },
                          ),
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ],
            ),
          ),
          Expanded(
            child: _visible.isEmpty
                ? const EmptyState(
                    icon: Icons.search_off,
                    title: 'No Prompts Found',
                    subtitle: 'Try a different search.',
                  )
                : _isGrid
                    ? GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 200,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: _visible.length,
                        itemBuilder: (context, i) {
                          final p = _visible[i];
                          return PromptCard(
                            prompt: p,
                            categoryName: category.name,
                            onFavoriteTap: () {
                              AppServices.state.toggleFavorite(p.id);
                              setState(() {});
                            },
                            onCopyTap: () => AppServices.copyPrompt(context, p.id, p.promptText),
                          );
                        },
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _visible.length,
                        itemBuilder: (context, i) {
                          final p = _visible[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: SizedBox(
                              height: 100,
                              child: Card(
                                clipBehavior: Clip.antiAlias,
                                child: Row(
                                  children: [
                                    SizedBox(width: 100, child: PromptImage(url: p.imageUrl)),
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
                                            const Spacer(),
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: Icon(
                                                    AppServices.state.isFavorite(p.id)
                                                        ? Icons.favorite
                                                        : Icons.favorite_border,
                                                    color: AppColors.primary,
                                                  ),
                                                  onPressed: () {
                                                    AppServices.state.toggleFavorite(p.id);
                                                    setState(() {});
                                                  },
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.copy, color: AppColors.accent),
                                                  onPressed: () => AppServices.copyPrompt(context, p.id, p.promptText),
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
