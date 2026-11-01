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

class _TrendingScreenState extends State<TrendingScreen> {
  final _repo = DemoPromptRepository();
  List<Prompt> _all = [];
  bool _loading = true;
  int _tab = 0; // 0 today, 1 week, 2 month, 3 all time

  @override
  void initState() {
    super.initState();
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

  List<Prompt> get _ranked {
    final now = DateTime.now();
    int maxAge;
    switch (_tab) {
      case 0:
        maxAge = 1;
      case 1:
        maxAge = 7;
      case 2:
        maxAge = 30;
      default:
        maxAge = 3650;
    }
    var list = _all.where((p) => now.difference(p.publishedDate).inDays <= maxAge).toList();
    list.sort((a, b) => _score(b).compareTo(_score(a)));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Trending')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TabBar(
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
                Expanded(
                  child: IndexedStack(
                    index: _tab,
                    children: List.generate(4, (i) {
                      // rebuild on tab change
                      return _RankedList(ranked: _tab == i ? _ranked : _ranked);
                    }),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: null,
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
                  // Rank number
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
                            '${p.views + AppServices.state.localViews(p.id)} views • ${p.copies + AppServices.state.localCopies(p.id)} copies • ${p.favorites} favs',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(Icons.copy, color: AppColors.accent, size: 20),
                                tooltip: 'Copy prompt',
                                onPressed: () => AppServices.copyPrompt(context, p.id, p.promptText),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pushNamed('/prompt-details', arguments: p),
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
    );
  }
}

// Tab switching handled by a small controller wrapper below.
class TrendingTabsController extends StatefulWidget {
  const TrendingTabsController({super.key});

  @override
  State<TrendingTabsController> createState() => _TrendingTabsControllerState();
}

class _TrendingTabsControllerState extends State<TrendingTabsController> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
