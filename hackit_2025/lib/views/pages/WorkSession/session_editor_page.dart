import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hackit_2025/data/constants.dart';
import 'package:hackit_2025/services/work_session_service.dart';
import 'package:hackit_2025/views/pages/Tasks/task_display_page.dart';
import 'package:hackit_2025/views/pages/WorkSession/work_session_page.dart';
import 'package:hackit_2025/views/widgets/task_widget.dart';

class SessionEditorPage extends StatefulWidget {
  const SessionEditorPage({super.key});

  @override
  State<SessionEditorPage> createState() => _SessionEditorPageState();
}

class _SessionEditorPageState extends State<SessionEditorPage> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // Fixed CTA
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: SizedBox(
          height: 54,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () async {
              final title = _titleCtrl.text.trim();
              final desc = _descCtrl.text.trim();
              final uid = FirebaseAuth.instance.currentUser!.uid;

              if (title.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a title')),
                );
                return;
              }

              // 1) start & seed flags
              await WorkSessionService.I.start(
                title: title,
                description: desc,
                uid: uid,
              );

              // 2) go to the live session page
              if (!mounted) return;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const WorkSessionPage()),
              );
            },

            child: const Text(
              'Create Session',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Begin Work Session', style: KTextStyle.header1Text),

              const SizedBox(height: 24),
              Text(
                'Title',
                style: KTextStyle.header2Text.copyWith(color: cs.onSurface),
              ),
              const SizedBox(height: 8),
              _InputField(controller: _titleCtrl, hint: 'Enter title here'),

              const SizedBox(height: 20),
              Text(
                'Description',
                style: KTextStyle.header2Text.copyWith(color: cs.onSurface),
              ),
              const SizedBox(height: 8),
              _InputField(
                controller: _descCtrl,
                hint: 'Enter description here',
                maxLines: 3,
              ),

              const SizedBox(height: 24),
              Text(
                'Tasks to complete',
                style: KTextStyle.header2Text.copyWith(color: cs.onSurface),
              ),
              const SizedBox(height: 10),

              // Filters + list live here and scroll; CTA stays fixed
              Expanded(
                child: _TaskPickerPanel(
                  uid: FirebaseAuth.instance.currentUser!.uid,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  const _InputField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: KTextStyle.descriptionText,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        focusColor: Colors.white,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.blue, width: 1.5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.grey, width: 1.5),
        ),
        isCollapsed: true,
        prefix: const SizedBox(width: 12),
      ),
    );
  }
}

class _TaskPickerPanel extends StatefulWidget {
  final String uid;
  const _TaskPickerPanel({required this.uid});

  @override
  State<_TaskPickerPanel> createState() => _TaskPickerPanelState();
}

class _TaskPickerPanelState extends State<_TaskPickerPanel> {
  int selectedIndex = 0;
  String? _selectedCategoryDocId;

  Stream<QuerySnapshot<Map<String, dynamic>>> _buildTaskStream() {
    Query<Map<String, dynamic>> q = FirebaseFirestore.instance
        .collection('tasks')
        .where('user', isEqualTo: widget.uid)
        .where('completed', isEqualTo: false);

    if (selectedIndex == 1) {
      q = q.where('category', isEqualTo: '${widget.uid}star');
    } else if (selectedIndex >= 2 && _selectedCategoryDocId != null) {
      q = q.where('category', isEqualTo: _selectedCategoryDocId);
    }
    return q.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ---------- FILTER ROW ----------
        SizedBox(
          height: 40,
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('category')
                .where('user', isEqualTo: widget.uid)
                .snapshots(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting &&
                  !snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snap.data?.docs ?? const [];

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 2 + docs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return ChoiceChip(
                      label: const Text('All'),
                      selected: selectedIndex == 0,
                      onSelected: (_) => setState(() {
                        selectedIndex = 0;
                        _selectedCategoryDocId = null;
                      }),
                    );
                  }
                  if (index == 1) {
                    return ChoiceChip(
                      label: const Icon(Icons.star),
                      selected: selectedIndex == 1,
                      onSelected: (_) => setState(() {
                        selectedIndex = 1;
                        _selectedCategoryDocId = null;
                      }),
                    );
                  }

                  final catDoc = docs[index - 2];
                  final label =
                      catDoc.data()['categoryName'] as String? ?? 'Category';
                  return ChoiceChip(
                    label: Text(label),
                    selected: selectedIndex == index,
                    onSelected: (_) => setState(() {
                      selectedIndex = index;
                      _selectedCategoryDocId = catDoc.id;
                    }),
                  );
                },
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // ---------- TASK LIST ----------
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _buildTaskStream(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting &&
                  !snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snap.data?.docs ?? const [];

              if (docs.isEmpty) {
                return const Center(child: Text('No tasks match this filter'));
              }

              return ListView.separated(
                itemCount: docs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final d = docs[index];
                  final data = d.data();

                  return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('category')
                        .doc(data['category']?.toString())
                        .snapshots(),
                    builder: (context, catSnap) {
                      if (catSnap.connectionState == ConnectionState.waiting &&
                          !catSnap.hasData) {
                        return const SizedBox(
                          height: 96,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final catName = catSnap.data?.data()?['categoryName'];
                      final catColor = catSnap.data?.data()?['categoryColor'];

                      return GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TaskDisplayPage(
                                title: data['title'],
                                description: data['description'],
                                date: data['date'],
                                categoryName: catName,
                                categoryColor: catColor,
                                docid: data['docid'],
                              ),
                            ),
                          );
                          if (mounted) setState(() {});
                        },
                        child: TaskWidget(
                          title: data['title'],
                          description: data['description'],
                          date: data['date'],
                          categoryName: catName,
                          categoryColor: catColor,
                          docid: data['docid'],
                          showCheckbox:
                              false, // ← hide completion checkbox on this page
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
