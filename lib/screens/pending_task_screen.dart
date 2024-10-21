import 'package:flutter/material.dart';

import '../blocs/bloc_exports.dart';
import '../models/task_model.dart';
import '../widgets/task_list.dart';

class PendingTaskScreen extends StatelessWidget {
  const PendingTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        List<Task> tasksList =
            state.pendingTasks.where((task) => !task.isDeleted).toList();

        tasksList.sort((a, b) {
          return a.dueDate.compareTo(b.dueDate);
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TasksList(tasksList: tasksList),
            ),
          ],
        );
      },
    );
  }
}
