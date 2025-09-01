import 'package:flutter/material.dart';
import 'package:hackit_2025/data/constants.dart';

class AddTasksPage extends StatelessWidget {
  const AddTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text("Add Task", style: KTextStyle.header1Text),
          SizedBox(height: 20),
          Text("Title"),
        ]),
      ),
    );
  }
}
