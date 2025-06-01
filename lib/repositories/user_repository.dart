import '../models/user.dart';
import '../models/post.dart';
import '../models/todo.dart';
import '../services/api_service.dart';

class UserRepository {
  final ApiService apiService = ApiService();

  Future<List<User>> fetchUsers(int skip, int limit) async {
    return await apiService.fetchUsers(skip, limit);
  }

  Future<List<User>> searchUsers(String query) async {
    return await apiService.searchUsers(query);
  }

  Future<List<Post>> fetchUserPosts(int userId) async {
    return await apiService.fetchUserPosts(userId);
  }

  Future<List<Todo>> fetchUserTodos(int userId) async {
    return await apiService.fetchUserTodos(userId);
  }
}
