import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/card_item.dart';

class ContentCacheService {
  static const _prefix = 'cache_content_';
  static const _timestampPrefix = 'cache_ts_';
  static const _ttl = Duration(hours: 24);

  /// Get cached article content for [blogId], or null if not cached / expired.
  Future<CardItem?> get(String blogId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tsStr = prefs.getString('$_timestampPrefix$blogId');
      if (tsStr == null) return null;
      final ts = DateTime.parse(tsStr);
      if (DateTime.now().difference(ts) > _ttl) return null;

      final raw = prefs.getString('$_prefix$blogId');
      if (raw == null) return null;
      return CardItem.fromJson(
          json.decode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Cache article content.
  Future<void> set(String blogId, CardItem item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          '$_prefix$blogId', json.encode(item.toJson()));
      await prefs.setString(
          '$_timestampPrefix$blogId', DateTime.now().toIso8601String());
    } catch (_) {}
  }
}
