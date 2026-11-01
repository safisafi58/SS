/// Fullscreen Image Viewer: pinch-to-zoom, zoom controls, download, share.
library;

import 'package:flutter/material.dart';

import '../data/models.dart';
import '../services/services.dart';
import '../theme/app_theme.dart';

class FullscreenImageScreen extends StatefulWidget {
  const FullscreenImageScreen({super.key});

  @override
  State<FullscreenImageScreen> createState() => _FullscreenImageScreenState();
}

class _FullscreenImageScreenState extends State<FullscreenImageScreen> {
  final _controller = TransformationController();
  final double _minScale = 1.0;
  final double _maxScale = 4.0;
  late Prompt prompt;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    prompt = ModalRoute.of(context)!.settings.arguments as Prompt;
  }

  void _zoomBy(double factor) {
    final matrix = _controller.value * factor;
    // clamp scale
    final scale = matrix.getMaxScaleOnAxis();
    if (scale >= _minScale && scale <= _maxScale) {
      _controller.value = matrix;
    }
  }

  void _resetZoom() => _controller.value = Matrix4.identity();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(prompt.title, style: const TextStyle(color: Colors.white, fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_in, color: Colors.white),
            tooltip: 'Zoom In',
            onPressed: () => _zoomBy(1.3),
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out, color: Colors.white),
            tooltip: 'Zoom Out',
            onPressed: () => _zoomBy(1 / 1.3),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Reset Zoom',
            onPressed: _resetZoom,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (v) {
              if (v == 'download') AppServices.downloadImage(context, prompt.imageUrl);
              if (v == 'share') AppServices.sharePrompt(prompt.title, prompt.promptText);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'download', child: Text('Download Image')),
              PopupMenuItem(value: 'share', child: Text('Share Prompt')),
            ],
          ),
        ],
      ),
      body: InteractiveViewer(
        transformationController: _controller,
        minScale: _minScale,
        maxScale: _maxScale,
        panEnabled: true,
        child: Center(child: Hero(tag: 'prompt-image-${prompt.id}', child: PromptImage(url: prompt.imageUrl))),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.download, color: Colors.white),
        tooltip: 'Download Image',
        onPressed: () => AppServices.downloadImage(context, prompt.imageUrl),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
