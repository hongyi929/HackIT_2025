import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hackit_2025/data/constants.dart';
import 'package:hackit_2025/services/user_stats_service.dart';
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
    this.showCheckbox = true,
    this.checkboxValue, // parent-controlled value (optional)
    this.onCheckboxChanged, // parent-controlled handler (optional)
  });

  // Presentation
  final String title;
  final String description;
  final Timestamp date;
  final String categoryName;
  final int categoryColor;

  // Identity
  final String docid;

  // Checkbox control
  final bool showCheckbox;
  final bool? checkboxValue;
  final ValueChanged<bool?>? onCheckboxChanged;

  @override
  State<TaskWidget> createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
  // Local checkbox state used only when the parent doesn't control it.
  bool _localChecked = false;

  @override
  void initState() {
    super.initState();
    if (widget.checkboxValue != null) _localChecked = widget.checkboxValue!;
  }

  @override
  void didUpdateWidget(covariant TaskWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep in sync with parent if it provides a value
    if (widget.checkboxValue != null && widget.checkboxValue != _localChecked) {
      _localChecked = widget.checkboxValue!;
    }
  }

  Future<void> _defaultComplete() async {
    // Original behavior for the Tasks page
    await FirebaseFirestore.instance
        .collection('tasks')
        .doc(widget.docid)
        .update({'completed': true});

    // Award +5 XP per completed task
    await UserStatsService.I.incrementXp(5);
  }

  @override
  Widget build(BuildContext context) {
    final checkboxValue = widget.checkboxValue ?? _localChecked;

    return AnimatedOpacity(
      opacity: 1,
      duration: const Duration(milliseconds: 300),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              spreadRadius: 2,
              blurRadius: 2,
              offset: Offset(2, 2),
            ),
          ],
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(widget.categoryColor), Colors.white],
            stops: const [0.065, 0.065],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            height: 100,
            width: double.infinity,
            child: Row(
              children: [
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title, style: KTextStyle.header3Text),
                      Text(
                        widget.description,
                        softWrap: true,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          const Icon(Icons.calendar_month),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "${DateFormat('MMM d yyyy').format(widget.date.toDate())}  |  ${widget.categoryName}",
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

                // Trailing checkbox (optional)
                Visibility(
                  visible: widget.showCheckbox,
                  maintainState: false,
                  maintainAnimation: false,
                  maintainSize: false,
                  child: Checkbox(
                    value: checkboxValue,
                    onChanged: (val) async {
                      if (widget.onCheckboxChanged != null) {
                        // Work Session flow: parent decides (e.g., toggles `semicomplete`)
                        widget.onCheckboxChanged!(val);
                      } else {
                        // Tasks page default: mark task completed in Firestore
                        await _defaultComplete();
                        if (mounted) {
                          setState(() => _localChecked = val ?? false);
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
