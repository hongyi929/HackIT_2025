import 'package:flutter/material.dart';

class TaskDropdownWidget extends StatelessWidget {
  const TaskDropdownWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text("Category"),
        SizedBox(
          width: double.infinity,
          child: DropdownButton(
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
            ],
            onChanged: (value) {},
          ),
        ),
      ],
    );
  }
}
