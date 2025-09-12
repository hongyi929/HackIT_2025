import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// Level thresholds for Lv0..Lv10 (inclusive lower-bounds).
/// Example: XP >= 20 → at least level 2; XP >= 300 → level 10.
const List<int> _levelThresholds = [
  0, // Lv0
  10, // Lv1
  20, // Lv2
  35, // Lv3
  50, // Lv4
  75, // Lv5
  100, // Lv6
  140, // Lv7
  180, // Lv8
  240, // Lv9
  300, // Lv10 (max)
];

int levelFromXp(int xp) {
  int lvl = 0;
  for (var i = 0; i < _levelThresholds.length; i++) {
    if (xp >= _levelThresholds[i]) lvl = i;
  }
  return lvl.clamp(0, 10);
}

int stageFromLevel(int level) {
  if (level <= 2) return 1; // seed
  if (level <= 4) return 2; // young
  if (level <= 6) return 3; // bloom
  if (level <= 8) return 4; // mature
  return 5; // final
}

// Pretty label for the stage bucket shown next to the level.
String stageLabel(int stage) {
  switch (stage) {
    case 1:
      return 'Seed';
    case 2:
      return 'Young';
    case 3:
      return 'Bloom';
    case 4:
    case 5:
      return 'Mature'; // stage 4 & 5 both "Mature" in the UI
    default:
      return 'Seed';
  }
}

// Returns the XP "cap" required to reach the next level.
// If already at max, returns null.
int? nextLevelCap(int level) {
  final lastIndex = _levelThresholds.length - 1; // = 10
  if (level >= lastIndex) return null; // already at max (Lv10)
  return _levelThresholds[level + 1];
}

// Convenience: are we at the max level?
bool isMaxLevel(int level) => nextLevelCap(level) == null;

// Lower/upper XP bounds for a given level.
// end == null when already at max level (no next cap).
({int start, int? end}) levelBounds(int level) {
  final idx = level.clamp(0, _levelThresholds.length - 1);
  final start = _levelThresholds[idx];
  final end = (idx + 1 < _levelThresholds.length)
      ? _levelThresholds[idx + 1]
      : null;
  return (start: start, end: end);
}

// Progress inside the *current* level window.
// - got:  how much XP earned inside this level
// - total: total XP width of this level window
// - ratio: got/total (1.0 at max level)
({int got, int total, double ratio}) inLevelProgress(int xp, int level) {
  final b = levelBounds(level);
  final base = b.start;
  final cap = b.end;

  final got = (xp - base) < 0 ? 0 : (xp - base);
  final total = cap == null ? 1 : (cap - base);
  final ratio = cap == null ? 1.0 : (got / total).clamp(0.0, 1.0);

  return (got: got, total: total, ratio: ratio);
}

String lottieAssetForStage(int stage) => switch (stage) {
  1 => 'assets/lotties/plant_stage1.json',
  2 => 'assets/lotties/plant_stage2.json',
  3 => 'assets/lotties/plant_stage3.json',
  4 => 'assets/lotties/plant_stage4.json',
  _ => 'assets/lotties/plant_stage5.json',
};

@immutable
class PlantProgress {
  final int xp;
  final int level;
  final int stage;
  const PlantProgress({
    required this.xp,
    required this.level,
    required this.stage,
  });
}

class PlantService {
  /// TODO: replace with your real source of truth (Firestore/local).
  Future<int> getCurrentXp() async {
    // For now return a stable demo XP. Replace this with your data.
    return 300;
  }

  Future<PlantProgress> load() async {
    final xp = await getCurrentXp();
    final level = levelFromXp(xp);
    final stage = stageFromLevel(level);
    return PlantProgress(xp: xp, level: level, stage: stage);
  }
}
