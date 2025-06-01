import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/user/user_bloc.dart';
import '../bloc/user/user_event.dart';
import '../bloc/user/user_state.dart';
import '../models/post.dart';

class LocalPostsScreen extends StatefulWidget {
  const LocalPostsScreen({super.key});

  @override
  State<LocalPostsScreen> createState() => _LocalPostsScreenState();
}

class _LocalPostsScreenState extends State<LocalPostsScreen> {
  Future<void> _onRefresh(BuildContext context) async {
    // No API call needed; just rebuild to show local posts
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate refresh
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<UserBloc>().add(LoadLocalPosts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Local Posts')),
      body: RefreshIndicator(
        onRefresh: () => _onRefresh(context),
        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            if (state.localPostsStatus == DataStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.localPostsStatus == DataStatus.error) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.localPostsError ?? 'Failed to load local posts',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.error),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Trigger rebuild
                        context.read<UserBloc>().add(CreatePost(userId: 1, title: '', body: '', tags: []));
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            final localPosts = state.localPosts.values.expand((posts) => posts).toList();
            if (localPosts.isEmpty) {
              return Center(child: Text('No local posts created', style: Theme.of(context).textTheme.bodyMedium));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: localPosts.length,
              itemBuilder: (context, index) {
                final post = localPosts[index];
                return _buildPostCard(context, post);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, Post post) {
    return GestureDetector(
      onTap: () => _showPostDialog(context, post),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(child: Icon(Icons.person)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      post.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                post.body.length > 100 ? '${post.body.substring(0, 100)}...' : post.body,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: post.tags.map((tag) => Chip(label: Text(tag))).toList()),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.thumb_up, size: 16),
                      const SizedBox(width: 4),
                      Text('${post.reactions.likes}'),
                      const SizedBox(width: 12),
                      const Icon(Icons.thumb_down, size: 16),
                      const SizedBox(width: 4),
                      Text('${post.reactions.dislikes}'),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.visibility, size: 16),
                      const SizedBox(width: 4),
                      Text('${post.views} views'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPostDialog(BuildContext context, Post post) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      pageBuilder: (context, anim1, anim2) => ScaleTransition(
        scale: Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutBack)),
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(post.body, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  Wrap(spacing: 8, children: post.tags.map((tag) => Chip(label: Text(tag))).toList()),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.thumb_up, size: 16),
                      const SizedBox(width: 4),
                      Text('${post.reactions.likes} likes'),
                      const SizedBox(width: 16),
                      const Icon(Icons.thumb_down, size: 16),
                      const SizedBox(width: 4),
                      Text('${post.reactions.dislikes} dislikes'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.visibility, size: 16),
                      const SizedBox(width: 4),
                      Text('${post.views} views'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
        ),
      ),
    );
  }
}
