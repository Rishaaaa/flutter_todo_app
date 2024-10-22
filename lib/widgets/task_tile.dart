import 'package:flutter/material.dart';
import '../blocs/bloc_exports.dart';
import '../models/task_model.dart';
import '../screens/add_task_screen.dart';

class TaskTile extends StatelessWidget {
  final Task task;

  const TaskTile({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 232, 207, 236),
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: ExpansionTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.0),
          side: BorderSide.none,
        ),
        title: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: task.isCompleted,
                  onChanged: (value) {
                    final updatedTask = task.copyWith(isCompleted: value!);
                    context.read<TaskBloc>().add(UpdateTask(task: updatedTask, context: context));
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      task.isCompleted
                          ? const SizedBox()
                          : Text(
                              'Due Date: ${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDueToday(task.dueDate)
                                    ? Colors.red
                                    : Colors.green,
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(
          task.isCompleted ? Icons.expand_less : Icons.expand_more,
        ),
        children: [
          Container(
            color: const Color.fromARGB(255, 242, 227, 240),
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (task.description != null && task.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      task.description!,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey[600],
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                task.isCompleted
                    ? Text(
                        'Due Date: ${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[800],
                        ),
                      )
                    : const SizedBox(),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => SingleChildScrollView(
                            child: Container(
                              padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom,
                              ),
                              child: AddTaskScreen(task: task),
                            ),
                          ),
                        );
                      },
                      child: const Text('Edit'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Warning'),
                              content: const Text(
                                  'Are you sure you want to delete this task? This action cannot be undone.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    context
                                        .read<TaskBloc>()
                                        .add(DeleteTask(task: task, context: context));
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Delete',
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

bool isDueToday(DateTime dueDate) {
  DateTime today = DateTime.now();
  return dueDate.year == today.year &&
      dueDate.month == today.month &&
      dueDate.day == today.day;
}
