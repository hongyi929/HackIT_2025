import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hackit_2025/data/constants.dart';
import 'package:hackit_2025/views/pages/Tasks/task_edit_page.dart';
import 'package:hackit_2025/views/widgets/date_input_widget.dart';
import 'package:hackit_2025/views/widgets/input_widget.dart';
import 'package:hackit_2025/views/widgets/task_edit_widget.dart';
import 'package:intl/intl.dart';
// Need to change this to a stream listener, so after edit it updates!
// Or faster would be to pushReplace in display, and pushReplace back after add
// To reduce codetime.
class TaskDisplayPage extends StatefulWidget {
  const TaskDisplayPage({
    super.key,
    required this.title,
    required this.description,
    required this.date,
    required this.categoryName,
    required this.categoryColor,
    required this.docid,
  });

  final String title;
  final String description;
  final Timestamp date;
  final String categoryName;
  final int categoryColor;
  final String docid;

  @override
  State<TaskDisplayPage> createState() => _TaskDisplayPageState();
}

TextEditingController titleController = TextEditingController();
TextEditingController descriptionController = TextEditingController();
TextEditingController dateController = TextEditingController();
TextEditingController categoryNameController = TextEditingController();

class _TaskDisplayPageState extends State<TaskDisplayPage> {
  Future<void> updateTask(titleController, descriptionController, date) async {
    final data = FirebaseFirestore.instance
        .collection("tasks")
        .doc(widget.docid);
    await data.update({
      "title": titleController,
      "description": descriptionController,
      "date": date,
    });
  }

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Timestamp newDate = widget.date;
    titleController.text = widget.title;
    descriptionController.text = widget.description;
    dateController.text = DateFormat("MMM d yyyy").format(widget.date.toDate());
    categoryNameController.text = widget.categoryName;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors
            .white, // Change to set color. Was done to debug scroll color.
        leading: null,
        title: Text("Task Editor"),
        scrolledUnderElevation: 0.0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return TaskEditPage(
                      title: widget.title,
                      description: widget.description,
                      date: widget.date,
                      categoryName: widget.categoryName,
                      categoryColor: widget.categoryColor,
                      docid: widget.docid,
                    );
                  },
                ),
              );
            },
            icon: Icon(Icons.edit),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 100),
        child: Center(
          child: SingleChildScrollView(
            child: SizedBox(
              child: Container(
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(widget.categoryColor), Colors.white],
                    stops: [0.065, 0.065],
                  ),
                ),

                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      SizedBox(height: 50),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: TaskEditWidget(
                          title: "Title",
                          controller: titleController,
                          style: KTextStyle.header1Text,
                          initialValue: widget.title,
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 40.0,
                        ),
                        child: TaskEditWidget(
                          title: "description",
                          controller: descriptionController,
                          style: KTextStyle.header1Text,
                          initialValue: widget.description,
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 40,
                        ),
                        child: DateInputWidget(
                          title: "Due date",
                          controller: dateController,
                          onChanged: (value) {
                            newDate = value;
                          },
                        ),
                      ),

                      Text(widget.categoryName),

                      SizedBox(),
                      FilledButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            await updateTask(
                              titleController.text,
                              descriptionController.text,
                              newDate,
                            );
                            Navigator.pop(context);
                            print("hi");
                          }
                          ;
                        },
                        child: Text("Save"),
                      ),
                      SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
