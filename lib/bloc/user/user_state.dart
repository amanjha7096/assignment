import 'package:equatable/equatable.dart';

import '../../models/post.dart';
import '../../models/todo.dart';
import '../../models/user.dart';

enum DataStatus { initial, loading, loaded, error }

class UserState extends Equatable {
  final List<User> users;
  final DataStatus usersStatus;
  final String? usersError;
  final bool hasReachedMax;
  final List<Post> posts;
  final DataStatus postsStatus;
  final String? postsError;
  final List<Todo> todos;
  final DataStatus todosStatus;
  final String? todosError;
  final Map<int, List<Post>> localPosts;
  final DataStatus localPostsStatus;
  final String? localPostsError;

  const UserState({
    this.users = const [],
    this.usersStatus = DataStatus.initial,
    this.usersError,
    this.hasReachedMax = false,
    this.posts = const [],
    this.postsStatus = DataStatus.initial,
    this.postsError,
    this.todos = const [],
    this.todosStatus = DataStatus.initial,
    this.todosError,
    this.localPosts = const {},
    this.localPostsStatus = DataStatus.initial,
    this.localPostsError,
  });

  UserState copyWith({
    List<User>? users,
    DataStatus? usersStatus,
    String? usersError,
    bool? hasReachedMax,
    List<Post>? posts,
    DataStatus? postsStatus,
    String? postsError,
    List<Todo>? todos,
    DataStatus? todosStatus,
    String? todosError,
    Map<int, List<Post>>? localPosts,
    DataStatus? localPostsStatus,
    String? localPostsError,
  }) {
    return UserState(
      users: users ?? this.users,
      usersStatus: usersStatus ?? this.usersStatus,
      usersError: usersError,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      posts: posts ?? this.posts,
      postsStatus: postsStatus ?? this.postsStatus,
      postsError: postsError,
      todos: todos ?? this.todos,
      todosStatus: todosStatus ?? this.todosStatus,
      todosError: todosError,
      localPosts: localPosts ?? this.localPosts,
      localPostsStatus: localPostsStatus ?? this.localPostsStatus,
      localPostsError: localPostsError,
    );
  }

  @override
  List<Object?> get props => [
    users,
    usersStatus,
    usersError,
    hasReachedMax,
    posts,
    postsStatus,
    postsError,
    todos,
    todosStatus,
    todosError,
    localPosts,
    localPostsStatus,
    localPostsError,
  ];
}
