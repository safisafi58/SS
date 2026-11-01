/// App-wide services: clipboard, share, download, image loading, stats.
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../state/app_state.dart';

class AppServices {
  static AppState state = AppState();

  /// Copies the FULL prompt text to the Android clipboard.
  /// Returns true on success.
  static Future<bool> copyPrompt(BuildContext context, String promptId, String promptText) async {
    try {
      await Clipboard.setData(ClipboardData(text: promptText));
      await state.incrementCopies(promptId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prompt Copied Successfully!')),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not copy. Please try again.')),
        );
      }
      return false;
    }
  }

  /// Shares prompt text using the Android share sheet.
  static Future<void> sharePrompt(String title, String promptText) async {
    await Share.share('$promptText\n\n— Shared from AI PROMPT', subject: title);
  }

  /// Shares the app.
  static Future<void> shareApp() async {
    await Share.share('Check out AI PROMPT — Create Beyond Imagination!');
  }

  /// Downloads an image to the Android gallery / Downloads folder.
  /// Requests storage permission only when required (Android 13+ uses
  /// granular media permissions handled by the system).
  static Future<void> downloadImage(BuildContext context, String url) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Downloading image...')),
    );
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) throw Exception('HTTP ${response.statusCode}');
      final bytes = response.bodyBytes;
      final dir = Directory('/storage/emulated/0/Download');
      if (!await dir.exists()) {
        final temp = await getTemporaryDirectory();
        await _save(context, temp.path, bytes);
        return;
      }
      await _save(context, dir.path, bytes);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download failed. Check your connection.')),
        );
      }
    }
  }

  static Future<void> _save(BuildContext context, String dirPath, Uint8List bytes) async {
    final name = 'ai_prompt_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final file = File('$dirPath/$name');
    await file.writeAsBytes(bytes);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image saved to ${file.path}')),
      );
    }
  }
}

/// Image widget with graceful loading/error placeholders.
class PromptImage extends StatefulWidget {
  final String url;
  final BoxFit fit;

  const PromptImage({super.key, required this.url, this.fit = BoxFit.cover});

  @override
  State<PromptImage> createState() => _PromptImageState();
}

class _PromptImageState extends State<PromptImage> {
  bool _failed = false;

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return Container(
        color: AppColorsImageFallback.surfaceHigh,
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image_outlined, color: AppColorsImageFallback.textSecondary),
      );
    }
    return Image.network(
      widget.url,
      fit: widget.fit,
      cacheWidth: 600,
      errorBuilder: (context, error, stackTrace) {
        _failed = true;
        return Container(
          color: AppColorsImageFallback.surfaceHigh,
          alignment: Alignment.center,
          child: const Icon(Icons.image_outlined, color: AppColorsImageFallback.textSecondary),
        );
      },
    );
  }
}

// Small helper to avoid importing theme into services for fallback colors.
class AppColorsImageFallback {
  static const surfaceHigh = Color(0xFF1D2447);
  static const textSecondary = Color(0xFF9FA8DA);
}
