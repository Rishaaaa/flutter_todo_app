import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../services/task_api_service.dart';
import '../../widgets/scaffold_message.dart';

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
    try {
      final response = await TaskApiService.createTask(event.task);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final createdTaskJson = jsonResponse['todo'];

        final createdTask = Task(
          id: createdTaskJson['todo_id'],
          title: createdTaskJson['title'],
          description: createdTaskJson['description'],
          isCompleted: createdTaskJson['is_completed'],
          dueDate:
              DateTime.fromMillisecondsSinceEpoch(createdTaskJson['due_date']),
        );

        if (createdTask.isCompleted) {
          emit(TaskState(
            pendingTasks: state.pendingTasks,
            completedTasks: List.from(state.completedTasks)..add(createdTask),
          ));
        } else {
          emit(TaskState(
            pendingTasks: List.from(state.pendingTasks)..add(createdTask),
            completedTasks: state.completedTasks,
          ));
        }

        ScaffoldMessage.show(
            event.context, MessageType.success, 'Task created successfully!');
      } else {
        ScaffoldMessage.show(event.context, MessageType.error,
            'Error creating task: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding task: $e');
      // Show general error message
      ScaffoldMessage.show(
          event.context, MessageType.error, 'Failed to add task.');
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    final updatedTask = event.task;
    try {
      final response = await TaskApiService.updateTask(updatedTask);

      if (response.statusCode == 200) {
        final List<Task> updatedPendingTasks = state.pendingTasks
            .where((task) => task.id != updatedTask.id)
            .toList();
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
        ));

        ScaffoldMessage.show(
            event.context, MessageType.success, 'Task updated successfully!');
      } else {
        ScaffoldMessage.show(event.context, MessageType.error,
            'Error updating task: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating task: $e');
      ScaffoldMessage.show(
          event.context, MessageType.error, 'Failed to update task.');
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    final task = event.task;
    try {
      final response = await TaskApiService.deleteTask('${task.id}');
      if (response.statusCode == 200) {
        final List<Task> updatedPendingTasks =
            state.pendingTasks.where((t) => t.id != task.id).toList();
        final List<Task> updatedCompletedTasks =
            state.completedTasks.where((t) => t.id != task.id).toList();

        emit(TaskState(
          pendingTasks: updatedPendingTasks,
          completedTasks: updatedCompletedTasks,
        ));

        ScaffoldMessage.show(
            event.context, MessageType.success, 'Task deleted successfully!');
      } else {
        ScaffoldMessage.show(event.context, MessageType.error,
            'Error deleting task: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting task: $e');
      ScaffoldMessage.show(
          event.context, MessageType.error, 'Failed to delete task.');
    }
  }

  Future<void> _onFetchTasks(FetchTasks event, Emitter<TaskState> emit) async {
    try {
      final response = await TaskApiService.fetchTasks();

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> todosJson = jsonResponse['todos'];

        final List<Task> tasks = todosJson.map((json) {
          return Task(
            id: json['todo_id'],
            title: json['title'],
            description: json['description'],
            isCompleted: json['is_completed'],
            dueDate: DateTime.fromMillisecondsSinceEpoch(json['due_date']),
          );
        }).toList();

        final pendingTasks = tasks.where((task) => !task.isCompleted).toList();
        final completedTasks = tasks.where((task) => task.isCompleted).toList();

        emit(TaskState(
          pendingTasks: pendingTasks,
          completedTasks: completedTasks,
        ));
      } else {
        emit(TaskState.error('Failed to load tasks from API.'));
      }
    } catch (e) {
      print('Error fetching tasks: $e');
      emit(TaskState.error('Error fetching tasks.'));
    }
  }
}
