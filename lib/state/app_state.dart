/// App-wide state: favorites, recent searches, notifications and stats.
///
/// Favorites and recent searches are persisted locally with shared_preferences
/// so they survive app restarts. No login is required.
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class AppState extends ChangeNotifier {
  static const _favoritesKey = 'favorite_prompt_ids';
  static const _searchesKey = 'recent_searches';
  static const _statsKey = 'local_prompt_stats';
  static const _notificationsKey = 'read_notification_ids';

  final Set<String> _favorites = {};
  final List<String> _recentSearches = [];
  final Map<String, Map<String, int>> _localStats = {};
  final Set<String> _readNotifications = {};

  bool loaded = false;

  Set<String> get favorites => _favorites;
  List<String> get recentSearches => _recentSearches;

  bool isFavorite(String promptId) => _favorites.contains(promptId);

  int localViews(String id) => _localStats[id]?['views'] ?? 0;
  int localCopies(String id) => _localStats[id]?['copies'] ?? 0;

  bool isNotificationRead(String id) => _readNotifications.contains(id);

  // ---------------------------------------------------------------------------
  // Persistence
  // ---------------------------------------------------------------------------

  Future<void> load() async {
    if (loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _favorites
      ..clear()
      ..addAll((prefs.getStringList(_favoritesKey) ?? []).toSet());
    _recentSearches
      ..clear()
      ..addAll(prefs.getStringList(_searchesKey) ?? []);
    try {
      final stats = jsonDecode(prefs.getString(_statsKey) ?? '{}') as Map<String, dynamic>;
      _localStats
        ..clear()
        ..addAll(stats.map((k, v) => MapEntry(k, Map<String, int>.from((v as Map).map((k2, v2) => MapEntry(k2 as String, v2 as int)))));
    } catch (_) {}
    _readNotifications
      ..clear()
      ..addAll((prefs.getStringList(_notificationsKey) ?? []).toSet());
    loaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, _favorites.toList());
    await prefs.setStringList(_searchesKey, _recentSearches);
    await prefs.setString(_statsKey, jsonEncode(_localStats));
    await prefs.setStringList(_notificationsKey, _readNotifications.toList());
  }

  // ---------------------------------------------------------------------------
  // Favorites
  // ---------------------------------------------------------------------------

  Future<void> toggleFavorite(String promptId) async {
    if (_favorites.contains(promptId)) {
      _favorites.remove(promptId);
    } else {
      _favorites.add(promptId);
    }
    notifyListeners();
    await _save();
  }

  Future<void> removeFavorite(String promptId) async {
    _favorites.remove(promptId);
    notifyListeners();
    await _save();
  }

  // ---------------------------------------------------------------------------
  // Searches
  // ---------------------------------------------------------------------------

  Future<void> addRecentSearch(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    _recentSearches
      ..removeWhere((s) => s.toLowerCase() == q.toLowerCase())
      ..insert(0, q);
    if (_recentSearches.length > 10) {
      _recentSearches.removeRange(10, _recentSearches.length);
    }
    notifyListeners();
    await _save();
  }

  Future<void> clearSearchHistory() async {
    _recentSearches.clear();
    notifyListeners();
    await _save();
  }

  // ---------------------------------------------------------------------------
  // Stats (local, merged with server/demo stats at display time)
  // ---------------------------------------------------------------------------

  Future<void> incrementViews(String promptId) async {
    final s = _localStats.putIfAbsent(promptId, () => {});
    s['views'] = (s['views'] ?? 0) + 1;
    notifyListeners();
    await _save();
  }

  Future<void> incrementCopies(String promptId) async {
    final s = _localStats.putIfAbsent(promptId, () => {});
    s['copies'] = (s['copies'] ?? 0) + 1;
    notifyListeners();
    await _save();
  }

  // ---------------------------------------------------------------------------
  // Notifications
  // ---------------------------------------------------------------------------

  Future<void> markNotificationRead(String id) async {
    _readNotifications.add(id);
    notifyListeners();
    await _save();
  }

  Future<void> markAllNotificationsRead(List<NotificationItem> items) async {
    for (final n in items) {
      _readNotifications.add(n.id);
    }
    notifyListeners();
    await _save();
  }
}
