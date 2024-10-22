part of 'task_bloc.dart';

sealed class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class FetchTasks extends TaskEvent {}

class AddTask extends TaskEvent {
  final Task task;
  final BuildContext context;
  const AddTask({required this.task, required this.context});

  @override
  List<Object> get props => [task, context];
}

class UpdateTask extends TaskEvent {
  final Task task;
  final BuildContext context;
  const UpdateTask({required this.task, required this.context});

  @override
  List<Object> get props => [task, context];
}

class DeleteTask extends TaskEvent {
  final Task task;
  final BuildContext context;
  const DeleteTask({
    required this.task, required this.context
  });

  @override
  List<Object> get props => [task, context];
}
