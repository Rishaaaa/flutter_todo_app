import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task_model.dart';
import 'auth_service.dart';

class TaskApiService {
  static const String baseUrl = 'https://devdc.opensort.io/family-tree/todos';
  static const Map<String, String> headers = {
    'community': 'famtree',
    'Content-Type': 'application/json',
  };

  static Future<http.Response> fetchTasks() async {
    final token = await AuthService.getAccessToken();
    return await http.get(
      Uri.parse(baseUrl),
      headers: {
        ...headers,
        'x-access-token': token,
      },
    );
  }

  static Future<http.Response> createTask(Task task) async {
    final token = await AuthService.getAccessToken();
    return await http.post(
      Uri.parse('$baseUrl/create'),
      headers: {
        ...headers,
        'x-access-token': token,
      },
      body: jsonEncode({
        'title': task.title,
        'description': task.description ?? '',
        'due_date': task.dueDate.millisecondsSinceEpoch,
        'is_completed': task.isCompleted,
      }),
    );
  }

  static Future<http.Response> updateTask(Task task) async {
    final token = await AuthService.getAccessToken();
    return await http.post(
      Uri.parse('$baseUrl/update/${task.id}'),
      headers: {
        ...headers,
        'x-access-token': token,
      },
      body: jsonEncode({
        'todo_id': task.id,
        'update': {
          'title': task.title,
          'description': task.description ?? '',
          'due_date': task.dueDate.millisecondsSinceEpoch,
          'is_completed': task.isCompleted,
        },
      }),
    );
  }

  static Future<http.Response> deleteTask(String taskId) async {
    final token = await AuthService.getAccessToken();
    return await http.get(
      Uri.parse('$baseUrl/delete/$taskId'),
      headers: {
        ...headers,
        'x-access-token': token,
      },
    );
  }
}
