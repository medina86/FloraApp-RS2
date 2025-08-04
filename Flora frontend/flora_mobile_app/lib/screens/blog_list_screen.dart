import 'package:flutter/material.dart';
import 'package:flora_mobile_app/models/blog_post.dart';
import 'package:flora_mobile_app/providers/blog_api.dart';
import 'package:flora_mobile_app/screens/blog_post_detail_screen.dart';
import 'package:flora_mobile_app/helpers/image_loader.dart';
import 'package:flora_mobile_app/providers/blog_provider_enhanced.dart';

class BlogListScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final bool fromHomeScreen;

  const BlogListScreen({Key? key, this.onBack, this.fromHomeScreen = false})
    : super(key: key);

  @override
  State<BlogListScreen> createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  List<BlogPost> _blogPosts = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBlogPosts();
  }

  Future<void> _loadBlogPosts({String? searchTerm}) async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final posts = await BlogApiService.getBlogPosts(searchTerm: searchTerm);

      if (mounted) {
        setState(() {
          _blogPosts = posts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading blog posts: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _onSearch() {
    _loadBlogPosts(searchTerm: _searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: widget.fromHomeScreen
            ? null
            : IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Color.fromARGB(255, 170, 46, 92),
                ),
                onPressed: widget.onBack ?? () => Navigator.of(context).pop(),
              ),
        title: const Text(
          'Flora Blog',
          style: TextStyle(
            color: Color.fromARGB(255, 170, 46, 92),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search blog posts...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 0,
                ),
              ),
              onSubmitted: (_) => _onSearch(),
            ),
          ),
          Expanded(
            child: _isLoading
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
                : _blogPosts.isEmpty
                ? const Center(child: Text('No blog posts found.'))
                : RefreshIndicator(
                    onRefresh: () => _loadBlogPosts(),
                    color: const Color.fromARGB(255, 170, 46, 92),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: _blogPosts.length,
                      itemBuilder: (context, index) {
                        final post = _blogPosts[index];
                        return _buildBlogPostCard(post, context);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlogPostCard(BlogPost post, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlogPostDetailScreen(
                postId: post.id,
                onBack: () => Navigator.pop(context),
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.imageUrls.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: ImageLoader.loadImage(
                  url:
                      BlogProviderEnhanced.getValidImageUrl(post.imageUrls) ??
                      '',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorWidget: Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 60,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${post.createdAt.day}-${post.createdAt.month}-${post.createdAt.year}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    post.content,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.comment, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${post.comments.length} Comments',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
