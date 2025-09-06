import 'package:flutter/material.dart';
import 'package:hackit_2025/data/constants.dart';
import 'package:hackit_2025/data/notifiers.dart';
import 'package:hackit_2025/services/firestore.dart';
import 'package:hackit_2025/views/widgets/date_input_widget.dart';
import 'package:hackit_2025/views/widgets/input_widget.dart';
import 'package:hackit_2025/views/widgets/task_dropdown_widget.dart';
import 'package:hive/hive.dart';

// TextFormField has to be redesigned to have card design and to remove paint icon
// This is so that input validation looks neat and box highlight during selection is easy

class AddTasksPage extends StatelessWidget {
  const AddTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final myBox = Hive.box("task_box");
    final categoryBox = Hive.box("category_box");
    final FirestoreTaskService firestoreService = FirestoreTaskService();

    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController dateController = TextEditingController();
    final taskKey = GlobalKey<FormState>();
    String? selectedCategory;
    print(myBox.values.toList());

    return Scaffold(
      backgroundColor: Color(0xFFF3FAFF),
      appBar: AppBar(backgroundColor: Color(0xFFF3FAFF)),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: taskKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Add Task", style: KTextStyle.header1Text),
              SizedBox(height: 20),
              InputWidget(title: "Task", controller: titleController),
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
              // For dropdown widget, Data will be passed through by selecting category, which will be used as a key to
              // Acces category color and category name.
              ValueListenableBuilder(
                valueListenable: categoryAmountNotifier,
                builder: (context, categoryAmount, child) {
                  return TaskDropdownWidget(
                    onChanged: (value) {
                      selectedCategory = value;
                    },
                  );
                },
              ),
              FilledButton(
                onPressed: () {
                  if (taskKey.currentState!.validate()) {
                    firestoreService.addTask(
                      titleController.text,
                      descriptionController.text,
                      dateController.text,
                      selectedCategory!,
                    );
                    taskAmountNotifier.value = myBox.length;
                    Navigator.pop(context);
                  }
                },
                child: Text("Create Task"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
