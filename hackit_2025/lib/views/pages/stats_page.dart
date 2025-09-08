// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hackit_2025/data/constants.dart';
import 'package:fl_chart/fl_chart.dart'; // for the chart
import '../../services/usage_service.dart'; // our logic helpers

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

    await ensureUsagePermission();

    // Start async work OUTSIDE setState
    final fut = loadUsage(_range);
    if (!mounted) return;

    // Assign fields synchronously, then call setState with an empty body
    _future = fut;
    setState(() {}); // <-- sync only

    // Optional: keeps pull-to-refresh spinner accurate
    await fut;
  }

  void _setRange(TimeRange r) {
    _range = r;
    _future = loadUsage(r);
    if (mounted) setState(() {}); // <-- sync only
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<AppUsageRow>>(
        future: _future,
        builder: (context, snap) {
          final rows = snap.data ?? [];
          final total = totalUsage(rows);
          debugPrint(
            'FB state=${snap.connectionState} rows=${rows.length}',
          ); // DEBUGGING

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                Text(
                  'Insights',
                  style: KTextStyle.titleText.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 10.0),
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
                //const SizedBox(height: 24),

                // show a pie chart of top apps for the current range
                if (rows.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _UsagePie(rows: rows),
                  const SizedBox(height: 16),
                ],

                // Big number
                Center(
                  child: Column(
                    children: [
                      Text(
                        formatDuration(total),
                        style: KTextStyle.interText.copyWith(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'SCREEN TIME',
                        style: KTextStyle.header3Text.copyWith(
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                Text(
                  'Most used apps',
                  style: KTextStyle.header1Text.copyWith(),
                ),
                const SizedBox(height: 12),

                if (snap.connectionState == ConnectionState.waiting)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (rows.isEmpty)
                  const Center(
                    child: Column(
                      children: [
                        Text(
                          'No data yet. Make sure “Usage Access” is enabled in Settings.',
                        ),
                      ],
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

class _UsagePie extends StatelessWidget {
  final List<AppUsageRow> rows;
  const _UsagePie({required this.rows});

  @override
  Widget build(BuildContext context) {
    // Defensive: ensure we have data
    if (rows.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort & take top 5; group the rest as "Other"
    final sorted = [...rows]..sort((a, b) => b.usage.compareTo(a.usage));
    final top5 = sorted.take(5).toList();

    final total = sorted.fold<Duration>(Duration.zero, (s, r) => s + r.usage);
    if (total.inSeconds <= 0) {
      // Nothing to chart yet
      return const SizedBox.shrink();
    }

    final others = sorted
        .skip(5)
        .fold<Duration>(Duration.zero, (s, r) => s + r.usage);

    // Build slices (value = seconds)
    final List<_Slice> slices = [
      ...top5.map(
        (r) => _Slice(label: r.displayName, seconds: r.usage.inSeconds),
      ),
      if (others.inSeconds > 0)
        _Slice(label: 'Other', seconds: others.inSeconds),
    ];

    // DEBUGGING: see what we’re plotting
    // ignore: avoid_print
    print('Pie data → total=${total.inMinutes}m, slices=${slices.length}');

    // High-contrast, safe palette (so it’s visible in any theme)
    const palette = <Color>[
      Color(0xFF1E88E5), // blue
      Color(0xFFD81B60), // pink
      Color(0xFF43A047), // green
      Color(0xFFF4511E), // orange
      Color(0xFF8E24AA), // purple
      Color(0xFF00897B), // teal
      Color(0xFF3949AB), // indigo
      Color(0xFFFB8C00), // amber
    ];

    final sections = <PieChartSectionData>[];
    final totalSeconds = total.inSeconds.toDouble();
    for (var i = 0; i < slices.length; i++) {
      final s = slices[i];
      final pct = (s.seconds / totalSeconds * 100).clamp(0, 100);
      sections.add(
        PieChartSectionData(
          value: s.seconds.toDouble(),
          title: '${pct.toStringAsFixed(0)}%',
          radius: 70,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
          color: palette[i % palette.length],
        ),
      );
    }

    return Column(
      children: [
        // Give it space so it’s definitely visible
        SizedBox(
          height: 220,
          child: DecoratedBox(
            // subtle background so you can visually “locate” the chart area
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withOpacity(0.25),
              borderRadius: BorderRadius.circular(16),
            ),
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 36,
                sectionsSpace: 2,
                startDegreeOffset: -90,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Compact legend
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: [
            for (var i = 0; i < slices.length; i++)
              _LegendItem(
                color: palette[i % palette.length],
                label: slices[i].label,
                duration: Duration(seconds: slices[i].seconds),
              ),
          ],
        ),
      ],
    );
  }
}

class _Slice {
  final String label;
  final int seconds;
  _Slice({required this.label, required this.seconds});
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final Duration duration;
  const _LegendItem({
    required this.color,
    required this.label,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withOpacity(0.4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            '$label · ${formatDuration(duration)}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
