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
      id: json['id'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      imageUrls: json['imageUrls'] != null
          ? List<String>.from(json['imageUrls'])
          : [],
      comments: json['comments'] != null
          ? List<BlogComment>.from(
              json['comments'].map((x) => BlogComment.fromJson(x)),
            )
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'imageUrls': imageUrls,
      'comments': comments.map((x) => x.toJson()).toList(),
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
      id: json['id'],
      authorName: json['authorName'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
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
