import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

class AddTasksPage extends StatefulWidget {
  const AddTasksPage({super.key});

  @override
  State<AddTasksPage> createState() => _AddTasksPageState();
}

class _AddTasksPageState extends State<AddTasksPage> {
  Future<void> uploadTaskToDb(
    titleController,
    descriptionController,
    dateTimestamp,
    categoryName,
  ) async {
    try {
      final docRef = FirebaseFirestore.instance.collection("tasks").doc();
      await docRef.set({
        "title": titleController.text.trim(),
        "description": descriptionController.text.trim(),
        "date": dateTimestamp,
        "category":
            (FirebaseAuth.instance.currentUser!.uid + categoryName.toString()),
        "user": FirebaseAuth.instance.currentUser!.uid,
        "completed": false,
        "docid": docRef.id,
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final FirestoreTaskService firestoreService = FirestoreTaskService();

    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController dateController = TextEditingController();
    final taskKey = GlobalKey<FormState>();
    String? selectedCategory;
    Timestamp? dateTimestamp;

    return Scaffold(
      backgroundColor: Color(0xFFF3FAFF),
      appBar: AppBar(
        backgroundColor: Color(0xFFF3FAFF),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
            setState(() {
              dropdownValue = null;
            });
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
              Text("Add Task", style: KTextStyle.titleText),
              SizedBox(height: 24),
              InputWidget(title: "Task", controller: titleController),
              SizedBox(height: 24),
              InputWidget(
                title: "Description",
                controller: descriptionController,
              ),
              SizedBox(height: 24),
              DateInputWidget(
                title: "Enter due date",
                controller: dateController,
                onChanged: (value) {
                  dateTimestamp = value;
                },
              ),

              // For dropdown widget, Data will be passed through by selecting category, which will be used as a key to
              // Acces category color and category name.
              TaskDropdownWidget(
                onChanged: (value) {
                  selectedCategory = value;
                },
              ),

              SizedBox(height: 64),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
              if (taskKey.currentState!.validate()) {
                uploadTaskToDb(
                  titleController,
                  descriptionController,
                  dateTimestamp!,
                  selectedCategory,
                );
                setState(() {
                  dropdownValue = null;
                });
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Create Task',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
