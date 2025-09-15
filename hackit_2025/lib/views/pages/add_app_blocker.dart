import 'package:flutter/material.dart';
import 'package:hackit_2025/data/constants.dart';
import 'package:hackit_2025/views/widgets/time_block_widget.dart';

class AddAppBlocker extends StatefulWidget {
  const AddAppBlocker({super.key});

  @override
  State<AddAppBlocker> createState() => _AddAppBlockerState();
}

TextEditingController timeBlockTitleController = TextEditingController();

class _AddAppBlockerState extends State<AddAppBlocker> {
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(color: Color(0XFFF3FAFF)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Text("Add App Blocker", style: KTextStyle.header1Text),
                SizedBox(height: 30, child: Center()),
                TimeBlockWidget(titleController: timeBlockTitleController),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
