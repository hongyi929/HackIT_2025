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
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final _service = PlantService();

  int _xp = 0;
  int _level = 0;
  int _stage = 1;

  int _seenLevel = 0;
  int _seenStage = 1;

  // play-once logic
  bool _shouldPlayOnceNow = true;
  bool _isLottieReady = false; // composition loaded?
  bool _askedToPlay = false; // we want to play when ready

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
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
      _shouldPlayOnceNow = true;
    });

    if (_level > _seenLevel) {
      final stageChanged = _stage > _seenStage;
      await _showLevelUpDialog(level: _level, stageChanged: stageChanged);
    }

    // ask to play; actual start will wait until Lottie is ready
    _askedToPlay = true;
    _maybePlay();

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

  // Start the one-shot playback ONLY when we have a duration.
  void _maybePlay() {
    if (!mounted) return;
    if (!_askedToPlay || !_isLottieReady) return;

    _askedToPlay = false; // consume the request
    _controller
      ..stop()
      ..reset();

    _controller.forward().whenComplete(() {
      if (!mounted) return;
      _controller.value = 1; // freeze on last frame
      setState(() => _shouldPlayOnceNow = false);
    });
  }

  bool _didInitialLoad = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInitialLoad) {
      _didInitialLoad = true;
      _loadAndMaybeCelebrate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final asset = lottieAssetForStage(_stage);
    final cap = nextLevelCap(_level);
    final expText = cap == null ? '$_xp EXP (MAX)' : '$_xp / $cap EXP';
    final p = inLevelProgress(_xp, _level);
    // debug: see what’s being used
    debugPrint('PlantPanel → xp=$_xp level=$_level stage=$_stage asset=$asset');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // off-white card around the plant
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
              key: ValueKey(
                asset,
              ), // <-- forces a new composition when path changes
              controller: _controller,
              repeat: false,
              options: LottieOptions(enableMergePaths: true),
              onLoaded: (composition) {
                _controller
                  ..duration = composition.duration
                  ..stop()
                  ..value = 0.0;

                // Choose where to freeze on the timeline for each stage.
                // Tweak these if your exported files differ.
                double _freezeProgressForStage(int stage) {
                  switch (stage) {
                    case 1:
                      return 1.0; // ends at the seed — fine
                    case 2:
                      return 0.60; // ~60% looks "young"
                    case 3:
                      return 0.70; // ~70% looks "bloom"
                    case 4:
                      return 0.78; // ~78% looks "mature"
                    case 5:
                      return 0.85; // more growth
                    default:
                      return 0.75;
                  }
                }

                final target = _freezeProgressForStage(_stage).clamp(0.0, 1.0);
                // Play once up to the 'target' frame, then hold there.
                _controller.animateTo(
                  target,
                  duration: _controller.duration! * target,
                  curve: Curves.easeOutCubic,
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),

        Center(
          child: Text(
            'Level $_level · ${stageLabel(_stage)}',
            style: KTextStyle.header1Text.copyWith(color: cs.onSurface),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 6),

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
