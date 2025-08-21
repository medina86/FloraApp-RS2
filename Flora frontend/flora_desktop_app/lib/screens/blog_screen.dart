import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../layouts/admin_main_layout.dart';
import '../models/blog_post_model.dart';
import '../providers/blog_provider.dart';
import './add_blog_post_screen.dart';
import './blog_post_details_screen.dart';

class BlogScreen extends StatefulWidget {
  const BlogScreen({Key? key}) : super(key: key);

  @override
  State<BlogScreen> createState() => _BlogScreenState();
}

class _BlogScreenState extends State<BlogScreen> {
  bool _isLoading = true;
  List<BlogPost> _blogPosts = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchBlogPosts();
  }

  Future<void> _fetchBlogPosts() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final blogPosts = await BlogProvider.getBlogPosts(
        searchTerm: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      if (!mounted) return;

      setState(() {
        _blogPosts = blogPosts;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        print('Error loading blog posts: $e');
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading blog posts: $e')));
      }
    }
  }

  Future<void> _deleteBlogPost(int id) async {
    try {
      final success = await BlogProvider.deleteBlogPost(id);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Blog post deleted successfully')),
        );
        _fetchBlogPosts();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting blog post: $e')));
      }
    }
  }

  // Pomoćna metoda za dobivanje validnog URL-a slike
  String? _getValidImageUrl(List<String> urls) {
    // Filtriramo prazne URL-ove i uzimamo prvi valjan URL
    final validUrls = urls.where((url) => url.isNotEmpty).toList();
    if (validUrls.isEmpty) return null;

    // Koristimo helper metodu za formiranje punog URL-a
    return BlogProvider.getFullImageUrl(validUrls.first);
  }

  Widget _buildBlogCard(BlogPost blog) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          final adminLayoutState = context
              .findAncestorStateOfType<AdminMainLayoutState>();
          if (adminLayoutState != null) {
            adminLayoutState.setContent(
              BlogPostDetailsScreen(blogPostId: blog.id),
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (blog.imageUrls.isNotEmpty &&
                _getValidImageUrl(blog.imageUrls) != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  _getValidImageUrl(blog.imageUrls)!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print('Error loading image: ${error.toString()}');
                    return Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 50),
                      ),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          blog.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              final adminLayoutState = context
                                  .findAncestorStateOfType<
                                    AdminMainLayoutState
                                  >();
                              if (adminLayoutState != null) {
                                adminLayoutState.setContent(
                                  AddBlogPostScreen(blogPost: blog),
                                );
                              }
                            },
                            tooltip: 'Edit post',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Confirm Deletion'),
                                  content: Text(
                                    'Are you sure you want to delete "${blog.title}"? This action cannot be undone.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('CANCEL'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _deleteBlogPost(blog.id);
                                      },
                                      child: const Text(
                                        'DELETE',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            tooltip: 'Delete post',
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    blog.content,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[700], height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('dd.MM.yyyy').format(blog.createdAt),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.comment,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${blog.comments.length} comments',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Blog',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 170, 46, 92),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search blog posts...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  onSubmitted: (_) => _fetchBlogPosts(),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _fetchBlogPosts,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {
                  final adminLayoutState = context
                      .findAncestorStateOfType<AdminMainLayoutState>();
                  if (adminLayoutState != null) {
                    adminLayoutState.setContent(const AddBlogPostScreen());
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Create Post'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(color: Colors.pink),
              ),
            )
          else if (_blogPosts.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.article, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      _searchQuery.isEmpty
                          ? 'No blog posts found'
                          : 'No blog posts found for "$_searchQuery"',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        final adminLayoutState = context
                            .findAncestorStateOfType<AdminMainLayoutState>();
                        if (adminLayoutState != null) {
                          adminLayoutState.setContent(
                            const AddBlogPostScreen(),
                          );
                        }
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Create Your First Post'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView(
                children: _blogPosts
                    .map((blog) => _buildBlogCard(blog))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
