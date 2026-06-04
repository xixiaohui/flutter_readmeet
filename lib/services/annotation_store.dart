import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/annotation.dart';

class AnnotationStore extends ChangeNotifier {
  static const _prefix = 'annotations_';

  List<Annotation> _annotations = [];
  String? _blogId;

  List<Annotation> get annotations => List.unmodifiable(_annotations);
  int get count => _annotations.length;

  /// Annotations with notes (comments).
  List<Annotation> get annotatedWithNotes =>
      _annotations.where((a) => a.hasNote).toList();

  Future<void> load(String blogId) async {
    _blogId = blogId;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_prefix$blogId');
      if (raw != null) {
        final list = (json.decode(raw) as List<dynamic>)
            .map((e) => Annotation.fromJson(e as Map<String, dynamic>))
            .toList();
        _annotations = list;
      } else {
        _annotations = [];
      }
    } catch (_) {
      _annotations = [];
    }
    notifyListeners();
  }

  Future<void> add({
    required String selectedText,
    required int startOffset,
    required int endOffset,
    required AnnotationType type,
    required int color,
    List<String> notes = const [],
    String? blogTitle,
  }) async {
    final now = DateTime.now();
    final ann = Annotation(
      id: '${now.millisecondsSinceEpoch}_${_annotations.length}',
      blogId: _blogId ?? '',
      blogTitle: blogTitle,
      startOffset: startOffset,
      endOffset: endOffset,
      selectedText: selectedText,
      type: type,
      color: color,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
    _annotations.add(ann);
    notifyListeners();
    await _persist();
  }

  Future<void> update(String id, {int? color, List<String>? notes}) async {
    final idx = _annotations.indexWhere((a) => a.id == id);
    if (idx == -1) return;
    _annotations[idx] = _annotations[idx].copyWith(color: color, notes: notes);
    notifyListeners();
    await _persist();
  }

  Future<void> delete(String id) async {
    _annotations.removeWhere((a) => a.id == id);
    notifyListeners();
    await _persist();
  }

  /// All annotations that intersect the given offset range.
  List<Annotation> annotationsInRange(int start, int end) =>
      _annotations.where((a) => a.intersects(start, end)).toList();

  /// Check if adding a new annotation at [start, end) would overlap an
  /// existing annotation of the same type and color.
  bool hasDuplicate(int start, int end, AnnotationType type, int color) =>
      _annotations.any((a) =>
          a.type == type &&
          a.color == color &&
          a.intersects(start, end) &&
          a.startOffset == start &&
          a.endOffset == end);

  Future<void> _persist() async {
    if (_blogId == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr =
          json.encode(_annotations.map((a) => a.toJson()).toList());
      await prefs.setString('$_prefix$_blogId', jsonStr);
    } catch (_) {
      // Silently ignore persistence failures
    }
  }
}
