import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hackit_2025/data/constants.dart';
import 'package:intl/intl.dart';

class DateInputWidget extends StatelessWidget {
  const DateInputWidget({
    super.key,
    required this.title,
    required this.controller,
    required this.onChanged,
  });

  final String title;
  final TextEditingController controller;
  final Function(Timestamp) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        TextFormField(
          style: KTextStyle.descriptionText,
          textAlignVertical: TextAlignVertical.center,
          validator: (value) => value!.isEmpty ? "Date needs to be filled" : null,
          decoration: InputDecoration(
            hintText: "Due Date",
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                color: Colors.grey,
                width: 1.5
              )
            ),
            isCollapsed: true,
            contentPadding: EdgeInsets.symmetric(vertical: 16.0),
            prefixIcon: Icon(Icons.calendar_month),
          ),
          controller: controller,
          onTap: () async {
            DateTime? datetime = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2025),
              lastDate: DateTime(2100),
            );
            if (datetime != null) {
              print("$datetime is here");
              onChanged(Timestamp.fromDate(datetime));
              String formattedDate = DateFormat(
                "d MMM yyyy",
              ).format(datetime);
              controller.text = formattedDate;
            }
          },
        ),
      ],
    );
  }
}
