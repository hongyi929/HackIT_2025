import 'package:flutter/material.dart';
import 'package:hackit_2025/data/constants.dart';

class InputWidget extends StatelessWidget {
  const InputWidget({super.key, required this.title, required this.controller});

  final String title;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: KTextStyle.header2Text),
        SizedBox(height: 5),
        TextFormField(
          validator: (value) =>
              value!.isNotEmpty ? null : "$title needs to be filled.",
          style: KTextStyle.descriptionText,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 16.0),
            hintText: "Enter $title",
            filled: true,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.blue, width: 1.5),
            ),
            fillColor: Colors.white,
            focusColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.grey, width: 1.5),
            ),

            isCollapsed: true,
            prefix: SizedBox(width: 12),
          ),
          controller: controller,
        ),
      ],
    );
  }
}
