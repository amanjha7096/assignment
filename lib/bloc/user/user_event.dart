import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchUsers extends UserEvent {
  final int skip;
  FetchUsers({this.skip = 0});
}

class SearchUsers extends UserEvent {
  final String query;
  SearchUsers(this.query);
}

class FetchUserDetails extends UserEvent {
  final int userId;
  FetchUserDetails(this.userId);
}

class CreatePost extends UserEvent {
  final int userId;
  final String title;
  final String body;
  final List<String> tags;

  CreatePost({required this.userId, required this.title, required this.body, this.tags = const []});

  @override
  List<Object> get props => [userId, title, body, tags];
}

class LoadLocalPosts extends UserEvent {}
