import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hackit_2025/data/constants.dart';
import 'package:hackit_2025/services/work_session_service.dart';
import 'package:hackit_2025/views/pages/WorkSession/session_results_page.dart';
import 'package:hackit_2025/views/pages/Tasks/task_display_page.dart';
import 'package:hackit_2025/views/pages/add_category_page.dart';
import 'package:hackit_2025/views/widgets/task_widget.dart';

class WorkSessionPage extends StatefulWidget {
  const WorkSessionPage({super.key});
  @override
  State<WorkSessionPage> createState() => _WorkSessionPageState();
}

class _WorkSessionPageState extends State<WorkSessionPage>
    with WidgetsBindingObserver {
  SessionMode _mode = SessionMode.working;

  final Set<String> _mutatingTasks = <String>{};

  Future<void> _toggleSemi(String taskId, bool newValue) async {
    if (!mounted || _mutatingTasks.contains(taskId)) return;

    // show the little spinner immediately
    setState(() => _mutatingTasks.add(taskId));

    try {
      await FirebaseFirestore.instance.collection('tasks').doc(taskId).update({
        'semicomplete': newValue,
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not update task. Try again.')),
        );
      }
    } finally {
      if (!mounted) return;

      // Defer removing the spinner until AFTER the next frame so we don’t
      // compete with the StreamBuilder list diff and trigger a transient error.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _mutatingTasks.remove(taskId));
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _boot();
  }

  Future<void> _boot() async {
    await WorkSessionService.I.ensureLoaded();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  Future<void> _confirmLeaveToResults() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave Work Session'),
        content: const Text('Are you sure you want to end this session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    await WorkSessionService.I.stopAndFreeze();

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const WorkSessionResultsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final snap = WorkSessionService.I.snap;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.meeting_room_outlined), // door-ish icon
          onPressed: _confirmLeaveToResults,
        ),
        //title: const Text('Work Session'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Align(
            alignment: AlignmentGeometry.center,
            child: Text(
              snap?.title ?? 'Work Session',
              style: KTextStyle.titleText,
              textAlign: TextAlign.center,
            ),
          ),
          if ((snap?.description ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Align(
              alignment: AlignmentGeometry.center,
              child: Center(
                child: Text(
                  snap!.description,
                  textAlign: TextAlign.center,
                  style: KTextStyle.descriptionText,
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),

          // Timer circle
          const _TimerCircle(),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () async {
                    await WorkSessionService.I.toggleMode();
                    if (mounted) {
                      setState(() {
                        _mode = WorkSessionService.I
                            .now()
                            .$3; // update label/color once
                      });
                    }
                  },
                  icon: Icon(
                    _mode == SessionMode.working
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                  ),
                  label: Text(
                    _mode == SessionMode.working ? 'Take break' : 'Resume',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _confirmLeaveToResults,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('End session'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),
          // Text(
          //   'Tasks',
          //   style: KTextStyle.header2Text.copyWith(color: cs.onSurface),
          // ),
          // const SizedBox(height: 8),

          // Active tasks (semicomplete == false)
          _SessionTaskSection(
            title: 'To do',
            semicomplete: false,
            mutatingIds: _mutatingTasks,
            onToggle: (id, v) => _toggleSemi(id, v),
          ),
          const SizedBox(height: 12),

          // Completed in this session (collapsible)
          ExpansionTile(
            initiallyExpanded: false,
            title: Text('Completed Tasks', style: KTextStyle.header3Text),
            children: [
              _SessionTaskSection(
                title: null,
                semicomplete: true,
                mutatingIds: _mutatingTasks,
                onToggle: (id, v) => _toggleSemi(id, v),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ],
      ),
    );
  }
}

class _SessionTaskSection extends StatelessWidget {
  final String? title;
  final bool semicomplete;
  final Set<String> mutatingIds;
  final Future<void> Function(String taskId, bool newValue) onToggle;

  const _SessionTaskSection({
    required this.title,
    required this.semicomplete,
    required this.mutatingIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final stream = FirebaseFirestore.instance
        .collection('tasks')
        .where('user', isEqualTo: uid)
        .where('completed', isEqualTo: false)
        .where('semicomplete', isEqualTo: semicomplete)
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snap) {
        if (snap.hasError) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('Error loading tasks')),
          );
        }
        if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              semicomplete ? 'No tasks completed yet' : 'No tasks to do',
              style: KTextStyle.descriptionText,
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(title!, style: KTextStyle.header3Text),
              const SizedBox(height: 8),
            ],
            for (int i = 0; i < docs.length; i++) ...[
              KeyedSubtree(
                // stable identity as items move between lists
                key: ValueKey(docs[i].id),
                child: _SessionTaskTile(
                  doc: docs[i],
                  mutatingIds: mutatingIds,
                  onToggle: onToggle,
                ),
              ),
              if (i < docs.length - 1)
                const SizedBox(height: 12), // <— spacing,
            ],
          ],
        );
      },
    );
  }
}

/// Looks like your TaskWidget but the checkbox toggles `semicomplete` instead
/// of the permanent `completed` field.
class _SessionTaskTile extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> doc;
  final Set<String> mutatingIds;
  final Future<void> Function(String taskId, bool newValue) onToggle;

  const _SessionTaskTile({
    required this.doc,
    required this.mutatingIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final data = doc.data();

    // Safe extraction with defaults for any missing fields
    final String title = (data['title'] as String?) ?? 'Untitled';
    final String description = (data['description'] as String?) ?? '';
    final Timestamp date = (data['date'] as Timestamp?) ?? Timestamp.now();
    final String docid = (data['docid'] as String?) ?? doc.id;
    final String? catId = data['category']?.toString();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: (catId == null)
          ? const Stream.empty()
          : FirebaseFirestore.instance
                .collection('category')
                .doc(catId)
                .snapshots(),
      builder: (context, catSnap) {
        // While the category doc is loading or missing, render a lightweight placeholder
        if (catId == null ||
            catSnap.connectionState == ConnectionState.waiting ||
            !catSnap.hasData ||
            catSnap.data?.data() == null) {
          return const SizedBox(
            height: 96,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        final cat = catSnap.data!.data()!;
        final String catName = (cat['categoryName'] as String?) ?? 'category';
        final int catColor = (cat['categoryColor'] as int?) ?? 0xFFE0E0E0;

        final bool isSemi = (data['semicomplete'] == true);
        final bool isMutating = mutatingIds.contains(doc.id);

        return Stack(
          children: [
            // Disable taps while we’re mutating to avoid double writes
            IgnorePointer(
              ignoring: isMutating,
              child: GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TaskDisplayPage(
                        title: title,
                        description: description,
                        date: date,
                        categoryName: catName,
                        categoryColor: catColor,
                        docid: docid,
                      ),
                    ),
                  );
                },
                child: TaskWidget(
                  key: ValueKey('task-${doc.id}'),
                  title: title,
                  description: description,
                  date: date,
                  categoryName: catName,
                  categoryColor: catColor,
                  docid: docid,
                  showCheckbox: !isMutating, // hide while writing
                  checkboxValue: isSemi, // visual state
                  onCheckboxChanged: (v) {
                    if (v != null) onToggle(doc.id, v); // flips semicomplete
                  },
                ),
              ),
            ),

            // Tiny spinner top-right while writing
            Positioned(
              right: 14,
              top: 14,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: isMutating
                    ? const SizedBox(
                        key: ValueKey('spin'),
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const SizedBox.shrink(key: ValueKey('none')),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TimerCircle extends StatelessWidget {
  const _TimerCircle({super.key});

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Rebuild just this widget once per second
    return StreamBuilder<int>(
      stream: Stream.periodic(const Duration(seconds: 1), (i) => i),
      builder: (_, __) {
        final tuple = WorkSessionService.I.now();
        final work = tuple.$1;
        final rest = tuple.$2;
        final mode = tuple.$3;

        final isWorking = mode == SessionMode.working;
        final label = isWorking ? 'Working' : 'Resting';
        final time = _fmt(isWorking ? work : rest);

        return Center(
          child: Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isWorking ? cs.primary : Colors.teal,
                width: 10,
              ),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: KTextStyle.header3Text),
                const SizedBox(height: 6),
                Text(time, style: KTextStyle.titleText),
              ],
            ),
          ),
        );
      },
    );
  }
}
