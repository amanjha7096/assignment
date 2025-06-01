import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/user/user_bloc.dart';
import '../bloc/user/user_event.dart';
import '../bloc/user/user_state.dart';
import '../models/post.dart';
import '../models/todo.dart';
import '../models/user.dart';
import '../widgets/post_card.dart';
import '../widgets/todo_card.dart';

class UserDetailScreen extends StatefulWidget {
  final User user;

  const UserDetailScreen({super.key, required this.user});

  @override
  _UserDetailScreenState createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> with TickerProviderStateMixin {
  final GlobalKey<AnimatedListState> _postsListKey = GlobalKey<AnimatedListState>();
  final GlobalKey<AnimatedListState> _todosListKey = GlobalKey<AnimatedListState>();
  late AnimationController _profileAnimationController;
  late Animation<double> _profileOpacity;

  @override
  void initState() {
    super.initState();
    context.read<UserBloc>().add(FetchUserDetails(widget.user.id));
    _profileAnimationController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _profileOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _profileAnimationController, curve: Curves.easeInOut));
    _profileAnimationController.forward();
  }

  @override
  void dispose() {
    _profileAnimationController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    context.read<UserBloc>().add(FetchUserDetails(widget.user.id));
    await context.read<UserBloc>().stream.firstWhere(
      (state) => state.postsStatus != DataStatus.loading && state.todosStatus != DataStatus.loading,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).colorScheme.background,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 250,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  '${widget.user.firstName} ${widget.user.lastName}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    FadeTransition(
                      opacity: _profileOpacity,
                      child: Center(
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(widget.user.image),
                          radius: 60,
                          backgroundColor: Theme.of(context).colorScheme.background,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeTransition(
                      opacity: _profileOpacity,
                      child: Center(
                        child: Text(widget.user.role.toUpperCase(), style: Theme.of(context).textTheme.bodySmall),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Personal Details'),
                    const SizedBox(height: 8),
                    _buildDetailsCard([
                      _buildDetailRow('Email', widget.user.email),
                      _buildDetailRow('Phone', widget.user.phone),
                      _buildDetailRow('Username', widget.user.username),
                      _buildDetailRow('Age', widget.user.age.toString()),
                      _buildDetailRow('Gender', widget.user.gender),
                      _buildDetailRow('Birth Date', widget.user.birthDate),
                      _buildDetailRow('Blood Group', widget.user.bloodGroup),
                      _buildDetailRow('Height', '${widget.user.height} cm'),
                      _buildDetailRow('Weight', '${widget.user.weight} kg'),
                      _buildDetailRow('Eye Color', widget.user.eyeColor),
                      _buildDetailRow('Hair', '${widget.user.hair.color} (${widget.user.hair.type})'),
                    ]),
                    const SizedBox(height: 16),
                    _buildSectionHeader('Address'),
                    const SizedBox(height: 8),
                    _buildExpansionCard(
                      children: [
                        _buildDetailRow('Street', widget.user.address.address),
                        _buildDetailRow('City', widget.user.address.city),
                        _buildDetailRow('State', '${widget.user.address.state} (${widget.user.address.stateCode})'),
                        _buildDetailRow('Postal Code', widget.user.address.postalCode),
                        _buildDetailRow('Country', widget.user.address.country),
                        _buildDetailRow(
                          'Coordinates',
                          'Lat: ${widget.user.address.coordinates.lat}, Lng: ${widget.user.address.coordinates.lng}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSectionHeader('Company'),
                    const SizedBox(height: 8),
                    _buildExpansionCard(
                      children: [
                        _buildDetailRow('Name', widget.user.company.name),
                        _buildDetailRow('Department', widget.user.company.department),
                        _buildDetailRow('Title', widget.user.company.title),
                        _buildDetailRow('Address', widget.user.company.address.address),
                        _buildDetailRow('City', widget.user.company.address.city),
                        _buildDetailRow(
                          'State',
                          '${widget.user.company.address.state} (${widget.user.company.address.stateCode})',
                        ),
                        _buildDetailRow('Postal Code', widget.user.company.address.postalCode),
                        _buildDetailRow('Country', widget.user.company.address.country),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSectionHeader('Other Details'),
                    const SizedBox(height: 8),
                    _buildExpansionCard(
                      children: [
                        _buildDetailRow('University', widget.user.university),
                        _buildDetailRow('EIN', widget.user.ein),
                        _buildDetailRow('SSN', widget.user.ssn),
                        _buildDetailRow('IP Address', widget.user.ip),
                        _buildDetailRow('MAC Address', widget.user.macAddress),
                        _buildDetailRow('User Agent', widget.user.userAgent),
                        _buildDetailRow('Crypto', '${widget.user.crypto.coin} (${widget.user.crypto.network})'),
                        _buildDetailRow('Wallet', widget.user.crypto.wallet),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Posts'),
                    const SizedBox(height: 8),
                    BlocListener<UserBloc, UserState>(
                      listener: (context, state) {
                        if (state.postsStatus == DataStatus.error) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(state.postsError ?? 'Failed to load posts')));
                        }
                      },
                      child: BlocBuilder<UserBloc, UserState>(
                        builder: (context, state) {
                          if (state.postsStatus == DataStatus.loading) {
                            return _buildLoadingIndicator();
                          }
                          if (state.postsStatus == DataStatus.error) {
                            return _buildErrorCard(
                              context,
                              state.postsError ?? 'Failed to load posts',
                              () => context.read<UserBloc>().add(FetchUserDetails(widget.user.id)),
                            );
                          }
                          final allPosts = [
                            ...(state.localPosts[widget.user.id] ?? []),
                            ...state.posts.where((post) => post.userId == widget.user.id),
                          ];
                          return allPosts.isEmpty
                              ? _buildEmptyState('No posts available')
                              : AnimatedList(
                                  key: _postsListKey,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  initialItemCount: allPosts.length,
                                  itemBuilder: (context, index, animation) {
                                    final post = allPosts[index];
                                    return FadeTransition(
                                      opacity: animation,
                                      child: PostCard(post: post),
                                    );
                                  },
                                );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Todos'),
                    const SizedBox(height: 8),
                    BlocListener<UserBloc, UserState>(
                      listener: (context, state) {
                        if (state.todosStatus == DataStatus.error) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(state.todosError ?? 'Failed to load todos')));
                        }
                      },
                      child: BlocBuilder<UserBloc, UserState>(
                        builder: (context, state) {
                          if (state.todosStatus == DataStatus.loading) {
                            return _buildLoadingIndicator();
                          }
                          if (state.todosStatus == DataStatus.error) {
                            return _buildErrorCard(
                              context,
                              state.todosError ?? 'Failed to load todos',
                              () => context.read<UserBloc>().add(FetchUserDetails(widget.user.id)),
                            );
                          }
                          return state.todos.isEmpty
                              ? _buildEmptyState('No todos available')
                              : AnimatedList(
                                  key: _todosListKey,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  initialItemCount: state.todos.length,
                                  itemBuilder: (context, index, animation) {
                                    final todo = state.todos[index];
                                    return FadeTransition(
                                      opacity: animation,
                                      child: TodoCard(todo: todo),
                                    );
                                  },
                                );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: -50, end: 0),
      duration: const Duration(milliseconds: 500),
      builder: (context, double offset, child) {
        return Transform.translate(
          offset: Offset(offset, 0),
          child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
        );
      },
    );
  }

  Widget _buildDetailsCard(List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildExpansionCard({required List<Widget> children}) {
    return Card(
      child: ExpansionTile(
        leading: Icon(Icons.expand_more, color: Theme.of(context).colorScheme.primary),
        title: Text('Details', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String message, VoidCallback onRetry) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(child: Text(message, style: Theme.of(context).textTheme.bodyMedium)),
      ),
    );
  }
}
