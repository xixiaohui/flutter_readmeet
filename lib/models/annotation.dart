enum AnnotationType { highlight, underline }

class Annotation {
  final String id;
  final String blogId;
  final int startOffset;
  final int endOffset;
  final String selectedText;
  final AnnotationType type;
  final int color;
  final List<String> notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Annotation({
    required this.id,
    required this.blogId,
    required this.startOffset,
    required this.endOffset,
    required this.selectedText,
    required this.type,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
    this.notes = const [],
  });

  bool get hasNote => notes.isNotEmpty;

  /// Whether this annotation's offset range intersects [start, end).
  bool intersects(int start, int end) =>
      startOffset < end && endOffset > start;

  Map<String, dynamic> toJson() => {
        'id': id,
        'blogId': blogId,
        'startOffset': startOffset,
        'endOffset': endOffset,
        'selectedText': selectedText,
        'type': type.name,
        'color': color,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Annotation.fromJson(Map<String, dynamic> json) {
    final notesRaw = json['notes'];
    final notesList = <String>[];
    // Support migration from old single-note format
    if (notesRaw is List) {
      notesList.addAll(notesRaw.cast<String>());
    } else if (json['note'] is String && (json['note'] as String).isNotEmpty) {
      notesList.add(json['note'] as String);
    }
    return Annotation(
      id: json['id'] as String,
      blogId: json['blogId'] as String,
      startOffset: json['startOffset'] as int,
      endOffset: json['endOffset'] as int,
      selectedText: json['selectedText'] as String,
      type: AnnotationType.values.byName(json['type'] as String),
      color: json['color'] as int,
      notes: notesList,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Annotation copyWith({
    int? color,
    List<String>? notes,
  }) =>
      Annotation(
        id: id,
        blogId: blogId,
        startOffset: startOffset,
        endOffset: endOffset,
        selectedText: selectedText,
        type: type,
        color: color ?? this.color,
        notes: notes ?? this.notes,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );
}

class AnnotationColors {
  static const int yellow = 0x80FFEB3B;
  static const int green = 0x804CAF50;
  static const int blue = 0x802196F3;
  static const int pink = 0x80E91E63;
  static const int orange = 0x80FF9800;

  static const int red = 0xFFE53935;
  static const int black = 0xFF1D1D1F;

  static const List<int> highlightColors = [yellow, green, blue, pink, orange];
  static const List<int> underlineColors = [red, black];
}
