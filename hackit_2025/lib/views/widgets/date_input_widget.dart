import 'package:flutter/material.dart';
import 'package:hackit_2025/data/constants.dart';
import 'package:intl/intl.dart';

class DateInputWidget extends StatelessWidget {
  const DateInputWidget({super.key, required this.title, required this.controller});

  final String title;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    TextEditingController inputController = TextEditingController();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        SizedBox(
          height: 60,
          child: Card.outlined(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: KTextStyle.descriptionText,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: "Due Date",
                        border: InputBorder.none,
                        isCollapsed: true,
                        prefixIcon: Icon(Icons.calendar_month)
                      ),
                      controller: inputController,
                      onTap:() async {
                        DateTime? datetime = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2025), lastDate: DateTime(2100));
                        if (datetime != null) {
                          String formattedDate = DateFormat("MMM d yyyy").format(datetime);
                          inputController.text = formattedDate;
                        }

                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
