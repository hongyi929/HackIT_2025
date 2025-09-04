import 'dart:io';
import 'package:flutter/material.dart';

import '/data/usage_service.dart'; // our logic helpers

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  TimeRange _range = TimeRange.today;
  Future<List<AppUsageRow>>? _future;

  @override
  void initState() {
    super.initState();
    _refresh(); // first load
  }

  Future<void> _refresh() async {
    if (!Platform.isAndroid) return;

    // Option A (simple): just await, ignore the bool
    await ensureUsagePermission();

    // Option B (use the bool) – uncomment if you want a hint to the user:
    // final granted = await ensureUsagePermission();
    // if (!granted && mounted) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Enable "Usage Access" to see your stats')),
    //   );
    // }

    setState(() => _future = loadUsage(_range));
  }

  void _setRange(TimeRange r) {
    setState(() {
      _range = r;
      _future = loadUsage(r);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: FutureBuilder<List<AppUsageRow>>(
        future: _future,
        builder: (context, snap) {
          final rows = snap.data ?? [];
          final total = totalUsage(rows);

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Segmented filter
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Chip(
                      'Today',
                      _range == TimeRange.today,
                      () => _setRange(TimeRange.today),
                    ),
                    const SizedBox(width: 8),
                    _Chip(
                      'This week',
                      _range == TimeRange.week,
                      () => _setRange(TimeRange.week),
                    ),
                    const SizedBox(width: 8),
                    _Chip(
                      'This month',
                      _range == TimeRange.month,
                      () => _setRange(TimeRange.month),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Big number
                Center(
                  child: Column(
                    children: [
                      Text(
                        formatDuration(total),
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'SCREEN TIME',
                        style: TextStyle(letterSpacing: 1.2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Most used apps',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),

                if (snap.connectionState == ConnectionState.waiting)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (rows.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No data yet. Make sure “Usage Access” is enabled in Settings.',
                    ),
                  )
                else
                  // ⬇️ No .toList() needed; map() already returns an Iterable
                  ...rows.map((r) => _AppRow(r)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Chip(this.label, this.selected, this.onTap);

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

class _AppRow extends StatelessWidget {
  final AppUsageRow row;
  const _AppRow(this.row);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: row.iconBytes != null
            ? Image.memory(row.iconBytes!, width: 32, height: 32)
            : const Icon(Icons.apps),
        title: Text(row.displayName),
        trailing: Text(
          formatDuration(row.usage),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
