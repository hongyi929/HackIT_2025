import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:hackit_2025/views/pages/add_category_page.dart';
import 'package:hackit_2025/views/widgets/category_dropdown_item.dart';

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
                    child: CategoryDropdownItem(
                      categoryName: "Programming 1",
                      categoryColor: Color(0xFF123456),
                    )
                  ),
                ),
                DropdownMenuItem(
                  value: "gr",
                  child: SizedBox(width: double.infinity, child: Text("Green")),
                ),
                DropdownMenuItem(
                  value: "popo",
                  child: GestureDetector(
                    child: SizedBox(
                      child: Row(
                        children: [
                          Icon(Icons.add),
                          SizedBox(width: 10),
                          Text("Add new category..."),
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return AddCategoryPage();
                      },));
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
