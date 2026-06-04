class ReadingProgress {
  final String blogId;
  final int pageIndex;
  final int totalPages;
  final double progress; // 0.0 ~ 1.0
  final String? blogTitle;
  final String? coverImg;
  final DateTime updatedAt;

  const ReadingProgress({
    required this.blogId,
    required this.pageIndex,
    required this.totalPages,
    required this.progress,
    this.blogTitle,
    this.coverImg,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'blogId': blogId,
        'pageIndex': pageIndex,
        'totalPages': totalPages,
        'progress': progress,
        'blogTitle': blogTitle,
        'coverImg': coverImg,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory ReadingProgress.fromJson(Map<String, dynamic> json) =>
      ReadingProgress(
        blogId: json['blogId'] as String,
        pageIndex: (json['pageIndex'] as num?)?.toInt() ?? 0,
        totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
        progress: (json['progress'] as num).toDouble(),
        blogTitle: json['blogTitle'] as String?,
        coverImg: json['coverImg'] as String?,
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  String get progressText => '${(progress * 100).toInt()}%';
}
