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
  DateTimeRange? _selectedRange;

  @override
  void initState() {
    super.initState();
    _refresh(); // first load
  }

  ({DateTime start, DateTime end}) _currentBounds() {
    if (_selectedRange != null) {
      final s = DateTime(
        _selectedRange!.start.year,
        _selectedRange!.start.month,
        _selectedRange!.start.day,
      );
      final eIncl = DateTime(
        _selectedRange!.end.year,
        _selectedRange!.end.month,
        _selectedRange!.end.day,
      );
      return (
        start: s,
        end: eIncl.add(const Duration(days: 1)),
      ); // end is exclusive
    }
    return rangeBounds(_range);
  }

  Future<void> _refresh() async {
    if (!Platform.isAndroid) return;

    await ensureUsagePermission();

    final b = _currentBounds();
    final fut = loadUsageRange(b.start, b.end);

    if (!mounted) return;
    _future = fut;
    setState(() {}); // synchronous setState

    await fut; // optional (for pull-to-refresh spinner)
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final lastMonth = now.subtract(const Duration(days: 30));

    final picked = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now,
      initialDateRange: DateTimeRange(start: lastMonth, end: now),
      helpText: 'Select a date range',
    );
    if (picked == null) return;

    // normalize to midnight for both ends (inclusive for display)
    final start = DateTime(
      picked.start.year,
      picked.start.month,
      picked.start.day,
    );
    final endIncl = DateTime(picked.end.year, picked.end.month, picked.end.day);

    _selectedRange = DateTimeRange(start: start, end: endIncl);

    // load with exclusive end
    final fut = loadUsageRange(start, endIncl.add(const Duration(days: 1)));
    _future = fut;
    if (mounted) setState(() {}); // triggers UI to swap the controls
  }

  void _setRange(TimeRange r) {
    _range = r;
    _selectedRange = null; // presets override custom date
    final b = rangeBounds(r);
    _future = loadUsageRange(b.start, b.end);
    if (mounted) setState(() {});
  }

  void _clearCustomRange() {
    _selectedRange = null;
    _refresh(); // fall back to Today/Week/Month
  }

  // nice short date label without extra packages
  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _fmtRange(DateTimeRange r) =>
      '${_fmtDate(r.start)} --> ${_fmtDate(r.end)}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<AppUsageRow>>(
        future: _future,
        builder: (context, snap) {
          final rows = snap.data ?? [];
          final total = totalUsage(rows);
          // debugPrint(
          //   'FB state=${snap.connectionState} rows=${rows.length}',
          // ); // DEBUGGING

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
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Chip(
                      'Today',
                      _selectedRange == null && _range == TimeRange.today,
                      () => _setRange(TimeRange.today),
                    ),
                    _Chip(
                      'This week',
                      _selectedRange == null && _range == TimeRange.week,
                      () => _setRange(TimeRange.week),
                    ),
                    _Chip(
                      'This month',
                      _selectedRange == null && _range == TimeRange.month,
                      () => _setRange(TimeRange.month),
                    ),

                    // When NO range is selected -> show an OUTLINED button
                    if (_selectedRange == null)
                      OutlinedButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label: const Text('Pick date'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),

                    // When a range IS selected -> show a filled-looking chip with an ×
                    if (_selectedRange != null)
                      Builder(
                        builder: (context) {
                          final cs = Theme.of(context).colorScheme;
                          return InputChip(
                            selected: true,
                            showCheckmark: false,
                            avatar: const Icon(Icons.event, size: 16),
                            label: Text(
                              'Selected: ${_fmtRange(_selectedRange!)}',
                            ),
                            onDeleted: _clearCustomRange,
                            deleteIcon: const Icon(Icons.close),
                            // make it look “filled” like a selected chip
                            selectedColor: cs
                                .primaryContainer, // M3: ok (you’re ignoring deprecations)
                            labelStyle: TextStyle(
                              color: cs.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
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
                        'Screen Time',
                        style: KTextStyle.header3Text.copyWith(
                          fontWeight: FontWeight.w600,
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
                  ...rows.map((r) => _AppRow(row: r, total: total)),
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
  final Duration total;
  const _AppRow({required this.row, required this.total});

  @override
  Widget build(BuildContext context) {
    final totalSecs = total.inSeconds;
    final target = totalSecs == 0 ? 0.0 : row.usage.inSeconds / totalSecs;

    final cs = Theme.of(context).colorScheme;
    final primary = cs.primary; // blue
    final track = cs.surfaceVariant; // gray

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: row.iconBytes != null
            ? Image.memory(row.iconBytes!, width: 32, height: 32)
            : const Icon(Icons.apps),
        title: Text(row.displayName),

        // Progress bar + caption UNDER the title
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),

            // ANIMATED BAR
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: target.clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  color: primary,
                  backgroundColor: track.withOpacity(0.4),
                ),
              ),
            ),

            const SizedBox(height: 4),
          ],
        ),

        trailing: Text(
          formatDuration(row.usage),
          style: KTextStyle.header2Text.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
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
    // print('Pie data → total=${total.inMinutes}m, slices=${slices.length}');

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
