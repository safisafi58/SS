/// Data models for the AI PROMPT app.
///
/// The public app consumes content published by a separate secure admin
/// panel. All models mirror the admin panel's Firestore/Storage schema so
/// the app can switch from demo data to Firebase data without UI changes.

class Category {
  final String id;
  final String name;
  final String imageUrl;
  final String description;
  final int promptCount;

  const Category({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.description = '',
    this.promptCount = 0,
  });
}

class Prompt {
  final String id;
  final String title;
  final String description;
  final String promptText;
  final String imageUrl;
  final String categoryId;
  final List<String> tags;
  final DateTime publishedDate;
  final bool featured;
  final bool trending;
  int views;
  int copies;
  int favorites;

  Prompt({
    required this.id,
    required this.title,
    required this.description,
    required this.promptText,
    required this.imageUrl,
    required this.categoryId,
    this.tags = const [],
    required this.publishedDate,
    this.featured = false,
    this.trending = false,
    this.views = 0,
    this.copies = 0,
    this.favorites = 0,
  });

  bool get isNew {
    final diff = DateTime.now().difference(publishedDate);
    return diff.inDays <= 7;
  }
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String type; // prompt, featured, trending, category
  final String? relatedPromptId;
  final DateTime date;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.relatedPromptId,
    required this.date,
    this.isRead = false,
  });
}
