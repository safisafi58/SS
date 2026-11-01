/// Latest Prompts Screen: all prompts sorted by published date, newest first.
library;

import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/repository.dart';
import '../services/services.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class LatestPromptsScreen extends StatefulWidget {
  const LatestPromptsScreen({super.key});

  @override
  State<LatestPromptsScreen> createState() => _LatestPromptsScreenState();
}

class _LatestPromptsScreenState extends State<LatestPromptsScreen> {
  final _repo = DemoPromptRepository();
  List<Prompt> _prompts = [];
  bool _loading = true;
  final _scrollCtrl = ScrollController();
  static const _pageSize = 4;

  @override
  void initState() {
    super.initState();
    _load();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 100) {
        _loadMore();
      }
    });
  }

  List<Prompt> _loaded = [];
  String? _lastId;

  Future<void> _load() async {
    final prompts = await _repo.getPrompts(limit: 50);
    prompts.sort((a, b) => b.publishedDate.compareTo(a.publishedDate));
    if (!mounted) return;
    setState(() {
      _prompts = prompts;
      _loaded = prompts.sublist(0, _pageSize.clamp(0, prompts.length));
      _loading = false;
    });
  }

  void _loadMore() {
    if (_loaded.length >= _prompts.length) return;
    setState(() {
      final next = (_loaded.length + _pageSize).clamp(0, _prompts.length);
      _loaded = _prompts.sublist(0, next);
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Latest Prompts')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: _loaded.length,
              itemBuilder: (context, i) {
                final p = _loaded[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PromptCard(
                    prompt: p,
                    categoryName: 'Latest',
                    showNewBadge: p.isNew,
                    onFavoriteTap: () {
                      AppServices.state.toggleFavorite(p.id);
                      setState(() {});
                    },
                    onCopyTap: () => AppServices.copyPrompt(context, p.id, p.promptText),
                  ),
                );
              },
            ),
    );
  }
}
