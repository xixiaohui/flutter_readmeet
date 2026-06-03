import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reading_progress.dart';

class ReadingProgressService {
  static const _key = 'reading_progress_map';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  /// Save or update a reading progress record.
  Future<void> save(ReadingProgress progress) async {
    final prefs = await _prefs;
    final map = _loadMap(prefs);
    map[progress.blogId] = progress.toJson();
    prefs.setString(_key, json.encode(map));
  }

  /// Get progress for a specific blog, or null if never read.
  Future<ReadingProgress?> get(String blogId) async {
    final prefs = await _prefs;
    final map = _loadMap(prefs);
    final data = map[blogId];
    if (data == null) return null;
    return ReadingProgress.fromJson(data);
  }

  /// List all reading records, sorted by most recently updated first.
  Future<List<ReadingProgress>> listAll() async {
    final prefs = await _prefs;
    final map = _loadMap(prefs);
    final list = map.values
        .map((d) => ReadingProgress.fromJson(d as Map<String, dynamic>))
        .toList();
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  /// Delete a reading record.
  Future<void> remove(String blogId) async {
    final prefs = await _prefs;
    final map = _loadMap(prefs);
    map.remove(blogId);
    prefs.setString(_key, json.encode(map));
  }

  Map<String, dynamic> _loadMap(SharedPreferences prefs) {
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return {};
    final decoded = json.decode(raw) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(k, v as Map<String, dynamic>));
  }
}
