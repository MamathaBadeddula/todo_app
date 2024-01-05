import 'package:flutter/material.dart';
import 'package:todo_app/utili/dialog_box.dart';
import 'package:todo_app/utili/todo_list.dart';
import 'package:todo_app/goog_sh.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
// text controller
  final _controller = TextEditingController();
  final _googleSheetsHelper = GoogleSheetsHelper();

  //list of todotasks
  List todotask = [
    ['Read', false],
    ['Exercise', false],
  ];

  void checkBoxChanged(bool? value, int index) {
    setState(() {
      todotask[index][1] = !todotask[index][1];
    });
  }

  //save new task
  void saveNewTask() async {
    await _googleSheetsHelper.addTask(_controller.text);
    setState(() {
      todotask.add([_controller.text, false]);
      _controller.clear();
    });
    Navigator.of(context).pop();
  }

  // create a new task

  void createNewTask() {
    showDialog(
        context: context,
        builder: (context) {
          return DialogBox(
            controller: _controller,
            onSave: saveNewTask,
            onCancel: () => Navigator.of(context).pop,
          );
        });
  }

  // delete task
  void deleteTask(int index) async {
    await _googleSheetsHelper.deleteTask(index);

    setState(() {
      todotask.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[200],
      appBar: AppBar(
        backgroundColor: Colors.blue[300],
        title: Center(child: Text('TO DO')),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewTask,
        child: Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: todotask.length,
        itemBuilder: (context, index) {
          return Todolist(
            taskName: todotask[index][0],
            taskCompleted: todotask[index][1],
            onChanged: (value) => checkBoxChanged(value, index),
            deleteFunction: (context) => deleteTask(index),
          );
        },
      ),
    );
  }
}
