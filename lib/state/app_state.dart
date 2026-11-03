/// App-wide state: favorites, recent searches, notifications and stats.
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models.dart';

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

  Future<void> load() async {
    if (loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _favorites
      ..clear()
      ..addAll((prefs.getStringList(_favoritesKey) ?? <String>[]).toSet());
    _recentSearches
      ..clear()
      ..addAll(prefs.getStringList(_searchesKey) ?? <String>[]);
    try {
      final decoded = jsonDecode(prefs.getString(_statsKey) ?? '{}');
      if (decoded is Map) {
        _localStats.clear();
        for (final entry in decoded.entries) {
          if (entry.value is Map) {
            final values = <String, int>{};
            for (final stat in (entry.value as Map).entries) {
              final value = stat.value;
              if (value is num) values[stat.key.toString()] = value.toInt();
            }
            _localStats[entry.key.toString()] = values;
          }
        }
      }
    } catch (_) {
      _localStats.clear();
    }
    _readNotifications
      ..clear()
      ..addAll((prefs.getStringList(_notificationsKey) ?? <String>[]).toSet());
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

  Future<void> toggleFavorite(String promptId) async {
    if (!_favorites.add(promptId)) _favorites.remove(promptId);
    notifyListeners();
    await _save();
  }

  Future<void> removeFavorite(String promptId) async {
    _favorites.remove(promptId);
    notifyListeners();
    await _save();
  }

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

  Future<void> incrementViews(String promptId) async {
    final stats = _localStats.putIfAbsent(promptId, () => <String, int>{});
    stats['views'] = (stats['views'] ?? 0) + 1;
    notifyListeners();
    await _save();
  }

  Future<void> incrementCopies(String promptId) async {
    final stats = _localStats.putIfAbsent(promptId, () => <String, int>{});
    stats['copies'] = (stats['copies'] ?? 0) + 1;
    notifyListeners();
    await _save();
  }

  Future<void> markNotificationRead(String id) async {
    _readNotifications.add(id);
    notifyListeners();
    await _save();
  }

  Future<void> markAllNotificationsRead(List<NotificationItem> items) async {
    _readNotifications.addAll(items.map((item) => item.id));
    notifyListeners();
    await _save();
  }
}
