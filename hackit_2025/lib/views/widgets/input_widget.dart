import 'package:flutter/material.dart';
import 'package:hackit_2025/data/constants.dart';

class InputWidget extends StatelessWidget {
  const InputWidget({super.key, required this.title, required this.controller});

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
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      style: KTextStyle.descriptionText,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: "Enter the title",
                        border: InputBorder.none,
                        isCollapsed: true,
                      ),
                      controller: inputController
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
