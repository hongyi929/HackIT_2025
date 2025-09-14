import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hackit_2025/data/constants.dart';
import 'package:hackit_2025/views/pages/add_category_page.dart';
import 'package:hackit_2025/views/widgets/category_dropdown_item.dart';

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
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("category")
          .where("user", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return Text("There is no data!");
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24),
            Text("Category", style: KTextStyle.header2Text),
            SizedBox(
              width: double.infinity,
              child: ButtonTheme(
                child: DropdownButtonFormField2(
                  validator: (value) =>
                      value != null ? null : "Category needs to be selected",
                  value: dropdownValue,
                  hint: Text("Select your category, bucko."),
                  isExpanded: true,
                  items: [
                    ...snapshot.data!.docs.map((categoryDictionary) {
                      return DropdownMenuItem(
                        value: categoryDictionary['categoryName'].toString(),
                        child: CategoryDropdownItem(
                          categoryName: categoryDictionary['categoryName'],
                          categoryColor: Color(
                            categoryDictionary['categoryColor'],
                          ),
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
                      setState(() {
                        dropdownValue = null;
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return AddCategoryPage();
                          },
                        ),
                      );
                    } else {
                      dropdownValue = value;
                      widget.onChanged(value);
                    }
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
