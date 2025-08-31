import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final myBox = Hive.box("task_box");

  void writeData() {
    myBox.put(1, "Mitch");
  }

  void readData() {
    print(myBox.get(1));
  }

  void deleteData() {
    myBox.delete(1);
  }

  TextEditingController testController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: testController,
              onEditingComplete: () {
                setState(() {
                  myBox.put(testController.text, testController.text);
                });
              },
            ),
            MaterialButton(
              onPressed: () {
                writeData();
              },
              child: Text("Write data"),
              color: Colors.blue,
            ),
            MaterialButton(
              onPressed: () {
                readData();
              },
              child: Text("Read data"),
              color: Colors.blue,
            ),
            MaterialButton(
              onPressed: () {
                deleteData();
              },
              child: Text("Delete data"),
              color: Colors.blue,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: myBox.length,
                itemBuilder: (context, index) {
                  String name = myBox.getAt(index);
                  return ListTile(
                    leading: IconButton(
                      onPressed: () {
                        setState(() {
                          myBox.deleteAt(index);
                        });
                      },
                      icon: Icon(Icons.remove),
                    ),
                    title: Text("$name"),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
