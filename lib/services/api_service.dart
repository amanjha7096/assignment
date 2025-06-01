import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/post.dart';
import '../models/todo.dart';

class ApiService {
  final String baseUrl = 'https://dummyjson.com';

  Future<List<User>> fetchUsers(int skip, int limit) async {
    final response = await http.get(Uri.parse('$baseUrl/users?limit=$limit&skip=$skip'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['users'] as List).map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch users');
    }
  }

  Future<List<User>> searchUsers(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/users/search?q=$query'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['users'] as List).map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search users');
    }
  }

  Future<List<Post>> fetchUserPosts(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/posts/user/$userId'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['posts'] as List).map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch posts');
    }
  }

  Future<List<Todo>> fetchUserTodos(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/todos/user/$userId'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['todos'] as List).map((json) => Todo.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch todos');
    }
  }
}
