import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hackit_2025/data/constants.dart';
import 'package:hackit_2025/data/notifiers.dart';
import 'package:hackit_2025/views/pages/Tasks/add_tasks_page.dart';
import 'package:hackit_2025/views/pages/Tasks/task_display_page.dart';
import 'package:hackit_2025/views/widgets/filter_button.dart';
import 'package:hackit_2025/views/widgets/task_widget.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

String? uid = FirebaseAuth.instance.currentUser!.uid;

class _TasksPageState extends State<TasksPage> {
  String? selectedCategory;

  int? selectedIndex = 0;
  Stream<QuerySnapshot<Map<String, dynamic>>>? stream = FirebaseFirestore
      .instance
      .collection("tasks")
      .where("user", isEqualTo: uid)
      .where("completed", isEqualTo: false)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    uid = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFC0E6FF), Color(0xFFF5FBFF)],
            begin: Alignment.topCenter,
            end: Alignment(0, 0.7),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Tasks", style: KTextStyle.titleText),
              SizedBox(height: 10.0),
              // Replace row with a horizontal listview.builder
              // Every item is the category filtered with UID. Starts with all first followed by starred (logic done last)
              // Then the categories by alphabetical order.
              // Use ... operator to combine these items together
              // Snapshot obtained, and then index of items to go through each of them 1 by 1
              // When clicked, selectedIndex == index of item. Then
              // If true, snapshot of tasks itself will be filtered by those conditions
              // So... filtered .where categoryName == the categoryName obtained from the index.
              // Have a variable store that, and use that variable in the task streambuilder
              // Also when selected, return a new boolean to the widget itself to change its UI Look
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("category")
                    .where(
                      "user",
                      isEqualTo: FirebaseAuth.instance.currentUser!.uid,
                    )
                    .snapshots(),
                builder: (context, categoryStream) {
                  if (categoryStream.connectionState == ConnectionState.waiting &&
                      !categoryStream.hasData) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: SizedBox(
                        height: 40,
                        child: ListView.builder(
                          itemCount: 2 + categoryStream.data!.docs.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return Row(
                                children: [
                                  ChoiceChip(
                                    label: Text("All"),
                                    selected: selectedIndex == index,
                                    onSelected: (value) {
                                      setState(() {
                                        selectedIndex = index;
                                        stream = FirebaseFirestore.instance
                                            .collection("tasks")
                                            .where("user", isEqualTo: uid)
                                            .where("completed", isEqualTo: false)
                                            .snapshots();
                                      });
                                    },
                                  ),
                                  SizedBox(width: 10),
                                ],
                              );
                            } else if (index == 1) {
                              return Row(
                                children: [
                                  ChoiceChip(
                                    label: Icon(Icons.star),
                                    selected: selectedIndex == index,
                                    onSelected: (value) {
                                      setState(() {
                                        selectedIndex = index;
                                        stream = FirebaseFirestore.instance
                                            .collection("tasks")
                                            .where("user", isEqualTo: uid)
                                            .where(
                                              "category",
                                              isEqualTo: (uid! + "star")
                                                  .toString(),
                                            )
                                            .where("completed", isEqualTo: false)
                                            .snapshots();
                                      });
                                    },
                                  ),
                                  SizedBox(width: 10),
                                ],
                              );
                            } else {
                              return Row(
                                children: [
                                  ChoiceChip(
                                    label: Text(
                                      categoryStream.data!.docs[index - 2]
                                          .data()['categoryName'],
                                    ),
                                    selected: selectedIndex == index,
                                    onSelected: (value) {
                                      setState(() {
                                        selectedIndex = index;
                                        stream = FirebaseFirestore.instance
                                            .collection("tasks")
                                            .where("user", isEqualTo: uid)
                                            .where(
                                              "category",
                                              isEqualTo:
                                                  uid! +
                                                  categoryStream
                                                      .data!
                                                      .docs[index - 2]
                                                      .data()['categoryName'],
                                            )
                                            .where("completed", isEqualTo: false)
                                            .snapshots();
                                      });
                                    },
                                  ),
                                  SizedBox(width: 10),
                                ],
                              );
                            }
                          },
                        ),
                      ),
                    );
                  }
                },
              ),
              SizedBox(height: 30),
              Expanded(
                child: StreamBuilder(
                  stream: stream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        !snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text("You have no active tasks"),
                      );
                    } else {
                      print(snapshot.data!.docs);
                      return AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        child: ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          key: ValueKey(snapshot.data!.docs.length),
                          itemBuilder: (context, index) {
                            Map<String, dynamic> taskMap = snapshot
                                .data!
                                .docs[index]
                                .data();
                            return Column(
                              children: [
                                // range error when title name is the same (solved)
                                // When 2 items have same categoryname, a type null is not a subtype of type string error occurs
                                StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection("category")
                                      .doc(taskMap['category'].toString())
                                      .snapshots(),
                                  builder: (context, categoryStream) {
                                    if (categoryStream.connectionState ==
                                            ConnectionState.waiting &&
                                        !categoryStream.hasData) {
                                      return Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    } else {
                                      return AnimatedSwitcher(
                                        duration: Duration(milliseconds: 300),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) {
                                                  return TaskDisplayPage(
                                                    title: taskMap['title'],
                                                    description:
                                                        taskMap['description'],
                                                    date: taskMap['date'],
                                                    categoryName: categoryStream
                                                        .data!['categoryName'],
                                                    categoryColor: categoryStream
                                                        .data!['categoryColor'],
                                                    docid: taskMap['docid'],
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                          child: TaskWidget(
                                            title: taskMap['title'],
                                            description: taskMap['description'],
                                            date: taskMap['date'],
                                            categoryName: categoryStream
                                                .data!['categoryName'],
                                            categoryColor: categoryStream
                                                .data!['categoryColor'],
                                            docid: taskMap['docid'],
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                                SizedBox(height: 20),
                              ],
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
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
        backgroundColor: Color(0XFF1B69E0),
      ),
    );
  }
}
