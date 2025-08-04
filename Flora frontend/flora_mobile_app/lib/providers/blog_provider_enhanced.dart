import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flora_mobile_app/layouts/constants.dart';
import 'package:flora_mobile_app/models/blog_post.dart';
import 'package:flora_mobile_app/providers/auth_provider.dart';

class BlogProviderEnhanced {
  static String getFullImageUrl(String imageUrl) {
    if (imageUrl.isEmpty) {
      developer.log('Empty image URL provided');
  
      return '';
    }

    if (imageUrl.contains('florablobstorage.blob.core.windows.net')) {
      developer.log('Using direct blob storage URL: $imageUrl');
      return imageUrl;
    }

    if (imageUrl.startsWith('file://')) {
      developer.log('File URLs not supported in mobile apps: $imageUrl');
      
      return '';
    }

    String fullUrl;
    if (imageUrl.startsWith('http')) {
      fullUrl = imageUrl;
    } else if (imageUrl.startsWith('/')) {
      fullUrl = '$baseUrl$imageUrl';
    } else {
      fullUrl = '$baseUrl/$imageUrl';
    }

    developer.log('Original image URL: $imageUrl');
    developer.log('Full image URL: $fullUrl');

    return fullUrl;
  }

  static Future<List<BlogPost>> getBlogPosts({String? searchTerm}) async {
    String url = '$baseUrl/BlogPost';

    if (searchTerm != null && searchTerm.isNotEmpty) {
      url += '?FTS=$searchTerm';
    }

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: AuthProvider.getHeaders(),
      );

      print('Blog posts response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<BlogPost> posts = [];

        if (data is Map && data.containsKey('items')) {
          final items = data['items'] as List;
          posts = items.map((item) => BlogPost.fromJson(item)).toList();
        } else if (data is List) {
          posts = data.map((item) => BlogPost.fromJson(item)).toList();
        }

        for (var post in posts) {
          print('Blog post ${post.id} image URLs: ${post.imageUrls}');
        }

        return posts;
      }
      throw Exception('Failed to load blog posts: ${response.statusCode}');
    } catch (e) {
      print('Error fetching blog posts: $e');
      rethrow;
    }
  }

  static Future<BlogPost> getBlogPostById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/BlogPost/$id'),
        headers: AuthProvider.getHeaders(),
      );

      if (response.statusCode == 200) {
        return BlogPost.fromJson(json.decode(response.body));
      }
      throw Exception('Failed to load blog post: ${response.statusCode}');
    } catch (e) {
      print('Error fetching blog post by ID: $e');
      rethrow;
    }
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
    print('API Base URL: $baseUrl');
    print('Trying endpoint: $baseUrl/BlogPost/comment');

    try {
      final endpoints = [
        '$baseUrl/BlogPost/comment',
        '$baseUrl/BlogPost/$blogPostId/comment', 
        '$baseUrl/BlogPost/$blogPostId/comments',
        '$baseUrl/BlogComment'
      ];
      
      http.Response? response;
      String? errorDetails;
      
      for (var endpoint in endpoints) {
        print('Trying endpoint: $endpoint');
        
        try {
          response = await http.post(
            Uri.parse(endpoint),
            headers: {
              ...AuthProvider.getHeaders(),
              'Content-Type': 'application/json',
            },
            body: json.encode(request),
          );
          
          print('Response from $endpoint: ${response.statusCode}');
          
          if (response.statusCode == 200 || response.statusCode == 201) {
            print('Success with endpoint: $endpoint');
            break; 
          } else {
            errorDetails = 'Status ${response.statusCode} from $endpoint: ${response.body}';
          }
        } catch (e) {
          print('Error with endpoint $endpoint: $e');
          errorDetails = 'Error with $endpoint: $e';
        }
      }
      
      if (response == null) {
        throw Exception('All comment API endpoints failed. Last error: $errorDetails');
      }
      
      try {
        final data = json.decode(response.body);
        print('Comment response data: $data');
        
        if (data is Map<String, dynamic>) {
          return BlogComment.fromJson(data);
        } 
        else if (data is Map && data.containsKey('data')) {
          return BlogComment.fromJson(data['data']);
        }
        else {
          print('Unexpected response format: $data');
        
          return BlogComment(
            id: DateTime.now().millisecondsSinceEpoch, 
            authorName: 'You',
            content: content,
            createdAt: DateTime.now(),
          );
        }
      } catch (e) {
        print('Error parsing comment response: $e');
        
       
        return BlogComment(
          id: DateTime.now().millisecondsSinceEpoch,
          authorName: 'You',
          content: content,
          createdAt: DateTime.now(),
        );
      }
    } catch (e) {
      print('Error adding comment: $e');
      
      String errorMsg = 'Failed to add comment: $e\n';
      errorMsg += 'Request: ${json.encode(request)}\n';
      errorMsg += 'Base URL: $baseUrl\n';
      
      throw Exception(errorMsg);
    }
  }

  static Widget buildImageErrorWidget({
    required double width,
    required double height,
    String? errorMessage,
    String? url,
  }) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, size: 50, color: Colors.grey[600]),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
            if (url != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  url,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static String? getValidImageUrl(List<String> urls) {
    
    final azureUrls = urls.where((url) => 
        url.isNotEmpty && 
        url.contains('florablobstorage.blob.core.windows.net')
    ).toList();
    
    if (azureUrls.isNotEmpty) {
      developer.log('Found Azure blob URL: ${azureUrls.first}');
      return azureUrls.first; 
    }
    final otherUrls = urls.where((url) => url.isNotEmpty).toList();
    if (otherUrls.isEmpty) {
      developer.log('No valid URLs found in list: $urls');
      return null;
    }
    developer.log('Using non-Azure URL: ${otherUrls.first}');
    return getFullImageUrl(otherUrls.first);
  }
}
