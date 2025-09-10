import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hackit_2025/data/constants.dart';
import 'package:hackit_2025/data/notifiers.dart';
import 'package:hackit_2025/services/firestore.dart';
import 'package:hackit_2025/views/pages/Tasks/task_display_page.dart';
import 'package:hackit_2025/views/widgets/date_input_widget.dart';
import 'package:hackit_2025/views/widgets/input_widget.dart';
import 'package:hackit_2025/views/widgets/task_dropdown_widget.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

// TextFormField has to be redesigned to have card design and to remove paint icon
// This is so that input validation looks neat and box highlight during selection is easy

class TaskEditPage extends StatefulWidget {
  const TaskEditPage({
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
  State<TaskEditPage> createState() => _TaskEditPageState();
}

class _TaskEditPageState extends State<TaskEditPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  String uid = FirebaseAuth.instance.currentUser!.uid;


  Future<void> updateTask(
    titleController,
    descriptionController,
    date,
    selectedCategory,
  ) async {
    final data = FirebaseFirestore.instance
        .collection("tasks")
        .doc(widget.docid);
    await data.update({
      "title": titleController,
      "description": descriptionController,
      "date": date,
      "category": uid + selectedCategory,
    });
  }

Future<Map<String, dynamic>> initCategoryCollection(selectedCategory) async{
  final categoryDoc = await FirebaseFirestore.instance.collection("category").doc(uid + selectedCategory).get();
  return categoryDoc.data()!;
}

  @override
  Widget build(BuildContext context) {
    
    Timestamp newDate = widget.date;

    titleController.text = widget.title;
    descriptionController.text = widget.description;
    dateController.text = DateFormat("MMM d yyyy").format(widget.date.toDate());
    dropdownValue = widget.categoryName;
    final taskKey = GlobalKey<FormState>();
    String? selectedCategory = widget.categoryName;
    

    return Scaffold(
      backgroundColor: Color(0xFFF3FAFF),
      appBar: AppBar(
        backgroundColor: Color(0xFFF3FAFF),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return TaskDisplayPage(
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
        ),
      ),
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
                onChanged: (value) {
                  newDate = value;
                },
              ),

              // For dropdown widget, Data will be passed through by selecting category, which will be used as a key to
              // Acces category color and category name.
              TaskDropdownWidget(
                onChanged: (value) {
                  selectedCategory = value;
                },
              ),

              FilledButton(
                onPressed: () async {
                  if (taskKey.currentState!.validate()) {
                    print("hi");
                    await updateTask(
                      titleController.text,
                      descriptionController.text,
                      newDate,
                      selectedCategory,
                    );
                    final categoryDoc = await initCategoryCollection(selectedCategory);
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                      return TaskDisplayPage(title: titleController.text, description: descriptionController.text, date: newDate, categoryName: selectedCategory!, categoryColor: categoryDoc['categoryColor'], docid: widget.docid);
                    },));
                  }
                },
                child: Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
