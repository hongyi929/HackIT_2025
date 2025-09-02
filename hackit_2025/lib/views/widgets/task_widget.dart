import 'package:flutter/material.dart';
import 'package:hackit_2025/data/constants.dart';

class TaskWidget extends StatelessWidget {
  const TaskWidget({super.key, required this.title, required this.description, required this.date});

  final String title;
  final String description;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: SizedBox(
          height: 100,
          width: double.infinity,
          // Row to separate 2 items: column of description items, and checkbox.
          // Expanded widget is used so descriptor items take up all available space from checkbox
          child: Row(
            children: [
              Expanded(
                // Column for the 3 main descriptor items (Header, Desc, Date.)
                // Extra row is used to separate calendar icon and date text.
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: KTextStyle.header3Text),
                    // softWrap argument to allow text to go into new line if overflows first line
                    // maxLines to determine how many lines before ellipsis is triggered
                    Text(
                      description,
                      softWrap: true,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Icon(Icons.calendar_month),
                        SizedBox(width: 10),
                        Text(date),
                      ],
                    ),
                  ],
                ),
              ),
              Checkbox(value: false, onChanged: (value) {}),
            ],
          ),
        ),
      ),
    );
  }
}
