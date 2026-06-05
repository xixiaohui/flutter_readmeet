import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import '../models/card_item.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String errorCode;
  const ApiException(this.message, {this.statusCode, this.errorCode = ''});

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

  static void _log(String method, Uri uri, int status, String? body) {
    debugPrint('[API] $method $uri → $status ${body != null ? '(${body.length} bytes)' : ''}');
  }

  Future<BlogListResponse> getBlogs({int page = 1, int pageSize = 20}) async {
    final uri = Uri.parse(ApiConfig.blogs).replace(
      queryParameters: {
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      },
    );

    final response = await _client.get(uri);
    _log('GET', uri, response.statusCode, response.body);

    if (response.statusCode == 200) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      final list = (body['data'] as List<dynamic>)
          .map((e) => CardItem.fromJson(e as Map<String, dynamic>))
          .toList();
      final total = body['total'] as int? ?? 0;
      return BlogListResponse(data: list, total: total);
    } else {
      throw ApiException('请求失败', statusCode: response.statusCode, errorCode: 'requestFailed');
    }
  }

  Future<CardItem> getBlogDetail(String id) async {
    final uri = Uri.parse(ApiConfig.blogDetail(id));

    final response = await _client.get(uri);
    _log('GET', uri, response.statusCode, response.body);

    if (response.statusCode == 200) {
      return CardItem.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    } else if (response.statusCode == 404) {
      throw ApiException('文章不存在', statusCode: 404, errorCode: 'articleNotFound');
    } else {
      throw ApiException('请求失败', statusCode: response.statusCode, errorCode: 'requestFailed');
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
    _log('GET', uri, response.statusCode, response.body);

    if (response.statusCode == 200) {
      final list = (json.decode(response.body) as List<dynamic>)
          .map((e) => CardItem.fromJson(e as Map<String, dynamic>))
          .toList();
      return list;
    } else if (response.statusCode == 400) {
      throw ApiException('请输入搜索关键词', statusCode: 400, errorCode: 'enterSearchKeyword');
    } else {
      throw ApiException('搜索失败', statusCode: response.statusCode, errorCode: 'searchFailed');
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
    _log('GET', uri, response.statusCode, response.body);

    if (response.statusCode == 200) {
      final list = (json.decode(response.body) as List<dynamic>)
          .map((e) => CardItem.fromJson(e as Map<String, dynamic>))
          .toList();
      return list;
    } else {
      throw ApiException('搜索失败', statusCode: response.statusCode, errorCode: 'searchFailed');
    }
  }

  Future<CardItem> getHeroBlog(String blogIndex) async {
    final uri = Uri.parse(ApiConfig.blogHero).replace(
      queryParameters: {'blog_index': blogIndex},
    );

    debugPrint('[API] GET $uri');
    final response = await _client.get(uri);
    debugPrint('[API] status=${response.statusCode} bodyLen=${response.body.length}');
    debugPrint('[API] body=${response.body.substring(0, response.body.length.clamp(0, 500))}');

    if (response.statusCode == 200) {
      return CardItem.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw ApiException('请求失败', statusCode: response.statusCode, errorCode: 'requestFailed');
    }
  }

  void dispose() {
    _client.close();
  }
}
