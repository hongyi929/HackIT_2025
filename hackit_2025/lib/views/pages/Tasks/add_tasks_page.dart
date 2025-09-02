import 'package:flutter/material.dart';
import 'package:hackit_2025/data/constants.dart';
import 'package:hackit_2025/data/notifiers.dart';
import 'package:hackit_2025/views/widgets/date_input_widget.dart';
import 'package:hackit_2025/views/widgets/input_widget.dart';
import 'package:hackit_2025/views/widgets/task_dropdown_widget.dart';
import 'package:hive/hive.dart';

class AddTasksPage extends StatelessWidget {
  const AddTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final myBox = Hive.box("task_box");
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController dateController = TextEditingController();

    return Scaffold(
      backgroundColor: Color(0xFFF3FAFF),
      appBar: AppBar(
        backgroundColor: Color(0xFFF3FAFF),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Add Task", style: KTextStyle.header1Text),
            SizedBox(height: 20),
            Text("Title"),
            SizedBox(
              height: 60,
              child: Card.outlined(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Stack(
                        alignment: AlignmentGeometry.center,
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue,
                            ),
                          ),
                          Icon(Icons.color_lens, size: 30),
                        ],
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          style: KTextStyle.descriptionText,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            hintText: "Enter the title",
                            border: InputBorder.none,
                            isCollapsed: true,
                          ),
                          controller: titleController,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            InputWidget(
              title: "Description",
              controller: descriptionController,
            ),
            SizedBox(height: 20),
            DateInputWidget(
              title: "Enter due date",
              controller: dateController,
            ),
            
            TaskDropdownWidget(),

            FilledButton(
              onPressed: () {
                myBox.put(titleController.text, [
                  titleController.text,
                  descriptionController.text,
                ]);
                taskAmountNotifier.value++;
                Navigator.pop(context);
              },
              child: Text("Create Task"),
            ),
          ],
        ),
      ),
    );
  }
}
