import 'package:flutter/material.dart';
import 'package:hackit_2025/data/constants.dart';
import 'package:hackit_2025/views/pages/Tasks/add_tasks_page.dart';
import 'package:hackit_2025/views/widgets/task_widget.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final myBox = Hive.box("task_box");

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
                FilledButton(onPressed: () {}, child: Text("All")),
                FilledButton(onPressed: () {}, child: Icon(Icons.star)),
                FilledButton(onPressed: () {}, child: Text("Category 1")),
              ],
            ),
            SizedBox(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: myBox.length,
                itemBuilder: (context, index) {
                  if (myBox.length > 0) {
                    return Column(
                      children: [
                        TaskWidget(title: "Heya", description: "Sup dawg"),
                        SizedBox(height: 10),
                      ],
                    );
                  } else {
                    return Text("Looks like you need to create a task!");
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return AddTasksPage();
              },
            ),
          );
        },
        icon: Icon(Icons.add, color: Colors.white),
        label: Text("Add task", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF217AFF),
      ),
    );
  }
}
