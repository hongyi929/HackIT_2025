import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hackit_2025/data/constants.dart';
import 'package:hackit_2025/services/user_stats_service.dart';
import 'package:hackit_2025/views/widgets/plant_panel.dart';

// Format helper
String _fmtHM(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  return h > 0 ? '${h}h ${m}m' : '${m}m';
}

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});
  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            Text('Progress', style: KTextStyle.titleText),
            const SizedBox(height: 12),

            // -- Metrics row (live)
            const SizedBox(height: 12),
            FutureBuilder<_ProgressMetrics>(
              future: _loadProgressMetrics(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(12),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final data =
                    snap.data ??
                    const _ProgressMetrics(tasksDone: 0, study: Duration.zero);
                return Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        label: 'Tasks completed',
                        value: '${data.tasksDone}',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MetricCard(
                        label: 'Time studied',
                        value: _fmtHM(data.study),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 12),

            // Plant shows current XP/level/stage
            const PlantPanel(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<_ProgressMetrics> _loadProgressMetrics() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    // Tasks completed (safe fallback without aggregation)
    final tasksSnap = await FirebaseFirestore.instance
        .collection('tasks')
        .where('user', isEqualTo: uid)
        .where('completed', isEqualTo: true)
        .get();
    final completedCount = tasksSnap.docs.length;

    // Total study time
    final studyTotal = await UserStatsService.I.getStudyTotal();

    return _ProgressMetrics(tasksDone: completedCount, study: studyTotal);
  }
}

class _ProgressMetrics {
  final int tasksDone;
  final Duration study;
  const _ProgressMetrics({required this.tasksDone, required this.study});
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  const _MetricCard({required this.label, required this.value});

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
            style: KTextStyle.titleText.copyWith(color: cs.primary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
