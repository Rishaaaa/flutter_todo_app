import 'package:flutter/material.dart';

import '../blocs/bloc_exports.dart';
import '../models/task_model.dart';
import '../widgets/scaffold_message.dart';
import '../widgets/task_list.dart';

class PendingTaskScreen extends StatelessWidget {
  const PendingTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessage.show(context, MessageType.error, state.errorMessage!);
        }
        List<Task> tasksList =
            state.pendingTasks.where((task) => !task.isCompleted).toList();

        tasksList.sort((a, b) {
          return a.dueDate.compareTo(b.dueDate);
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Chip(
                  backgroundColor: const Color.fromARGB(255, 234, 214, 238),
                  label: Text(
                    '${(state.pendingTasks.length)} Tasks',
                  ),
                ),
              ),
            ),
            if (tasksList.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'No pending tasks available.',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              )
            else
              Expanded(
                child: TasksList(tasksList: tasksList),
              ),
          ],
        );
      },
    );
  }
}
