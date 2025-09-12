// lib/views/widgets/plant_panel.dart
import 'package:flutter/material.dart';
import 'package:hackit_2025/data/constants.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hackit_2025/services/plant_service.dart';

class PlantPanel extends StatefulWidget {
  const PlantPanel({super.key});

  @override
  State<PlantPanel> createState() => _PlantPanelState();
}

class _PlantPanelState extends State<PlantPanel>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final AnimationController _controller;
  final _service = PlantService();

  int _xp = 0;
  int _level = 0;
  int _stage = 1;

  int _seenLevel = 0;
  int _seenStage = 1;

  bool _shouldPlayOnceNow = true; // play once each visit

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    Future.microtask(_loadAndMaybeCelebrate);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadAndMaybeCelebrate() async {
    final prefs = await SharedPreferences.getInstance();
    _seenLevel = prefs.getInt('plant.seenLevel') ?? 0;
    _seenStage = prefs.getInt('plant.seenStage') ?? 1;

    final progress = await _service.load();

    if (!mounted) return;
    setState(() {
      _xp = progress.xp;
      _level = progress.level;
      _stage = progress.stage;
      _shouldPlayOnceNow = true; // ensure we play after asset loads
    });

    if (_level > _seenLevel) {
      final stageChanged = _stage > _seenStage;
      await _showLevelUpDialog(level: _level, stageChanged: stageChanged);
      // NOTE: do NOT start the controller here — wait for onLoaded.
    }

    await prefs.setInt('plant.seenLevel', _level);
    await prefs.setInt('plant.seenStage', _stage);
  }

  Future<void> _showLevelUpDialog({
    required int level,
    required bool stageChanged,
  }) {
    final msg = stageChanged
        ? 'Congratulations, you have reached level $level!\nLook, your plant is growing and evolving!'
        : 'Congratulations, you have reached level $level!';

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Level up!'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _playOnceThenFreeze() {
    if (!mounted) return;
    _controller
      ..stop()
      ..reset();
    _controller.forward().whenComplete(() {
      if (!mounted) return;
      _controller.value = 1; // freeze on last frame
      setState(() => _shouldPlayOnceNow = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final cap = nextLevelCap(_level);
    final expText = cap == null ? '$_xp EXP (MAX)' : '$_xp / $cap EXP';

    final cs = Theme.of(context).colorScheme;
    final asset = lottieAssetForStage(_stage);

    // In-level progress numbers (e.g. 51 XP at Lv5 with bounds 50-75 → 1/25)
    final p = inLevelProgress(_xp, _level);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Off-white box around the plant (same vibe as the Stats pie box)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: cs.surfaceContainerHighest.withOpacity(0.25),
            borderRadius: BorderRadius.circular(24),
          ),
          child: AspectRatio(
            aspectRatio: 1.2,
            child: Lottie.asset(
              asset,
              controller: _controller,
              repeat: false,
              onLoaded: (composition) {
                _controller.duration = composition.duration;
                if (_shouldPlayOnceNow) {
                  _playOnceThenFreeze();
                } else {
                  _controller.value = 1; // keep last frame
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Centered: "Level X · {Stage}"
        Center(
          child: Text(
            'Level $_level · ${stageLabel(_stage)}',
            style: KTextStyle.header1Text.copyWith(color: cs.onSurface),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 6),

        // Centered: "{got} / {total} EXP" (progress within the current level)
        // Global EXP text: "current XP / next-level cap", or "MAX" at top level
        Center(
          child: Text(
            expText,
            style: KTextStyle.header2Text.copyWith(
              // ignore: deprecated_member_use
              color: cs.onSurface.withOpacity(0.85),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),

        // Animated progress bar for *in-level* progress
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: p.ratio),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              minHeight: 10,
              color: cs.primary,
              // ignore: deprecated_member_use
              backgroundColor: cs.surfaceContainerHighest.withOpacity(0.5),
            ),
          ),
        ),
      ],
    );
  }
}
