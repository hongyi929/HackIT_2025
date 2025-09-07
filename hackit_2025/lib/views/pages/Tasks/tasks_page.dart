import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hackit_2025/data/constants.dart';
import 'package:hackit_2025/data/notifiers.dart';
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
  final categoryBox = Hive.box("category_box");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Tasks", style: KTextStyle.titleText),
            SizedBox(height: 10.0),
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
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("tasks")
                    .where(
                      "user",
                      isEqualTo: FirebaseAuth.instance.currentUser?.uid,
                    )
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData) {    
                    return const Center(
                      child: Text("You have no active tasks"),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> taskMap = snapshot
                            .data!
                            .docs[index]
                            .data();
                        return Column(
                          children: [
                            // range error when title name is the same (solved)
                            // When 2 items have same categoryname, a type null is not a subtype of type string error occurs
                            TaskWidget(
                              title: taskMap['title'],
                              description: taskMap['description'],
                              date: taskMap['date'],
                              categoryName: taskMap['category'],
                              categoryColor: Colors.blue.toARGB32(),
                            ),
                            SizedBox(height: 10),
                          ],
                        );
                      },
                    );
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
