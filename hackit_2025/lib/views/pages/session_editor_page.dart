import 'package:flutter/material.dart';
import 'package:hackit_2025/views/widgets/input_widget.dart';

class SessionEditorPage extends StatefulWidget {
  const SessionEditorPage({super.key});

  @override
  State<SessionEditorPage> createState() => _SessionEditorPageState();
}

class _SessionEditorPageState extends State<SessionEditorPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            InputWidget(title: "Title", controller: titleController),
            InputWidget(title: "Description", controller: descriptionController)
          ],
        ),
      )
    );
  }
}