import 'package:flutter/material.dart';
import 'package:hackit_2025/data/constants.dart';
import 'package:hackit_2025/views/widgets/task_widget.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final myBox = Hive.box("task_box");

  void writeData() {
    myBox.put(1, "Mitch");
  }

  void readData() {
    print(myBox.get(1));
  }

  void deleteData() {
    myBox.delete(1);
  }

  TextEditingController testController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Tasks", style: KTextStyle.header1Text),
            Row(
              spacing: 10,
              children: [
                FilledButton(onPressed: () {
                  
                }, child: Text("All")),
                FilledButton(onPressed: () {
                  
                }, child: Icon(Icons.star)),
                FilledButton(onPressed: () {
                  
                }, child: Text("Category 1"))
              ]
            ),
            SizedBox(height: 30),
            TaskWidget()
          ]
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: Icon(Icons.add, color: Colors.white),
        label: Text("Add task", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF217AFF),
      ),
    );
  }
}
