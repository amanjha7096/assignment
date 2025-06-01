import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/user/user_bloc.dart';
import '../bloc/user/user_event.dart';
import '../bloc/user/user_state.dart';
import '../models/post.dart';
import '../widgets/post_card.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _tagsController = TextEditingController();
  final int _defaultUserId = 1234; // Default user ID for local posts

  @override
  void initState() {
    super.initState();
    // Add listeners to update preview dynamically
    _titleController.addListener(_updatePreview);
    _bodyController.addListener(_updatePreview);
    _tagsController.addListener(_updatePreview);
  }

  @override
  void dispose() {
    _titleController
      ..removeListener(_updatePreview)
      ..dispose();
    _bodyController
      ..removeListener(_updatePreview)
      ..dispose();
    _tagsController
      ..removeListener(_updatePreview)
      ..dispose();
    super.dispose();
  }

  void _updatePreview() {
    setState(() {});
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final tags = _tagsController.text.isEmpty
          ? <String>[]
          : _tagsController.text.split(',').map((tag) => tag.trim()).toList();
      context.read<UserBloc>().add(
        CreatePost(userId: _defaultUserId, title: _titleController.text, body: _bodyController.text, tags: tags),
      );
    }
  }

  Future<void> _onRefresh() async {
    // Minimal refresh: Clear form or reload state if needed
    setState(() {
      _titleController.clear();
      _bodyController.clear();
      _tagsController.clear();
    });
  }

  // Create a Post object for preview
  Post _buildPreviewPost() {
    return Post(
      id: 0, // Dummy ID for preview
      userId: _defaultUserId,
      title: _titleController.text.isEmpty ? 'Enter a title' : _titleController.text,
      body: _bodyController.text.isEmpty ? 'Enter the post body' : _bodyController.text,
      tags: _tagsController.text.isEmpty
          ? ['preview']
          : _tagsController.text.split(',').map((tag) => tag.trim()).toList(),
      reactions: Reactions(likes: 0, dislikes: 0),
      views: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Post',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).colorScheme.background,
        child: BlocListener<UserBloc, UserState>(
          listener: (context, state) {
            if (state.localPostsStatus == DataStatus.loaded) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Post created successfully',
                    style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                ),
              );
            } else if (state.localPostsStatus == DataStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.localPostsError ?? 'Failed to create post',
                    style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        labelStyle: Theme.of(context).textTheme.bodyMedium,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainer,
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _bodyController,
                      decoration: InputDecoration(
                        labelText: 'Body',
                        labelStyle: Theme.of(context).textTheme.bodyMedium,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainer,
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the post body';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _tagsController,
                      decoration: InputDecoration(
                        labelText: 'Tags (comma-separated, optional)',
                        labelStyle: Theme.of(context).textTheme.bodyMedium,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainer,
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    Text('Preview', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    PostCard(post: _buildPreviewPost()),
                    const SizedBox(height: 24),
                    Center(
                      child: BlocBuilder<UserBloc, UserState>(
                        builder: (context, state) {
                          return state.localPostsStatus == DataStatus.loading
                              ? CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                                )
                              : ElevatedButton(
                                  onPressed: _submitForm,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: Text(
                                    'Create Post',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
