import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/taskModel.dart';



class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _searchController.addListener(() {
      _filterTasks();
    });
  }

  _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tasksString = prefs.getString('tasks');
    if (tasksString != null) {
      setState(() {
        _tasks = Task.decode(tasksString);
        _filteredTasks = _tasks;
      });
    }
  }

  _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('tasks', Task.encode(_tasks));
  }

  _addTask(String title, String time) async {
    setState(() {
      _tasks.add(Task(title, time));
      _filteredTasks = _tasks;
    });
    _saveTasks();
  }

  _removeTask(int index) async {
    setState(() {
      _tasks.removeAt(index);
      _filteredTasks = _tasks;
    });
    _saveTasks();
  }

  _toggleTaskCompletion(int index) async {
    setState(() {
      _tasks[index].title = _tasks[index].title.startsWith('[Done] ')
          ? _tasks[index].title.substring(7)
          : '[Done] ' + _tasks[index].title;
      _filteredTasks = _tasks;
    });
    _saveTasks();
  }

  _showAddTaskDialog() {
    TextEditingController taskController = TextEditingController();
    TimeOfDay? selectedTime;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add Task'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: taskController,
                    decoration: InputDecoration(hintText: 'Enter task'),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        selectedTime == null
                            ? 'Select Time'
                            : selectedTime!.format(context),
                        style: TextStyle(fontSize: 16),
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.access_time),
                        onPressed: () async {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (pickedTime != null) {
                            setState(() {
                              selectedTime = pickedTime;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Add'),
                  onPressed: () {
                    if (taskController.text.isNotEmpty &&
                        selectedTime != null) {
                      _addTask(
                        taskController.text,
                        selectedTime!.format(context),
                      );
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }


  _filterTasks() {
    setState(() {
      _filteredTasks = _tasks
          .where((task) => task.title
          .toLowerCase()
          .contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('To-Do List'),
            Spacer(),
            CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('images/image.jpg'),
            ),
          ],
        ),
        backgroundColor: Colors.blueGrey,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredTasks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    _filteredTasks[index].title,
                    style: TextStyle(
                      decoration: _filteredTasks[index]
                          .title
                          .startsWith('[Done] ')
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  subtitle: Text(_filteredTasks[index].time),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _removeTask(index),
                  ),
                  onTap: () => _toggleTaskCompletion(index),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
