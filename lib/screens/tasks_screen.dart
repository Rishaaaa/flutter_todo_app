import 'package:flutter/material.dart';
import 'package:flutter_todo_app/screens/completed_task_screen.dart';
import 'package:flutter_todo_app/screens/pending_task_screen.dart';
import '../blocs/bloc_exports.dart';
import 'add_task_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(FetchTasks());
  }

  final List<Map<String, dynamic>> _pageDetails = [
    {'pageName': const PendingTaskScreen(), 'title': 'Pending Tasks'},
    {'pageName': const CompletedTaskScreen(), 'title': 'Completed Tasks'},
  ];

  var _selectedPageIndex = 0;

  void _addTask(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: const AddTaskScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple.shade100,
        title: Text(_pageDetails[_selectedPageIndex]['title']),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => _addTask(context),
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                shadowColor: Colors.black.withOpacity(0.5),
                elevation: 6,
              ),
              child: const Icon(Icons.add),
            ),
          )
        ],
      ),
      body: Container(
        color: Colors.purple.shade50,
        child: _pageDetails[_selectedPageIndex]['pageName'],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.purple.shade100,
        fixedColor: Colors.purple.shade900,
        unselectedItemColor: Colors.black87,
        currentIndex: _selectedPageIndex,
        onTap: (index) {
          setState(() {
            _selectedPageIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.list), label: 'Pending Tasks'),
          BottomNavigationBarItem(
              icon: Icon(Icons.done), label: 'Completed Tasks'),
        ],
      ),
    );
  }
}
