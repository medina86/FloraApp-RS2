import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../layouts/admin_main_layout.dart';
import '../models/blog_post_model.dart';
import '../providers/blog_provider.dart';
import './blog_screen.dart';

class AddBlogPostScreen extends StatefulWidget {
  final BlogPost? blogPost;

  const AddBlogPostScreen({Key? key, this.blogPost}) : super(key: key);

  @override
  State<AddBlogPostScreen> createState() => _AddBlogPostScreenState();
}

class _AddBlogPostScreenState extends State<AddBlogPostScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  List<File> _selectedImages = [];
  final ImagePicker _imagePicker = ImagePicker();
  List<String> _existingImageUrls = [];
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    if (widget.blogPost != null) {
      _isEdit = true;
      _titleController.text = widget.blogPost!.title;
      _contentController.text = widget.blogPost!.content;
      _existingImageUrls = [...widget.blogPost!.imageUrls];
    }
  }

  Future<void> _pickImages() async {
    final List<XFile> pickedImages = await _imagePicker.pickMultiImage();
    if (pickedImages.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(pickedImages.map((xFile) => File(xFile.path)));
      });
    }
  }

  void _removeSelectedImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _removeExistingImage(int index) {
    setState(() {
      // Uklanjamo sliku iz filtriranih URL-ova
      final validUrls = _existingImageUrls
          .where((url) => url.isNotEmpty)
          .toList();
      final urlToRemove = validUrls[index];
      _existingImageUrls.remove(urlToRemove);
    });
  }

  Future<void> _submitBlogPost() async {
    if (!mounted) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final String title = _titleController.text;
    final String content = _contentController.text;

    try {
      if (_isEdit) {
        // Update existing post
        await BlogProvider.updateBlogPost(
          widget.blogPost!.id,
          title,
          content,
          _selectedImages,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Blog post updated successfully')),
        );
      } else {
        // Create new post
        await BlogProvider.createBlogPost(title, content, _selectedImages);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Blog post created successfully')),
        );
      }

      // Navigate back to blog list
      if (!mounted) return;
      final adminLayoutState = context
          .findAncestorStateOfType<AdminMainLayoutState>();
      if (adminLayoutState != null) {
        adminLayoutState.setContent(const BlogScreen());
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEdit ? 'Edit Blog Post' : 'Create Blog Post'),
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
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Blog Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Content',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Blog Content',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some content';
                    }
                    return null;
                  },
                  maxLines: 15,
                  minLines: 10,
                  textAlignVertical: TextAlignVertical.top,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Images',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (_existingImageUrls.isNotEmpty) ...[
                  const Text(
                    'Current Images:',
                    style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      // Filtriramo prazne URL-ove
                      itemCount: _existingImageUrls
                          .where((url) => url.isNotEmpty)
                          .length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: NetworkImage(
                                    BlogProvider.getFullImageUrl(
                                      _existingImageUrls
                                          .where((url) => url.isNotEmpty)
                                          .toList()[index],
                                    ),
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              child: CircleAvatar(
                                backgroundColor: Colors.red,
                                radius: 12,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => _removeExistingImage(index),
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                OutlinedButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Add Images'),
                ),
                if (_selectedImages.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Selected Images:',
                    style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: FileImage(_selectedImages[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              child: CircleAvatar(
                                backgroundColor: Colors.red,
                                radius: 12,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => _removeSelectedImage(index),
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitBlogPost,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      minimumSize: const Size(200, 50),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(_isEdit ? 'Update Post' : 'Create Post'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
