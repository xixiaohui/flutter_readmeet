class ApiConfig {
  static const String baseUrl = 'https://readmeet.club/api';

  static String get blogs => '$baseUrl/blogs';

  static String blogDetail(dynamic identifier) => '$baseUrl/blogs/$identifier';

  static String get blogSearch => '$baseUrl/blogs/search';

  static String get blogSearchAll => '$baseUrl/blogs/searchall';

  static String get blogSearchAuthor => '$baseUrl/blogs/searchauthor';

  static String get blogHero => '$baseUrl/blogs/hero';
}
