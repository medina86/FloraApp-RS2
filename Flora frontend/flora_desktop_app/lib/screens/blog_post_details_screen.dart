import 'package:flora_desktop_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../layouts/admin_main_layout.dart';
import '../models/blog_post_model.dart';
import '../providers/blog_provider.dart';
import './blog_screen.dart';
import './add_blog_post_screen.dart';

class BlogPostDetailsScreen extends StatefulWidget {
  final int blogPostId;

  const BlogPostDetailsScreen({Key? key, required this.blogPostId})
    : super(key: key);

  @override
  State<BlogPostDetailsScreen> createState() => _BlogPostDetailsScreenState();
}

class _BlogPostDetailsScreenState extends State<BlogPostDetailsScreen> {
  bool _isLoading = true;
  BlogPost? _blogPost;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchBlogPost();
  }

  Future<void> _fetchBlogPost() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final post = await BlogProvider.getBlogPostById(widget.blogPostId);

      if (!mounted) return;

      setState(() {
        _blogPost = post;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        print('Error loading blog post: $e');
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading blog post: $e')));
      }
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a comment')));
      return;
    }

    try {
      final int? currentUserId = AuthProvider.userId;

      if (currentUserId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User not logged in')),
        );
        return;
      }

      await BlogProvider.addComment(
        widget.blogPostId,
        _commentController.text,
        currentUserId,
      );

      _commentController.clear();
      _fetchBlogPost();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding comment: $e')));
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isLoading ? 'Blog Post Details' : _blogPost!.title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              final adminLayoutState = context
                  .findAncestorStateOfType<AdminMainLayoutState>();
              if (adminLayoutState != null) {
                adminLayoutState.setContent(const BlogScreen());
              }
            },
          ),
          actions: [
            if (!_isLoading && _blogPost != null)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  final adminLayoutState = context
                      .findAncestorStateOfType<AdminMainLayoutState>();
                  if (adminLayoutState != null) {
                    adminLayoutState.setContent(
                      AddBlogPostScreen(blogPost: _blogPost),
                    );
                  }
                },
              ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _blogPost == null
            ? const Center(child: Text('Blog post not found'))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Posted on ${DateFormat('dd.MM.yyyy').format(_blogPost!.createdAt)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${_blogPost!.comments.length} comments',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      _blogPost!.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Images
                    if (_blogPost!.imageUrls.isNotEmpty) ...[
                      Container(
                        height: 300,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,

                          itemCount: _blogPost!.imageUrls
                              .where((url) => url.isNotEmpty)
                              .length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.only(right: 16),
                              width: 400,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  BlogProvider.getFullImageUrl(
                                    _blogPost!.imageUrls
                                        .where((url) => url.isNotEmpty)
                                        .toList()[index],
                                  ),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    print(
                                      'Error loading image: ${error.toString()}',
                                    );
                                    return Container(
                                      width: 400,
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          size: 50,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Content
                    Text(
                      _blogPost!.content,
                      style: const TextStyle(fontSize: 16, height: 1.6),
                    ),
                    const SizedBox(height: 40),

                    // Comments section
                    const Text(
                      'Comments',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Add comment form
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: const InputDecoration(
                              hintText: 'Add a comment...',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _addComment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                          ),
                          child: const Text('Post Comment'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Comments list
                    if (_blogPost!.comments.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(
                            'No comments yet',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _blogPost!.comments.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final comment = _blogPost!.comments[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      comment.authorName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      DateFormat(
                                        'dd.MM.yyyy',
                                      ).format(comment.createdAt),
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  comment.content,
                                  style: const TextStyle(height: 1.4),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
