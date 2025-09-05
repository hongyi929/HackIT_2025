import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:hackit_2025/views/pages/add_category_page.dart';
import 'package:hackit_2025/views/widgets/category_dropdown_item.dart';
import 'package:hive/hive.dart';

class TaskDropdownWidget extends StatefulWidget {
  const TaskDropdownWidget({super.key, required this.onChanged});
  
final Function(String?) onChanged;

  @override
  State<TaskDropdownWidget> createState() => _TaskDropdownWidgetState();
}


String? dropdownValue;

class _TaskDropdownWidgetState extends State<TaskDropdownWidget> {
  @override
  Widget build(BuildContext context) {
    final categoryBox = Hive.box("category_box");
    // test values

    categoryBox.put("Joedsmam", ["Joedsmam", 4293967395]);
    categoryBox.put("Joedssmam", ["Joedssmam", 4223967095]);
    var categoryList = categoryBox.values.toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text("Category"),
        SizedBox(
          width: double.infinity,
          child: ButtonTheme(
            child: DropdownButtonFormField2(
              validator: (value) => value != null ? null : "Category needs to be selected",
              value: dropdownValue,
              hint: Text("Select your category, bucko."),
              isExpanded: true,
              items: [
                ...categoryList.map((dropValue) {
                  return DropdownMenuItem(
                    value: dropValue[0].toString(),
                    child: CategoryDropdownItem(
                      categoryName: dropValue[0].toString(),
                      categoryColor: Color(dropValue[1]),
                    ),
                  );
                }).toList(),
                DropdownMenuItem(
                  value: "addCategory",
                  child: Row(
                    children: [
                      Icon(Icons.add),
                      SizedBox(width: 10),
                      Text("Add category"),
                    ],
                  ),
                ),
              ],

              onChanged: (value) {
                if (value == "addCategory") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return AddCategoryPage();
                      },
                    ),
                  );
                } else {
                  setState(() {
                    dropdownValue = value;
                  });
                  widget.onChanged(value);
                  dropdownValue = null;
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
