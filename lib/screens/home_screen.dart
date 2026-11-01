/// Home Tab: header, search bar, featured carousel, categories,
/// trending, latest and popular sections.
library;

import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/repository.dart';
import '../services/services.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _repo = DemoPromptRepository();
  List<Prompt> _prompts = [];
  List<Category> _categories = [];
  bool _loading = true;
  bool _offline = false;
  final _searchCtrl = TextEditingController();
  final _pageCtrl = PageController(viewportFraction: 0.85);
  int _featuredIndex = 0;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() {}));
    _load();
  }

  Future<void> _load() async {
    try {
      final prompts = await _repo.getPrompts(limit: 50);
      final categories = await _repo.getCategories();
      if (!mounted) return;
      setState(() {
        _prompts = prompts;
        _categories = categories;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _offline = true;
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return _buildSkeleton();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            children: [
              if (_offline) const OfflineBanner(),
              _buildHeader(),
              _buildSearchBar(),
              _buildFeatured(),
              _buildCategories(),
              _buildTrending(),
              _buildLatest(),
              _buildPopular(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            SkeletonBox(height: 56),
            SizedBox(height: 20),
            SkeletonBox(height: 180, radius: null),
            SizedBox(height: 20),
            SkeletonBox(height: 14, width: 120),
            SizedBox(height: 12),
            SkeletonBox(height: 110),
            SizedBox(height: 20),
            SkeletonBox(height: 14, width: 140),
            SizedBox(height: 12),
            SkeletonBox(height: 160),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 10),
          const Text('AI PROMPT',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined),
            onPressed: () => Navigator.of(context).pushNamed('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_outlined),
            onPressed: () => Navigator.of(context).pushNamed('/more'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    setState(() {});
                  },
                ),
        ),
        onSubmitted: (v) {
          if (v.trim().isNotEmpty) {
            AppServices.state.addRecentSearch(v);
            Navigator.of(context).pushNamed('/search', arguments: v);
          }
        },
      ),
    );
  }

  Widget _buildFeatured() {
    final featured = _prompts.where((p) => p.featured).toList();
    if (featured.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: SectionHeader(
              title: 'Featured',
              actionLabel: 'Explore All',
              onAction: () =>
                  Navigator.of(context).pushNamed('/latest')),
        ),
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageCtrl,
            itemCount: featured.length,
            onPageChanged: (i) => setState(() => _featuredIndex = i),
            itemBuilder: (context, i) {
              final p = featured[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => Navigator.of(context)
                        .pushNamed('/prompt-details', arguments: p),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        PromptImage(url: p.imageUrl),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.9),
                                Colors.transparent
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 14,
                          right: 14,
                          bottom: 14,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.title,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () => Navigator.of(context)
                                    .pushNamed('/prompt-details', arguments: p),
                                icon: const Icon(Icons.explore, size: 18),
                                label: const Text('Explore'),
                              ),
                            ],
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
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            featured.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _featuredIndex == i ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _featuredIndex == i ? AppColors.accent : AppColors.divider,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategories() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: SectionHeader(
            title: 'Categories',
            actionLabel: 'See All',
            onAction: () => Navigator.of(context).pushNamed('/categories'),
          ),
        ),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            itemBuilder: (context, i) {
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: CategoryCard(category: _categories[i]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTrending() {
    final trending = _prompts.where((p) => p.trending).toList();
    if (trending.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: SectionHeader(
            title: 'Trending Prompts',
            actionLabel: 'See All',
            onAction: () => Navigator.of(context).pushNamed('/trending'),
          ),
        ),
        SizedBox(
          height: 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: trending.length,
            itemBuilder: (context, i) {
              final p = trending[i];
              return SizedBox(
                width: 180,
                child: PromptCard(
                  prompt: p,
                  categoryName: _categoryName(p.categoryId),
                  onFavoriteTap: () {
                    AppServices.state.toggleFavorite(p.id);
                    setState(() {});
                  },
                  onCopyTap: () =>
                      AppServices.copyPrompt(context, p.id, p.promptText),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLatest() {
    final latest = [..._prompts]
      ..sort((a, b) => b.publishedDate.compareTo(a.publishedDate));
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: SectionHeader(
            title: 'Latest Prompts',
            actionLabel: 'See All',
            onAction: () => Navigator.of(context).pushNamed('/latest'),
          ),
        ),
        SizedBox(
          height: 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: latest.length,
            itemBuilder: (context, i) {
              final p = latest[i];
              return SizedBox(
                width: 180,
                child: PromptCard(
                  prompt: p,
                  categoryName: _categoryName(p.categoryId),
                  showNewBadge: true,
                  onCopyTap: () =>
                      AppServices.copyPrompt(context, p.id, p.promptText),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPopular() {
    final popular = [..._prompts]
      ..sort((a, b) => (b.views + b.copies).compareTo(a.views + a.copies));
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: SectionHeader(title: 'Popular This Week'),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: popular.length > 3 ? 3 : popular.length,
          itemBuilder: (context, i) {
            final p = popular[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: PromptCard(
                prompt: p,
                categoryName: _categoryName(p.categoryId),
                onCopyTap: () =>
                    AppServices.copyPrompt(context, p.id, p.promptText),
              ),
            );
          },
        ),
      ],
    );
  }

  String _categoryName(String id) => _categories
      .where((c) => c.id == id)
      .map((c) => c.name)
      .followedBy(['Unknown'])
      .first;

  void _toggleFav(Prompt p) {
    AppServices.state.toggleFavorite(p.id);
    setState(() {});
  }
}
