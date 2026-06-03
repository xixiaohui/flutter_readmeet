import 'author.dart';

class CardItem {
  final String id;
  final String? img;
  final String? tag;
  final String title;
  final String? description;
  final List<Author> authors;
  final String? content;
  final String? createdAt;
  final String? slug;
  final String? blogIndex;

  const CardItem({
    required this.id,
    this.img,
    this.tag,
    required this.title,
    this.description,
    this.authors = const [],
    this.content,
    this.createdAt,
    this.slug,
    this.blogIndex,
  });

  factory CardItem.fromJson(Map<String, dynamic> json) {
    return CardItem(
      id: _toString(json['id']),
      img: _toStringOrNull(json['img']),
      tag: _toStringOrNull(json['tag']),
      title: _toString(json['title']),
      description: _toStringOrNull(json['description']),
      authors: _parseAuthors(json['authors']),
      content: _toStringOrNull(json['content']),
      createdAt: _toStringOrNull(json['created_at']),
      slug: _toStringOrNull(json['slug']),
      blogIndex: _toStringOrNull(json['blog_index']),
    );
  }

  static String _toString(dynamic value) => value?.toString() ?? '';

  static String? _toStringOrNull(dynamic value) => value?.toString();

  static List<Author> _parseAuthors(dynamic authorsValue) {
    if (authorsValue == null) return [];
    if (authorsValue is List) {
      return authorsValue
          .map((a) => Author.fromJson(a as Map<String, dynamic>))
          .toList();
    }
    if (authorsValue is String) {
      return authorsValue
          .split(';')
          .map((s) => Author(name: s.trim()))
          .where((a) => a.name?.isNotEmpty == true)
          .toList();
    }
    return [];
  }

  String get authorName =>
      authors.isNotEmpty ? (authors.first.name ?? '未知作者') : '未知作者';

  String? get authorAvatar =>
      authors.isNotEmpty ? authors.first.avatar : null;
}
