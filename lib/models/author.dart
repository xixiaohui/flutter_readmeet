class Author {
  final String? name;
  final String? avatar;

  const Author({this.name, this.avatar});

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      name: json['name'] as String?,
      avatar: json['avatar'] as String?,
    );
  }
}
