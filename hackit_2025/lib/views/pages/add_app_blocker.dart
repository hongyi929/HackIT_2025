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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text("Add App Blocker", style: KTextStyle.header1Text),
            SizedBox(
              height: 100,
              child: Center(
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // center the 2 items
                  children: List.generate(2, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                      ), // spacing
                      child: ChoiceChip(
                        selected: selectedIndex == index,
                        label: Text(
                          index == 0 ? "Time Blocker" : "Other Blocker",
                        ),
                        onSelected: (value) {
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                      ),
                    );
                  }),
                ),
              ),
            ),
            TimeBlockWidget(titleController: timeBlockTitleController)
          ],
        ),
      ),
    );
  }
}
