/// Prompt Details Screen — the core screen of the app.
library;

import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/repository.dart';
import '../services/services.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class PromptDetailsScreen extends StatefulWidget {
  const PromptDetailsScreen({super.key});

  @override
  State<PromptDetailsScreen> createState() => _PromptDetailsScreenState();
}

class _PromptDetailsScreenState extends State<PromptDetailsScreen> {
  final _repo = DemoPromptRepository();
  late Prompt prompt;
  List<Prompt> _similar = [];
  List<Category> _categories = [];
  bool _expanded = false;
  bool _descriptionExpanded = false;
  bool _textSelected = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    prompt = ModalRoute.of(context)!.settings.arguments as Prompt;
    AppServices.state.incrementViews(prompt.id);
    _load();
  }

  Future<void> _load() async {
    final all = await _repo.getPrompts(limit: 50);
    final categories = await _repo.getCategories();
    if (!mounted) return;
    setState(() {
      _similar = all
          .where((p) => p.categoryId == prompt.categoryId && p.id != prompt.id)
          .toList();
      _categories = categories;
    });
  }

  String get _categoryName =>
      _categories.where((c) => c.id == prompt.categoryId).map((c) => c.name).followedBy(['Unknown']).first;

  @override
  Widget build(BuildContext context) {
    final views = prompt.views + AppServices.state.localViews(prompt.id);
    final copies = prompt.copies + AppServices.state.localCopies(prompt.id);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(prompt.title, style: const TextStyle(fontSize: 17)),
        actions: [
          IconButton(
            icon: Icon(
              AppServices.state.isFavorite(prompt.id) ? Icons.favorite : Icons.favorite_border,
              color: AppServices.state.isFavorite(prompt.id) ? AppColors.danger : null,
            ),
            tooltip: 'Add to Favorites',
            onPressed: () {
              setState(() => AppServices.state.toggleFavorite(prompt.id));
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share Prompt',
            onPressed: () => AppServices.sharePrompt(prompt.title, prompt.promptText),
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'download') AppServices.downloadImage(context, prompt.imageUrl);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'download', child: Text('Download Image')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---------------- Image preview ----------------
          Stack(
            children: [
              Hero(
                tag: 'prompt-image-${prompt.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: PromptImage(url: prompt.imageUrl),
                  ),
                ),
              ),
              Positioned(
                right: 10,
                bottom: 10,
                child: Row(
                  children: [
                    _circleBtn(
                      icon: Icons.fullscreen,
                      tooltip: 'Fullscreen',
                      onTap: () => Navigator.of(context).pushNamed('/fullscreen-image', arguments: prompt),
                    ),
                    const SizedBox(width: 8),
                    _circleBtn(
                      icon: Icons.download,
                      tooltip: 'Download',
                      onTap: () => AppServices.downloadImage(context, prompt.imageUrl),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ---------------- Info row ----------------
          Row(
            children: [
              Expanded(
                child: _infoChip('Category', _categoryName),
              ),
              const SizedBox(width: 8),
              Expanded(child: _infoChip('Published', _formatDate(prompt.publishedDate))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _infoChip('Views', '$views', icon: Icons.visibility),
              ),
              const SizedBox(width: 8),
              Expanded(child: _infoChip('Copies', '$copies', icon: Icons.copy)),
            ],
          ),
          const SizedBox(height: 16),

          // ---------------- Description ----------------
          Text(prompt.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => setState(() => _descriptionExpanded = !_descriptionExpanded),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prompt.description,
                  maxLines: _descriptionExpanded ? null : 3,
                  overflow: _descriptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
                ),
                Text(
                  _descriptionExpanded ? 'Read Less' : 'Read More',
                  style: const TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ---------------- Prompt text container ----------------
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.text_snippet_outlined, color: AppColors.accent, size: 18),
                    SizedBox(width: 6),
                    Text('PROMPT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1, color: AppColors.accent)),
                  ],
                ),
                const SizedBox(height: 12),
                SelectableText(
                  prompt.promptText,
                  showCursor: true,
                  style: const TextStyle(fontSize: 14, height: 1.6, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ---------------- Prompt action buttons ----------------
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  backgroundColor: AppColors.primary,
                ),
                onPressed: () => AppServices.copyPrompt(context, prompt.id, prompt.promptText),
                icon: const Icon(Icons.copy),
                label: const Text('Copy Prompt'),
              ),
              OutlinedButton.icon(
                onPressed: () => setState(() => _textSelected = !_textSelected),
                icon: Icon(_textSelected ? Icons.done : Icons.select_all, size: 18),
                label: Text(_textSelected ? 'Selected' : 'Select Text'),
              ),
              OutlinedButton.icon(
                onPressed: () => setState(() => _expanded = !_expanded),
                icon: Icon(_expanded ? Icons.unfold_less : Icons.unfold_more, size: 18),
                label: Text(_expanded ? 'Collapse' : 'Expand'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => AppServices.sharePrompt(prompt.title, prompt.promptText),
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('Share Prompt'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() => AppServices.state.toggleFavorite(prompt.id));
                  },
                  icon: Icon(
                    AppServices.state.isFavorite(prompt.id) ? Icons.favorite : Icons.favorite_border,
                    size: 18,
                  ),
                  label: Text(AppServices.state.isFavorite(prompt.id) ? 'Saved' : 'Save'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ---------------- Similar prompts ----------------
          if (_similar.isNotEmpty) ...[
            SectionHeader(
              title: 'Similar Prompts',
              actionLabel: 'View All',
              onAction: () => Navigator.of(context)
                  .pushNamed('/category-details', arguments: _categories.firstWhere((c) => c.id == prompt.categoryId, orElse: () => Category(id: prompt.categoryId, name: 'Category', imageUrl: prompt.imageUrl))),
            ),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _similar.length,
                itemBuilder: (context, i) => SizedBox(
                  width: 160,
                  child: PromptCard(
                    prompt: _similar[i],
                    categoryName: _categoryName,
                    onFavoriteTap: () {
                      AppServices.state.toggleFavorite(_similar[i].id);
                      setState(() {});
                    },
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _circleBtn({required IconData icon, required String tooltip, required VoidCallback onTap}) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.background.withOpacity(0.7),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(padding: const EdgeInsets.all(8), child: Icon(icon, size: 18, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _infoChip(String label, String value, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: AppColors.accent),
            const SizedBox(width: 6),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
