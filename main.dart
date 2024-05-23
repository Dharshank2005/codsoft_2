import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Task {
  final String title;
  bool completed; // Add other properties as needed

  Task({required this.title, this.completed = false});
}

class TaskItem extends StatelessWidget {
  final Task task;
  final Function(Task) onDelete;
  final Function(Task) onEdit;

  const TaskItem({
    required this.task,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: task.completed,
        onChanged: (newValue) => Provider.of<Tasks>(context, listen: false)
            .toggleTaskCompletion(task),
      ),
      title: Text(
        task.title,
        style: TextStyle(
          decoration:
              task.completed ? TextDecoration.lineThrough : TextDecoration.none,
          fontSize: 16.0,
          fontWeight: FontWeight.normal,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => onEdit(task),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => onDelete(task),
          ),
        ],
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Tasks>(
      create: (context) => Tasks(),
      child: MaterialApp(
        theme: ThemeData(
          primaryColor: Colors.blue,
          colorScheme: const ColorScheme.light(
            primary: Colors.blue,
            secondary: Colors.green,
          ),
        ),
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Task Manager',
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.blue,
          ),
          body: TaskList(),
          floatingActionButton: Builder(
            builder: (BuildContext builderContext) {
              return FloatingActionButton(
                onPressed: () => Navigator.push(
                  builderContext,
                  MaterialPageRoute(
                    builder: (context) => AddTaskScreen(
                      addTaskToList:
                          Provider.of<Tasks>(context, listen: false).addTask,
                    ),
                  ),
                ),
                child: const Icon(Icons.add),
                backgroundColor: Colors.green,
              );
            },
          ),
        ),
      ),
    );
  }
}

class AddTaskScreen extends StatefulWidget {
  final Function(String) addTaskToList;

  const AddTaskScreen({required this.addTaskToList});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final titleController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  void addTask() {
    if (titleController.text.isEmpty) return;
    widget.addTaskToList(titleController.text);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Task Title',
              ),
            ),
            ElevatedButton(
              onPressed: addTask,
              child: const Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tasks = Provider.of<Tasks>(context); // Access Tasks provider

    return ListView.builder(
      itemCount: tasks.tasks.length,
      itemBuilder: (context, index) {
        final task = tasks.tasks[index];
        return TaskItem(
          task: task,
          onDelete: tasks.deleteTask,
          onEdit: (task) =>
              tasks.editTask(context, task), // Pass context to editTask
        );
      },
    );
  }
}

class Tasks extends ChangeNotifier {
  List<Task> tasks = []; // Assuming you have an initialized tasks list

  void addTask(String title) {
    if (title.isEmpty) {
      return;
    }
    tasks.add(Task(title: title));
    notifyListeners(); // Notify listeners about the change
  }

  void deleteTask(Task task) {
    tasks.remove(task);
    notifyListeners(); // Notify listeners about the change
  }

  void editTask(BuildContext context, Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTaskScreen(task: task),
      ),
    ).then((updatedTask) {
      if (updatedTask != null) {
        updateTask(task, updatedTask);
      }
    });
  }

  void updateTask(Task oldTask, Task newTask) {
    final index = tasks.indexOf(oldTask);
    if (index != -1) {
      tasks[index] = newTask;
      notifyListeners();
    }
  }

  void toggleTaskCompletion(Task task) {
    final index = tasks.indexOf(task);
    if (index != -1) {
      tasks[index].completed = !tasks[index].completed;
      notifyListeners(); // Notify listeners about the change
    }
  }
}

class EditTaskScreen extends StatefulWidget {
  final Task task;

  const EditTaskScreen({required this.task});

  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    titleController.text = widget.task.title; // Set initial text
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  void saveTask() {
    if (titleController.text.isEmpty) return;
    Navigator.pop(
      context,
      Task(
        title: titleController.text,
        completed: widget.task.completed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Task Title',
              ),
            ),
            ElevatedButton(
              onPressed: saveTask,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}
