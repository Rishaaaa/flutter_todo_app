import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../blocs/bloc_exports.dart';
import '../models/task_model.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? task;

  const AddTaskScreen({super.key, this.task});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  DateTime? selectedDueDate;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.task?.title ?? '');
    descriptionController =
        TextEditingController(text: widget.task?.description ?? '');
    selectedDueDate = widget.task?.dueDate ?? DateTime.now();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            widget.task == null ? 'Add Task' : 'Update Task',
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 10),
          TextField(
            autofocus: true,
            controller: titleController,
            decoration: const InputDecoration(
              label: Text('Title'),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(
              label: Text('Description'),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedDueDate != null
                    ? 'Due Date: ${DateFormat.yMMMd().format(selectedDueDate!)}'
                    : 'Select Due Date',
              ),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDueDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );

                  if (pickedDate != null) {
                    setState(() {
                      selectedDueDate = pickedDate;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  var newTask = Task(
                    id: widget.task?.id ?? "",
                    title: titleController.text,
                    description: descriptionController.text.isNotEmpty
                        ? descriptionController.text
                        : null,
                    dueDate: selectedDueDate ?? DateTime.now(),
                    isCompleted: widget.task?.isCompleted ?? false,
                  );

                  if (widget.task == null) {
                    // For new tasks
                    context.read<TaskBloc>().add(AddTask(task: newTask, context: context));
                  } else {
                    // For updating existing tasks
                    context.read<TaskBloc>().add(UpdateTask(task: newTask, context:context));
                  }

                  Navigator.pop(context);
                },
                child: Text(widget.task == null ? 'Add' : 'Update'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
