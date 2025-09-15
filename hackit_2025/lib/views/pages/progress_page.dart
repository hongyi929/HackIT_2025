// lib/views/pages/progress_page.dart
import 'package:flutter/material.dart';
import 'package:hackit_2025/data/constants.dart';
import 'package:hackit_2025/views/widgets/plant_panel.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFC0E6FF), Color(0xFFF5FBFF)],
            begin: Alignment.topCenter,
            end: Alignment(0, 0.7),
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20.0),
            children: [
              Text('Progress', style: KTextStyle.titleText),
              const SizedBox(height: 12),
        
              // -- Metrics row
              const SizedBox(height: 12),
              Row(
                children: const [
                  Expanded(
                    child: _MetricCard(label: 'Tasks completed', value: '28'),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(label: 'Time studied', value: '2h 45min'),
                  ),
                ],
              ),
        
              const SizedBox(height: 12),
        
              // Place your "Today / This week / Overall" filter chips here later
              // … then the plant:
              const PlantPanel(),
        
              const SizedBox(height: 24),
        
              // (Optional) your level bar, “tasks to next level”, etc…
            ],
          ),
        ),
      ),
    );
  }
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
