import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hackit_2025/data/constants.dart';
import 'package:intl/intl.dart';

class TaskWidget extends StatefulWidget {
  const TaskWidget({
    super.key,
    required this.title,
    required this.description,
    required this.date,
    required this.categoryName,
    required this.categoryColor,
    required this.docid,
  });

  final String title;
  final String description;
  final Timestamp date;
  final String categoryName;
  final int categoryColor;
  final String docid;

  @override
  State<TaskWidget> createState() => _TaskWidgetState();
}


double opacity = 1;

class _TaskWidgetState extends State<TaskWidget> {
  bool boolCheck = false;
  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: 1,
      duration: const Duration(milliseconds: 300),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              spreadRadius: 2,
              blurRadius: 2,
              offset: const Offset(2, 2),
            ),
          ],
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(widget.categoryColor), Colors.white],
            stops: [0.065, 0.065],
          ),
        ),
      
        child: Padding(
          padding: EdgeInsets.all(20),
          child: SizedBox(
            height: 100,
            width: double.infinity,
            // Row to separate 2 items: column of description items, and checkbox.
            // Expanded widget is used so descriptor items take up all available space from checkbox
            child: Row(
              children: [
                SizedBox(width: 15),
                Expanded(
                  // Column for the 3 main descriptor items (Header, Desc, Date.)
                  // Extra row is used to separate calendar icon and date text.
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title, style: KTextStyle.header3Text),
                      // softWrap argument to allow text to go into new line if overflows first line
                      // maxLines to determine how many lines before ellipsis is triggered
                      Text(
                        widget.description,
                        softWrap: true,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Icon(Icons.calendar_month),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "${DateFormat("MMM d yyyy").format(widget.date.toDate())}  |  ${widget.categoryName}",
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Checkbox(
                  value: boolCheck,
                  onChanged: (value) async {
                    setState(() async {
                      print("hi");
                      await FirebaseFirestore.instance
                          .collection("tasks")
                          .doc(widget.docid)
                          .update({"completed": true});
                      setState(() {
                        boolCheck = value!;
                        
                      });
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
