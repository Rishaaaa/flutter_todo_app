import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/task_model.dart';

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  TaskBloc() : super(const TaskState()) {
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<FetchTasks>(_onFetchTasks);
  }

  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    final task = event.task;
    final newTask = task.copyWith(
      id: task.id == 0 ? DateTime.now().millisecondsSinceEpoch : task.id,
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      List<String>? storedTasks = prefs.getStringList('tasks') ?? [];

      // Convert task to JSON and add to the list
      storedTasks.add(jsonEncode({
        'id': newTask.id,
        'title': newTask.title,
        'description': newTask.description,
        'isCompleted': newTask.isCompleted,
        'isDeleted': newTask.isDeleted,
        'dueDate': newTask.dueDate.toIso8601String(),
      }));

      await prefs.setStringList('tasks', storedTasks);

      // Update task lists based on completion status
      if (newTask.isCompleted) {
        emit(TaskState(
          pendingTasks: state.pendingTasks,
          completedTasks: List.from(state.completedTasks)..add(newTask),
          deletedTasksCount: state.deletedTasksCount,
        ));
      } else {
        emit(TaskState(
          pendingTasks: List.from(state.pendingTasks)..add(newTask),
          completedTasks: state.completedTasks,
          deletedTasksCount: state.deletedTasksCount,
        ));
      }
    } catch (e) {
      print('Error adding task: $e');
    }
  }

  void _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    final updatedTask = event.task;

    final List<Task> updatedPendingTasks =
        state.pendingTasks.where((task) => task.id != updatedTask.id).toList();
    final List<Task> updatedCompletedTasks = state.completedTasks
        .where((task) => task.id != updatedTask.id)
        .toList();

    if (updatedTask.isCompleted) {
      updatedCompletedTasks.add(updatedTask);
    } else {
      updatedPendingTasks.add(updatedTask);
    }

    emit(TaskState(
      pendingTasks: updatedPendingTasks,
      completedTasks: updatedCompletedTasks,
      deletedTasksCount: state.deletedTasksCount,
    ));

    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> tasksToStore =
          [...updatedPendingTasks, ...updatedCompletedTasks].map((task) {
        return jsonEncode({
          'id': task.id,
          'title': task.title,
          'description': task.description,
          'isCompleted': task.isCompleted,
          'isDeleted': task.isDeleted,
          'dueDate': task.dueDate.toIso8601String(),
        });
      }).toList();
      await prefs.setStringList('tasks', tasksToStore);
    } catch (e) {
      print('Error saving updated tasks to local storage: $e');
    }
  }

  void _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    try {
      final task = event.task;

      final updatedTask = task.copyWith(isDeleted: true);

      final List<Task> updatedPendingTasks =
          state.pendingTasks.where((t) => t.id != updatedTask.id).toList();
      final List<Task> updatedCompletedTasks =
          state.completedTasks.where((t) => t.id != updatedTask.id).toList();
      final deletedCount = state.deletedTasksCount + 1;

      emit(TaskState(
        pendingTasks: updatedPendingTasks,
        completedTasks: updatedCompletedTasks,
        deletedTasksCount: deletedCount,
      ));

      final prefs = await SharedPreferences.getInstance();
      List<String> tasksToStore =
          [...updatedPendingTasks, ...updatedCompletedTasks].map((task) {
        return jsonEncode({
          'id': task.id,
          'title': task.title,
          'description': task.description,
          'isCompleted': task.isCompleted,
          'isDeleted': task.isDeleted,
          'dueDate': task.dueDate.toIso8601String(),
        });
      }).toList();
      await prefs.setStringList('tasks', tasksToStore);
    } catch (e) {
      print('Error deleting task: $e');
    }
  }

  void _onFetchTasks(FetchTasks event, Emitter<TaskState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      List<String>? storedTasks = prefs.getStringList('tasks');

      if (storedTasks != null && storedTasks.isNotEmpty) {
        final List<Task> tasks = storedTasks.map((jsonString) {
          final json = jsonDecode(jsonString);
          return Task(
            id: json['id'],
            title: json['title'],
            description: json['description'],
            isCompleted: json['isCompleted'],
            isDeleted: json['isDeleted'],
            dueDate: DateTime.parse(json['dueDate']),
          );
        }).toList();

        final pendingTasks = tasks
            .where((task) => !task.isCompleted && !task.isDeleted)
            .toList();
        final completedTasks =
            tasks.where((task) => task.isCompleted && !task.isDeleted).toList();
        final deletedCount = tasks.where((task) => task.isDeleted).length;

        emit(TaskState(
          pendingTasks: pendingTasks,
          completedTasks: completedTasks,
          deletedTasksCount: deletedCount,
        ));
      } else {
        final response =
            await http.get(Uri.parse('https://dummyjson.com/todos'));

        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          final List<dynamic> todosJson = jsonResponse['todos'];

          final List<Task> tasks = todosJson.map((json) {
            return Task(
              id: json['id'],
              title: json['todo'],
              description: null,
              isCompleted: json['completed'],
              isDeleted: false,
              dueDate: DateTime.now(),
            );
          }).toList();

          List<String> tasksToStore = tasks.map((task) {
            return jsonEncode({
              'id': task.id,
              'title': task.title,
              'description': task.description,
              'isCompleted': task.isCompleted,
              'isDeleted': task.isDeleted,
              'dueDate': task.dueDate.toIso8601String(),
            });
          }).toList();
          await prefs.setStringList('tasks', tasksToStore);

          final pendingTasks =
              tasks.where((task) => !task.isCompleted).toList();
          final completedTasks =
              tasks.where((task) => task.isCompleted).toList();
          emit(TaskState(
              pendingTasks: pendingTasks,
              completedTasks: completedTasks,
              deletedTasksCount: 0));
        } else {
          throw Exception('Failed to load tasks from API');
        }
      }
    } catch (e) {
      print('Error fetching tasks: $e');
    }
  }
}
