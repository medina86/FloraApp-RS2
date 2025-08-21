import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../layouts/constants.dart';
import '../models/blog_post_model.dart';
import '../providers/auth_provider.dart';
import 'package:http_parser/http_parser.dart';

class BlogProvider {
  static String getFullImageUrl(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return imageUrl;
    } else if (imageUrl.startsWith('/')) {
      return '$baseUrl/$imageUrl';
    } else {
      return '$baseUrl/$imageUrl';
    }
  }

  static Future<List<BlogPost>> getBlogPosts({String? searchTerm}) async {
    String url = '$baseUrl/BlogPost';

    if (searchTerm != null && searchTerm.isNotEmpty) {
      url += '?FTS=$searchTerm';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: AuthProvider.getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is Map && data.containsKey('items')) {
        final items = data['items'] as List;

        for (var item in items) {
          if (item.containsKey('imageUrls')) {
            print(
              'Image URLs for blog post ${item['id']}: ${item['imageUrls']}',
            );
          }
        }

        return items.map((item) => BlogPost.fromJson(item)).toList();
      }
    }
    throw Exception('Failed to load blog posts: ${response.statusCode}');
  }

  // Dohvaćanje jednog blog posta po ID-u
  static Future<BlogPost> getBlogPostById(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/BlogPost/$id'),
      headers: AuthProvider.getHeaders(),
    );

    if (response.statusCode == 200) {
      return BlogPost.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to load blog post: ${response.statusCode}');
  }

  static Future<BlogPost> createBlogPost(
    String title,
    String content,
    List<File> images,
  ) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/BlogPost'))
      ..headers.addAll(AuthProvider.getHeaders())
      ..fields['Title'] = title
      ..fields['Content'] = content;

    for (var i = 0; i < images.length; i++) {
      var file = images[i];
      var fileExtension = file.path.split('.').last;
      var contentType = 'image/$fileExtension';

      request.files.add(
        await http.MultipartFile.fromPath(
          'Images',
          file.path,
          contentType: MediaType.parse(contentType),
        ),
      );
    }

    final response = await request.send();
    final responseData = await response.stream.toBytes();
    final responseString = String.fromCharCodes(responseData);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return BlogPost.fromJson(json.decode(responseString));
    }
    throw Exception('Failed to create blog post: $responseString');
  }

  static Future<BlogPost> updateBlogPost(
    int id,
    String title,
    String content,
    List<File> images,
  ) async {
    var request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl/BlogPost/$id'),
    );
    var headers = AuthProvider.getHeaders();

    headers.remove('Content-Type');
    request.headers.addAll(headers);

    request.fields['Title'] = title;
    request.fields['Content'] = content;

    for (var i = 0; i < images.length; i++) {
      var file = images[i];
      var fileExtension = file.path.split('.').last;
      var contentType = 'image/$fileExtension';

      request.files.add(
        await http.MultipartFile.fromPath(
          'Images',
          file.path,
          contentType: MediaType.parse(contentType),
        ),
      );
    }

    try {
      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);

      if (response.statusCode == 200) {
        return BlogPost.fromJson(json.decode(responseString));
      } else {
        throw Exception(
          'Failed to update blog post: $responseString (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Failed to update blog post: $e');
    }
  }

  static Future<bool> deleteBlogPost(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/BlogPost/$id'),
      headers: AuthProvider.getHeaders(),
    );

    return response.statusCode == 200 || response.statusCode == 204;
  }

  static Future<BlogComment> addComment(
    int blogPostId,
    String content,
    int userId,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/BlogComment'),
      headers: {
        ...AuthProvider.getHeaders(),
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'blogPostId': blogPostId,
        'content': content,
        'userId': userId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return BlogComment.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to add comment: ${response.statusCode}');
  }
}
