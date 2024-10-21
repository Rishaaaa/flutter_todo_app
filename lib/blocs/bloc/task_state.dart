part of 'task_bloc.dart';

class TaskState extends Equatable {
  final List<Task> pendingTasks;
  final List<Task> completedTasks;
  final int deletedTasksCount;

  const TaskState({
    this.pendingTasks = const [],
    this.completedTasks = const [],
    this.deletedTasksCount = 0,
  });

  @override
  List<Object> get props => [pendingTasks, completedTasks, deletedTasksCount];
}
