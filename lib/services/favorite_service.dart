import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/favorite.dart';

class FavoriteService extends ChangeNotifier {
  static const _key = 'favorites';

  List<Favorite> _favorites = [];
  final Set<String> _ids = {};

  List<Favorite> get favorites => List.unmodifiable(_favorites);
  int get count => _favorites.length;

  bool isFavorited(String blogId) => _ids.contains(blogId);

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        final list = (json.decode(raw) as List<dynamic>)
            .map((e) => Favorite.fromJson(e as Map<String, dynamic>))
            .toList();
        _favorites = list;
        _ids.clear();
        _ids.addAll(list.map((f) => f.blogId));
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> add({
    required String blogId,
    required String title,
    required String authorName,
    String? coverImg,
  }) async {
    if (_ids.contains(blogId)) return;
    final fav = Favorite(
      blogId: blogId,
      title: title,
      authorName: authorName,
      coverImg: coverImg,
      savedAt: DateTime.now(),
    );
    _favorites.insert(0, fav);
    _ids.add(blogId);
    notifyListeners();
    await _persist();
  }

  Future<void> remove(String blogId) async {
    if (!_ids.contains(blogId)) return;
    _favorites.removeWhere((f) => f.blogId == blogId);
    _ids.remove(blogId);
    notifyListeners();
    await _persist();
  }

  Future<void> toggle({
    required String blogId,
    required String title,
    required String authorName,
    String? coverImg,
  }) async {
    if (isFavorited(blogId)) {
      await remove(blogId);
    } else {
      await add(
        blogId: blogId,
        title: title,
        authorName: authorName,
        coverImg: coverImg,
      );
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr =
          json.encode(_favorites.map((f) => f.toJson()).toList());
      await prefs.setString(_key, jsonStr);
    } catch (_) {}
  }
}
