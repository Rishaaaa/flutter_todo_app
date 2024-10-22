part of 'task_bloc.dart';

class TaskState extends Equatable {
  final List<Task> pendingTasks;
  final List<Task> completedTasks;
  final String? errorMessage;
  const TaskState({
    this.pendingTasks = const [],
    this.completedTasks = const [],
    this.errorMessage,
  });

  const TaskState.error(this.errorMessage)
      : pendingTasks = const [],
        completedTasks = const [];

  @override
  List<Object> get props => [pendingTasks, completedTasks, errorMessage ?? ''];
}
