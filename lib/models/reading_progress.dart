class ReadingProgress {
  final String blogId;
  final double scrollOffset;
  final double progress; // 0.0 ~ 1.0
  final String? blogTitle;
  final String? coverImg;
  final DateTime updatedAt;

  const ReadingProgress({
    required this.blogId,
    required this.scrollOffset,
    required this.progress,
    this.blogTitle,
    this.coverImg,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'blogId': blogId,
        'scrollOffset': scrollOffset,
        'progress': progress,
        'blogTitle': blogTitle,
        'coverImg': coverImg,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory ReadingProgress.fromJson(Map<String, dynamic> json) =>
      ReadingProgress(
        blogId: json['blogId'] as String,
        scrollOffset: (json['scrollOffset'] as num).toDouble(),
        progress: (json['progress'] as num).toDouble(),
        blogTitle: json['blogTitle'] as String?,
        coverImg: json['coverImg'] as String?,
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  String get progressText => '${(progress * 100).toInt()}%';
}
