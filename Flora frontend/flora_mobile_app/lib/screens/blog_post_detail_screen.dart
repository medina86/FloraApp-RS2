import 'package:flutter/material.dart';
import 'package:flora_mobile_app/models/blog_post.dart';
import 'package:flora_mobile_app/providers/blog_api.dart';
import 'package:flora_mobile_app/providers/auth_provider.dart';
import 'package:flora_mobile_app/providers/blog_provider_enhanced.dart';
import 'package:flora_mobile_app/helpers/image_loader.dart';
import 'dart:developer' as developer;

class BlogPostDetailScreen extends StatefulWidget {
  final int postId;
  final VoidCallback onBack;

  const BlogPostDetailScreen({
    Key? key,
    required this.postId,
    required this.onBack,
  }) : super(key: key);

  @override
  State<BlogPostDetailScreen> createState() => _BlogPostDetailScreenState();
}

class _BlogPostDetailScreenState extends State<BlogPostDetailScreen> {
  bool _isLoading = true;
  bool _isSubmittingComment = false;
  BlogPost? _blogPost;
  String? _errorMessage;
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadBlogPost();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadBlogPost() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      developer.log('Loading blog post with ID: ${widget.postId}');
      final post = await BlogApiService.getBlogPostById(widget.postId);

      if (mounted) {
        setState(() {
          _blogPost = post;
          _isLoading = false;
        });

        developer.log('Blog post loaded: ${post.title}');
        developer.log('Image URLs: ${post.imageUrls}');
      }
    } catch (e) {
      developer.log('Error loading blog post: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading blog post: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _submitComment() async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a comment')));
      return;
    }

    final user = AuthProvider.getUser();
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to comment')),
      );
      return;
    }

    setState(() {
      _isSubmittingComment = true;
    });

    try {
      developer.log(
        'Submitting comment: BlogPostId=${_blogPost!.id}, UserId=${user.id}, Content=$comment',
      );

      // Try the enhanced provider for better error handling and debugging
      final newComment = await BlogProviderEnhanced.addComment(
        _blogPost!.id,
        user.id,
        comment,
      );

      developer.log('Comment successfully posted: ${newComment.id}');

      setState(() {
        _blogPost!.comments.add(newComment);
        _commentController.clear();
        _isSubmittingComment = false;
      });

      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      developer.log('Error posting comment: $e');

      if (mounted) {
        setState(() {
          _isSubmittingComment = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to post comment. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Blog Post',
          style: TextStyle(
            color: Color.fromARGB(255, 170, 46, 92),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color.fromARGB(255, 170, 46, 92),
          ),
          onPressed: widget.onBack,
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 170, 46, 92),
              ),
            )
          : _errorMessage != null
          ? Center(
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      if (_blogPost!.imageUrls.isNotEmpty) ...[
                        if (BlogProviderEnhanced.getValidImageUrl(
                              _blogPost!.imageUrls,
                            ) !=
                            null)
                          _buildBlogImage(
                            BlogProviderEnhanced.getValidImageUrl(
                              _blogPost!.imageUrls,
                            )!,
                          ),
                        const SizedBox(height: 20),
                      ],
                      Text(
                        _blogPost!.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Posted on ${_blogPost!.createdAt.day}/${_blogPost!.createdAt.month}/${_blogPost!.createdAt.year}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _blogPost!.content,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Divider(),
                      const SizedBox(height: 16),
                      Text(
                        'Comments (${_blogPost!.comments.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_blogPost!.comments.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          alignment: Alignment.center,
                          child: Text(
                            'No comments yet. Be the first to comment!',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                      else
                        ...(_blogPost!.comments
                            .map((comment) => _buildCommentWidget(comment))
                            .toList()),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                          maxLines: null,
                          textInputAction: TextInputAction.newline,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _isSubmittingComment ? null : _submitComment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            170,
                            46,
                            92,
                          ),
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(12),
                          minimumSize: const Size(48, 48),
                        ),
                        child: _isSubmittingComment
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.send, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildBlogImage(String imageUrl) {
    // Use the BlogProviderEnhanced to process the URL
    final processedUrl = BlogProviderEnhanced.getFullImageUrl(imageUrl);
    developer.log('Original blog image URL: $imageUrl');
    developer.log('Processed blog image URL: $processedUrl');

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ImageLoader.loadImage(
        url: processedUrl,
        width: double.infinity,
        height: 250,
        fit: BoxFit.cover,
        errorWidget: _buildImagePlaceholder(
          'Nije moguće učitati sliku: $processedUrl',
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(String reason) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 250,
        color: Colors.grey[200],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'Nije moguće učitati sliku',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              reason,
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentWidget(BlogComment comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                comment.authorName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                '${comment.createdAt.day}-${comment.createdAt.month}-${comment.createdAt.year}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(comment.content, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
