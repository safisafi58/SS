/// Search Screen: search across titles, descriptions, prompt text,
/// categories and tags with filters and search history.
library;

import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/repository.dart';
import '../services/services.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class SearchScreen extends StatefulWidget {
  final bool embedded;
  final String? initialQuery;

  const SearchScreen({super.key, this.embedded = false, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _repo = DemoPromptRepository();
  final _searchCtrl = TextEditingController();
  List<Prompt> _all = [];
  List<Category> _categories = [];
  bool _loading = true;
  String _query = '';
  int _filter = 0; // 0 all, 1 categories, 2 newest, 3 popular, 4 most viewed, 5 most copied

  @override
  void initState() {
    super.initState();
    _searchCtrl.text = widget.initialQuery ?? '';
    _query = _searchCtrl.text;
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
    if (_query.isNotEmpty) {
      await AppServices.state.addRecentSearch(_query);
    }
  }

  List<Prompt> get _results {
    if (_query.isEmpty) return [];
    final q = _query.toLowerCase();
    var list = _all.where((p) {
      final catName = _categories
          .where((c) => c.id == p.categoryId)
          .map((c) => c.name)
          .join(' ')
          .toLowerCase();
      return p.title.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q) ||
          p.promptText.toLowerCase().contains(q) ||
          catName.contains(q) ||
          p.tags.any((t) => t.toLowerCase().contains(q));
    }).toList();
    switch (_filter) {
      case 2:
        list.sort((a, b) => b.publishedDate.compareTo(a.publishedDate));
      case 3:
        list.sort((a, b) => (b.views + b.copies).compareTo(a.views + a.copies));
      case 4:
        list.sort((a, b) => b.views.compareTo(a.views));
      case 5:
        list.sort((a, b) => b.copies.compareTo(a.copies));
    }
    return list;
  }

  List<Category> get _categoryResults {
    if (_query.isEmpty || _filter != 1) return [];
    final q = _query.toLowerCase();
    return _categories.where((c) => c.name.toLowerCase().contains(q)).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(String value) async {
    setState(() => _query = value);
    if (value.trim().isNotEmpty) {
      await AppServices.state.addRecentSearch(value);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = AppServices.state;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: widget.embedded ? AppBar(title: const Text('Search')) : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (!widget.embedded)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 56, 16, 8),
                    child: _searchField(),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: _searchField(),
                  ),
                _filterChips(),
                Expanded(
                  child: _query.isEmpty
                      ? _buildSuggestions(state)
                      : _buildResults(),
                ),
              ],
            ),
    );
  }

  Widget _searchField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search AI Prompts',
              suffixIcon: _searchCtrl.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _query = '');
                      },
                    ),
            ),
            onSubmitted: _submit,
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: () => _submit(_searchCtrl.text),
          child: const Text('Search'),
        ),
      ],
    );
  }

  Widget _filterChips() {
    const labels = ['All', 'Categories', 'Newest', 'Popular', 'Most Viewed', 'Most Copied'];
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: labels.length,
        itemBuilder: (context, i) {
          final selected = _filter == i;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(labels[i]),
              selected: selected,
              onSelected: (_) => setState(() => _filter = i),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSuggestions(AppStateLike state) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (state.recentSearches.isNotEmpty) ...[
          Row(
            children: [
              const Expanded(child: Text('Recent Searches', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
              TextButton(
                onPressed: () async {
                  await AppServices.state.clearSearchHistory();
                  setState(() {});
                },
                child: const Text('Clear History', style: TextStyle(color: AppColors.danger, fontSize: 12)),
              ),
            ],
          ),
          ...state.recentSearches.map(
            (s) => ListTile(
              dense: true,
              leading: const Icon(Icons.history, size: 18, color: AppColors.textSecondary),
              title: Text(s, style: const TextStyle(fontSize: 14)),
              onTap: () {
                _searchCtrl.text = s;
                _submit(s);
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
        const Text('Popular Searches', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ...['Portrait', 'Anime', 'Cars', 'Nature', 'Luxury'].map(
          (s) => ListTile(
            dense: true,
            leading: const Icon(Icons.trending_up, size: 18, color: AppColors.primary),
            title: Text(s, style: const TextStyle(fontSize: 14)),
            onTap: () {
              _searchCtrl.text = s;
              _submit(s);
            },
          ),
        ),
        const SizedBox(height: 12),
        const Text('Trending Searches', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['Neon', 'Cinematic', 'Warrior', 'Lion', 'Wedding', 'Gaming', 'Fantasy'].map((s) {
            return ActionChip(
              label: Text(s, style: const TextStyle(fontSize: 12)),
              onPressed: () {
                _searchCtrl.text = s;
                _submit(s);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildResults() {
    final prompts = _filter == 1 ? <Prompt>[] : _results;
    final categories = _categoryResults;
    if (prompts.isEmpty && categories.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off,
        title: 'No Results Found',
        subtitle: 'Try different keywords or check the spelling.',
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (categories.isNotEmpty) ...[
          const Text('Categories', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((c) => ActionChip(label: Text(c.name), onPressed: () {})).toList(),
          ),
          const SizedBox(height: 16),
        ],
        ...prompts.map(
          (p) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PromptCard(
              prompt: p,
              categoryName: _categories
                  .where((c) => c.id == p.categoryId)
                  .map((c) => c.name)
                  .followedBy(['Unknown'])
                  .first,
              onFavoriteTap: () {
                AppServices.state.toggleFavorite(p.id);
                setState(() {});
              },
              onCopyTap: () => AppServices.copyPrompt(context, p.id, p.promptText),
            ),
          ),
        ),
      ],
    );
  }
}

/// Small interface so the suggestions builder can read history without
/// depending on the concrete state class.
abstract class AppStateLike {
  List<String> get recentSearches;
}
