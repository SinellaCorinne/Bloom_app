import 'package:dio/dio.dart';
import '../models/tasks.dart';

class ApiService {
  static const String _baseUrl = 'https://bloom-app-kvza.onrender.com';

  final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));

  // GET /task
  Future<List<Task>> getTasks() async {

    final response = await _dio.get('/task');
    final List data = response.data as List;
    return data.map((json) => Task.fromJson(json)).toList();
  }

  // POST /task
  Future<Task> createTask(Task task) async {
    final response = await _dio.post('/task', data: task.toJson());
    return Task.fromJson(response.data);
  }

  // PATCH /task/:id
  Future<Task> updateTask(int id, Map<String, dynamic> data) async {
    final response = await _dio.patch('/task/$id', data: data);
    return Task.fromJson(response.data);
  }

  // DELETE /task/:id
  Future<void> deleteTask(int id) async {
    await _dio.delete('/task/$id');
  }

  // Dans api_service.dart

// Inscription
  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    try {
      final response = await _dio.post('/auth/local/register', data: {
        'username': username,
        'email': email,
        'password': password,
      });
      return response.data; // Contient le jwt et l'user
    } catch (e) {
      throw Exception("Erreur lors de l'inscription");
    }
  }

// Connexion
  Future<Map<String, dynamic>> login(String identifier, String password) async {
    try {
      final response = await _dio.post('/auth/local', data: {
        'identifier': identifier,
        'password': password,
      });
      return response.data; // Renvoie le token et les infos user
    } catch (e) {
      throw Exception("Identifiants incorrects");
    }
  }
}
