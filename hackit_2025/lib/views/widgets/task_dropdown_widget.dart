import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class TaskDropdownWidget extends StatefulWidget {
  const TaskDropdownWidget({super.key});

  @override
  State<TaskDropdownWidget> createState() => _TaskDropdownWidgetState();
}

String? dropdownValue;

class _TaskDropdownWidgetState extends State<TaskDropdownWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text("Category"),
        SizedBox(
          width: double.infinity,
          child: ButtonTheme(
            child: DropdownButton2(
              value: dropdownValue,
              hint: Text("Select your category, bucko."),
              isExpanded: true,
              items: [
                DropdownMenuItem(
                  value: "bl",
                  child: SizedBox(
                    width: double.infinity,
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(child: Text("The category item name")),
                      ],
                    ),
                  ),
                ),

                DropdownMenuItem(
                  value: "gr",
                  child: SizedBox(width: double.infinity, child: Text("Green")),
                ),
                DropdownMenuItem(
                  value: "gr",
                  child: GestureDetector(
                    child: SizedBox(
                      width: double.infinity,
                      child: Row(
                        children: [
                          Icon(Icons.add),
                          SizedBox(width: 10),
                          Text("Add new category..."),
                        ],
                      ),
                    ),
                    onTap: () {
                      
                    },
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  dropdownValue = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
