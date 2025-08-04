import 'dart:convert';
import 'package:flora_mobile_app/models/blog_post.dart';
import 'package:flora_mobile_app/providers/base_provider.dart';
import 'package:flora_mobile_app/providers/auth_provider.dart';
import 'package:flora_mobile_app/layouts/constants.dart';
import 'package:http/http.dart' as http;

class BlogApiService {
  static Future<List<BlogPost>> getBlogPosts({String? searchTerm}) async {
    final endpoint = searchTerm != null && searchTerm.isNotEmpty
        ? '/BlogPost?FTS=$searchTerm'
        : '/BlogPost';

    return await BaseApiService.get(endpoint, (data) {
      if (data is Map<String, dynamic>) {
        final list = data['items'] ?? data['result'] ?? data['data'] ?? [];
        return (list as List).map((item) => BlogPost.fromJson(item)).toList();
      } else if (data is List) {
        return data.map((item) => BlogPost.fromJson(item)).toList();
      }
      return <BlogPost>[];
    });
  }

  static Future<BlogPost> getBlogPostById(int id) async {
    return await BaseApiService.get<BlogPost>(
      '/BlogPost/$id',
      (data) => BlogPost.fromJson(data),
    );
  }

  static Future<BlogComment> addComment(
    int blogPostId,
    int userId,
    String content,
  ) async {
    final request = {
      'blogPostId': blogPostId,
      'userId': userId,
      'content': content,
    };

    print('Sending comment request: ${json.encode(request)}');
    print('Endpoint: /BlogComment');
    print('Headers: ${AuthProvider.getHeaders()}');

    try {
      final uri = Uri.parse('$baseUrl/BlogComment');
      final headers = {
        ...AuthProvider.getHeaders(),
        'Content-Type': 'application/json',
      };

      print('Sending request to: $uri');
      print('With headers: $headers');
      print('With body: ${json.encode(request)}');

      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode(request),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Comment response received: $data');
        return BlogComment.fromJson(data);
      } else {
        throw ApiException(
          'POST /BlogComment failed: ${response.body}',
          response.statusCode,
        );
      }
    } catch (e) {
      print('Error posting comment: $e');
      rethrow;
    }
  }

  static Future<List<BlogComment>> getCommentsByBlogPostId(
    int blogPostId,
  ) async {
    return await BaseApiService.get<List<BlogComment>>(
      '/BlogComment?BlogPostId=$blogPostId',
      (data) =>
          (data as List).map((item) => BlogComment.fromJson(item)).toList(),
    );
  }
}
