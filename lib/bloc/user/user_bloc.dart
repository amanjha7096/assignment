import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/post.dart';
import '../../repositories/user_repository.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository;
  int _localPostId = 1000; // Start with a high ID to avoid conflicts with API IDs

  UserBloc({required this.userRepository}) : super(const UserState()) {
    on<FetchUsers>(_onFetchUsers);
    on<SearchUsers>(_onSearchUsers);
    on<FetchUserDetails>(_onFetchUserDetails);
    on<CreatePost>(_onCreatePost);
    on<LoadLocalPosts>(_onLoadLocalPosts);
  }

  Future<void> _onFetchUsers(FetchUsers event, Emitter<UserState> emit) async {
    if (state.hasReachedMax) return;
    try {
      emit(state.copyWith(usersStatus: DataStatus.loading, usersError: null));
      final users = await userRepository.fetchUsers(event.skip, 10);
      emit(
        state.copyWith(
          usersStatus: DataStatus.loaded,
          users: event.skip == 0 ? users : [...state.users, ...users],
          hasReachedMax: users.isEmpty,
        ),
      );
    } catch (e) {
      emit(state.copyWith(usersStatus: DataStatus.error, usersError: e.toString()));
    }
  }

  Future<void> _onSearchUsers(SearchUsers event, Emitter<UserState> emit) async {
    if (event.query.isEmpty) {
      emit(state.copyWith(usersStatus: DataStatus.loaded, usersError: null));
      return;
    }
    try {
      emit(state.copyWith(usersStatus: DataStatus.loading, usersError: null));
      final users = await userRepository.searchUsers(event.query);
      emit(state.copyWith(usersStatus: DataStatus.loaded, users: users));
    } catch (e) {
      emit(state.copyWith(usersStatus: DataStatus.error, usersError: e.toString()));
    }
  }

  Future<void> _onFetchUserDetails(FetchUserDetails event, Emitter<UserState> emit) async {
    try {
      emit(
        state.copyWith(
          postsStatus: DataStatus.loading,
          todosStatus: DataStatus.loading,
          postsError: null,
          todosError: null,
        ),
      );
      final posts = await userRepository.fetchUserPosts(event.userId);
      print('☑️☑️☑️☑️posts:$posts');
      final todos = await userRepository.fetchUserTodos(event.userId);
      emit(state.copyWith(postsStatus: DataStatus.loaded, todosStatus: DataStatus.loaded, posts: posts, todos: todos));
    } catch (e) {
      emit(
        state.copyWith(
          postsStatus: DataStatus.error,
          todosStatus: DataStatus.error,
          postsError: e.toString(),
          todosError: e.toString(),
        ),
      );
    }
  }

  void _onCreatePost(CreatePost event, Emitter<UserState> emit) async {
    try {
      emit(state.copyWith(localPostsStatus: DataStatus.loading, localPostsError: null));

      final newPost = Post(
        id: _localPostId++,
        title: event.title,
        body: event.body,
        tags: event.tags,
        reactions: Reactions(likes: 0, dislikes: 0),
        views: 0,
        userId: event.userId,
      );

      final updatedLocalPosts = Map<int, List<Post>>.from(state.localPosts);
      updatedLocalPosts[event.userId] = [newPost, ...(updatedLocalPosts[event.userId] ?? [])];

      // Save to shared preferences
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(
        updatedLocalPosts.map((key, value) => MapEntry(key.toString(), value.map((e) => e.toJson()).toList())),
      );
      await prefs.setString('local_posts', jsonString);

      emit(state.copyWith(localPostsStatus: DataStatus.loaded, localPosts: updatedLocalPosts));
    } catch (e) {
      emit(state.copyWith(localPostsStatus: DataStatus.error, localPostsError: e.toString()));
    }
  }

  void _onLoadLocalPosts(LoadLocalPosts event, Emitter<UserState> emit) async {
    try {
      emit(state.copyWith(localPostsStatus: DataStatus.loading, localPostsError: null));

      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('local_posts');

      if (jsonString != null) {
        final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
        final Map<int, List<Post>> restored = decoded.map((key, value) {
          return MapEntry(int.parse(key), List<Post>.from(value.map((e) => Post.fromJson(e))));
        });

        emit(state.copyWith(localPostsStatus: DataStatus.loaded, localPosts: restored));
      } else {
        emit(state.copyWith(localPostsStatus: DataStatus.loaded));
      }
    } catch (e) {
      emit(state.copyWith(localPostsStatus: DataStatus.error, localPostsError: e.toString()));
    }
  }
}
