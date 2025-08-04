import 'package:flutter/material.dart';

class BlogPost {
  final int id;
  final String title;
  final String content;
  final DateTime createdAt;
  final List<String> imageUrls;
  final List<BlogComment> comments;

  BlogPost({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.imageUrls,
    required this.comments,
  });

  factory BlogPost.fromJson(Map<String, dynamic> json) {
    return BlogPost(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      imageUrls:
          (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      comments:
          (json['comments'] as List<dynamic>?)
              ?.map((e) => BlogComment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'imageUrls': imageUrls,
      'comments': comments.map((e) => e.toJson()).toList(),
    };
  }
}

class BlogComment {
  final int id;
  final String authorName;
  final String content;
  final DateTime createdAt;

  BlogComment({
    required this.id,
    required this.authorName,
    required this.content,
    required this.createdAt,
  });

  factory BlogComment.fromJson(Map<String, dynamic> json) {
    return BlogComment(
      id: json['id'] as int,
      authorName: json['authorName'] as String? ?? 'Anonymous',
      content: json['content'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorName': authorName,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
