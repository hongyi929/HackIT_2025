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
      backgroundColor: Color(0XFFF3FAFF),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color(0XFFF3FAFF),
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
                height: 420,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5), // Shadow color
                      spreadRadius: 5, // How much the shadow spreads
                      blurRadius: 7, // How blurred the shadow is
                      offset: const Offset(0, 1), // Offset of the shadow (x, y)
                    ),
                  ],
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
                  child: SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 50),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              titleController.text,
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              descriptionController.text,
                              textAlign: TextAlign.center,
                            ),
                          ),

                          SizedBox(height: 50),

                          SizedBox(height: 10),
                          Text("Due date", style: KTextStyle.header2Text),
                          Text(dateController.text),
                          SizedBox(height: 50),

                          Text("Category", style: KTextStyle.header2Text),
                          Text(widget.categoryName),

                          SizedBox(height: 50),
                        ],
                      ),
                    ),
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
