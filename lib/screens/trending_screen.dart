/// Trending Screen: tabs for Today, This Week, This Month, All Time.
/// Rankings are computed from real prompt statistics.
library;

import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/repository.dart';
import '../services/services.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class TrendingScreen extends StatefulWidget {
  const TrendingScreen({super.key});

  @override
  State<TrendingScreen> createState() => _TrendingScreenState();
}

class _TrendingScreenState extends State<TrendingScreen>
    with SingleTickerProviderStateMixin {
  final _repo = DemoPromptRepository();
  List<Prompt> _all = [];
  bool _loading = true;
  late final TabController _tabCtrl;

  static const _periods = [1, 7, 30, 3650]; // days

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _load();
  }

  Future<void> _load() async {
    final prompts = await _repo.getPrompts(limit: 50);
    if (!mounted) return;
    setState(() {
      _all = prompts;
      _loading = false;
    });
  }

  int _score(Prompt p) {
    final views = p.views + AppServices.state.localViews(p.id);
    final copies = p.copies + AppServices.state.localCopies(p.id);
    return views + copies * 3;
  }

  List<Prompt> _rankedFor(int tabIndex) {
    final now = DateTime.now();
    final maxAge = _periods[tabIndex];
    var list =
        _all.where((p) => now.difference(p.publishedDate).inDays <= maxAge).toList();
    list.sort((a, b) => _score(b).compareTo(_score(a)));
    return list;
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Trending'),
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: AppColors.textPrimary,
          indicatorColor: AppColors.accent,
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'This Week'),
            Tab(text: 'This Month'),
            Tab(text: 'All Time'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabCtrl,
              children: List.generate(
                4,
                (i) => _RankedList(ranked: _rankedFor(i)),
              ),
            ),
    );
  }
}

class _RankedList extends StatelessWidget {
  final List<Prompt> ranked;

  const _RankedList({required this.ranked});

  @override
  Widget build(BuildContext context) {
    if (ranked.isEmpty) {
      return const EmptyState(
        icon: Icons.trending_up,
        title: 'No Trending Prompts',
        subtitle: 'Nothing trending in this period yet.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ranked.length,
      itemBuilder: (context, i) {
        final p = ranked[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              height: 110,
              child: Row(
                children: [
                  Container(
                    width: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: i < 3 ? AppColors.brandGradient : null,
                      color: i < 3 ? null : AppColors.surfaceHigh,
                    ),
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontSize: i < 3 ? 20 : 16,
                        fontWeight: FontWeight.bold,
                        color: i < 3 ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
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
                          const SizedBox(height: 4),
                          Text(
                            '${p.views + AppServices.state.localViews(p.id)} views • '
                            '${p.copies + AppServices.state.localCopies(p.id)} copies • '
                            '${p.favorites} favs',
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textSecondary),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(Icons.copy,
                                    color: AppColors.accent, size: 20),
                                tooltip: 'Copy prompt',
                                onPressed: () =>
                                    AppServices.copyPrompt(context, p.id, p.promptText),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context)
                                    .pushNamed('/prompt-details', arguments: p),
                                child: const Text('Details',
                                    style:
                                        TextStyle(color: AppColors.accent, fontSize: 12)),
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
    );
  }
}
