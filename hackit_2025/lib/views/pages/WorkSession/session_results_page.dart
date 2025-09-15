import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hackit_2025/data/constants.dart';
import 'package:hackit_2025/services/user_stats_service.dart';
import 'package:hackit_2025/services/work_session_service.dart';
import 'package:hackit_2025/views/widgets/task_widget.dart';

class WorkSessionResultsPage extends StatelessWidget {
  const WorkSessionResultsPage({super.key});

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '${h}h ${m}m' : '${m}min';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final snap = WorkSessionService.I.snap; // frozen in stopAndFreeze
    final WorkSessionService svc = WorkSessionService.I;
    final now = svc.now(); // reads frozen totals
    final work = now.$1;
    final rest = now.$2;

    final uid = FirebaseAuth.instance.currentUser!.uid;

    final completedStream = FirebaseFirestore.instance
        .collection('tasks')
        .where('user', isEqualTo: uid)
        .where('semicomplete', isEqualTo: true)
        .snapshots();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              snap?.title ?? 'Work Session',
              style: KTextStyle.titleText,
              textAlign: TextAlign.center,
            ),
            if ((snap?.description ?? '').isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                snap!.description,
                style: KTextStyle.descriptionText,
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),

            // Chips row
            Row(
              spacing: 12,
              children: [
                Expanded(
                  child: _MetricCard(
                    color: Colors.teal,
                    label: 'Rest time',
                    value: _fmt(rest),
                  ),
                ),
                Expanded(
                  child: _MetricCard(
                    color: cs.primary,
                    label: 'Time studied',
                    value: _fmt(work),
                  ),
                ),
                // count tasks via stream below; we’ll render the number there too
              ],
            ),
            const SizedBox(height: 8),

            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: completedStream,
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                final docs = snap.data?.docs ?? [];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // augment chips with count
                    if (snap.hasData)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _MetricCard(
                            color: Colors.blueAccent.shade400,
                            label: 'Tasks completed',
                            value: docs.length.toString(),
                          ),
                        ),
                      ),
                    SizedBox(height: 12),
                    if (docs.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Text(
                            'No tasks were completed in this session.',
                          ),
                        ),
                      )
                    else
                      Text("Tasks Completed", style: KTextStyle.header1Text),
                    SizedBox(height: 12),
                    for (final d in docs)
                      _CompletedTaskTile(doc: d), // no checkbox here
                  ],
                );
              },
            ),
          ],
        ),
      ),

      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0XFF1B69E0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () async {
              final uid = FirebaseAuth.instance.currentUser!.uid;
              final q = await FirebaseFirestore.instance
                  .collection('tasks')
                  .where('user', isEqualTo: uid)
                  .where('completed', isEqualTo: false)
                  .where('semicomplete', isEqualTo: true)
                  .get();

              // Convert & count
              final batch = FirebaseFirestore.instance.batch();
              for (final d in q.docs) {
                batch.update(d.reference, {
                  'completed': true,
                  'semicomplete': false,
                });
              }
              await batch.commit();

              // Award XP: 5 per task completed in this session
              if (q.docs.isNotEmpty) {
                await UserStatsService.I.incrementXp(5 * q.docs.length);
              }

              // finalize tasks & clear flags, then go home
              await WorkSessionService.I.applyResultsAndClearFlags();
              if (context.mounted) {
                Navigator.of(context).popUntil((r) => r.isFirst);
              }
            },
            child: const Text(
              'Continue',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final Color color;
  final String label;
  const _Chip({required this.color, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

class _CompletedTaskTile extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> doc;
  const _CompletedTaskTile({required this.doc});

  @override
  Widget build(BuildContext context) {
    final data = doc.data();
    final catId = data['category']?.toString();
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('category')
          .doc(catId)
          .snapshots(),
      builder: (context, catSnap) {
        if (catSnap.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        final catName = catSnap.data?.data()?['categoryName'];
        final catColor = catSnap.data?.data()?['categoryColor'];
        return TaskWidget(
          title: data['title'],
          description: data['description'],
          date: data['date'],
          categoryName: catName,
          categoryColor: catColor,
          docid: data['docid'],
          showCheckbox: false, // <— hide permanently on results
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  const _MetricCard({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        // ignore: deprecated_member_use
        border: Border.all(color: cs.outlineVariant.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: cs.shadow.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: KTextStyle.header3Text.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: KTextStyle.titleText.copyWith(color: color),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
