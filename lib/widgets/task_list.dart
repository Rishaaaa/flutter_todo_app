import 'package:flutter/material.dart';

import '../models/task_model.dart';
import 'task_tile.dart';

class TasksList extends StatelessWidget {
  const TasksList({
    super.key,
    required this.tasksList,
  });

  final List<Task> tasksList;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasksList.length,
      itemBuilder: (context, index) {
        var task = tasksList[index];
        return TaskTile(task: task);
      },
    );
  }
}
