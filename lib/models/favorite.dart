class Favorite {
  final String blogId;
  final String title;
  final String authorName;
  final String? coverImg;
  final DateTime savedAt;

  const Favorite({
    required this.blogId,
    required this.title,
    required this.authorName,
    this.coverImg,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() => {
        'blogId': blogId,
        'title': title,
        'authorName': authorName,
        'coverImg': coverImg,
        'savedAt': savedAt.toIso8601String(),
      };

  factory Favorite.fromJson(Map<String, dynamic> json) => Favorite(
        blogId: json['blogId'] as String,
        title: json['title'] as String,
        authorName: json['authorName'] as String,
        coverImg: json['coverImg'] as String?,
        savedAt: DateTime.parse(json['savedAt'] as String),
      );
}
