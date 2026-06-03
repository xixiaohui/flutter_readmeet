import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import '../models/card_item.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class BlogListResponse {
  final List<CardItem> data;
  final int total;

  const BlogListResponse({required this.data, required this.total});
}

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<BlogListResponse> getBlogs({int page = 1, int pageSize = 20}) async {
    final uri = Uri.parse(ApiConfig.blogs).replace(
      queryParameters: {
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      },
    );

    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      final list = (body['data'] as List<dynamic>)
          .map((e) => CardItem.fromJson(e as Map<String, dynamic>))
          .toList();
      final total = body['total'] as int? ?? 0;
      return BlogListResponse(data: list, total: total);
    } else {
      throw ApiException('请求失败', statusCode: response.statusCode);
    }
  }

  Future<CardItem> getBlogDetail(String id) async {
    final uri = Uri.parse(ApiConfig.blogDetail(id));

    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      return CardItem.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    } else if (response.statusCode == 404) {
      throw ApiException('文章不存在', statusCode: 404);
    } else {
      throw ApiException('请求失败', statusCode: response.statusCode);
    }
  }

  Future<List<CardItem>> searchBlogs(String query,
      {int limit = 20, int offset = 0}) async {
    final uri = Uri.parse(ApiConfig.blogSearchAll).replace(
      queryParameters: {
        'q': query,
        'limit': limit.toString(),
        'offset': offset.toString(),
      },
    );

    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final list = (json.decode(response.body) as List<dynamic>)
          .map((e) => CardItem.fromJson(e as Map<String, dynamic>))
          .toList();
      return list;
    } else if (response.statusCode == 400) {
      throw ApiException('请输入搜索关键词', statusCode: 400);
    } else {
      throw ApiException('搜索失败', statusCode: response.statusCode);
    }
  }

  Future<List<CardItem>> searchAuthor(String query,
      {int limit = 20, int offset = 0}) async {
    final uri = Uri.parse(ApiConfig.blogSearchAuthor).replace(
      queryParameters: {
        'q': query,
        'limit': limit.toString(),
        'offset': offset.toString(),
      },
    );

    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final list = (json.decode(response.body) as List<dynamic>)
          .map((e) => CardItem.fromJson(e as Map<String, dynamic>))
          .toList();
      return list;
    } else {
      throw ApiException('搜索失败', statusCode: response.statusCode);
    }
  }

  Future<CardItem> getHeroBlog(String blogIndex) async {
    final uri = Uri.parse(ApiConfig.blogHero).replace(
      queryParameters: {'blog_index': blogIndex},
    );

    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      return CardItem.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw ApiException('请求失败', statusCode: response.statusCode);
    }
  }

  void dispose() {
    _client.close();
  }
}
