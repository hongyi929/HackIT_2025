import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple in-memory + SharedPrefs session state so the timers survive app
/// background/foreground. Firestore is used only for task flags.
enum SessionMode { working, resting }

class WorkSessionSnapshot {
  final String title;
  final String description;
  final int startedAtMs;
  final int workMs;
  final int restMs;
  final SessionMode mode;
  final int lastModeStartMs;
  WorkSessionSnapshot({
    required this.title,
    required this.description,
    required this.startedAtMs,
    required this.workMs,
    required this.restMs,
    required this.mode,
    required this.lastModeStartMs,
  });

  Map<String, Object> toJson() => {
    'title': title,
    'description': description,
    'startedAtMs': startedAtMs,
    'workMs': workMs,
    'restMs': restMs,
    'mode': mode.name,
    'lastModeStartMs': lastModeStartMs,
  };

  static WorkSessionSnapshot fromJson(Map<String, Object?> j) =>
      WorkSessionSnapshot(
        title: (j['title'] ?? '') as String,
        description: (j['description'] ?? '') as String,
        startedAtMs: (j['startedAtMs'] ?? 0) as int,
        workMs: (j['workMs'] ?? 0) as int,
        restMs: (j['restMs'] ?? 0) as int,
        mode: ((j['mode'] ?? 'working') as String) == 'resting'
            ? SessionMode.resting
            : SessionMode.working,
        lastModeStartMs: (j['lastModeStartMs'] ?? 0) as int,
      );
}

class WorkSessionService {
  static const _prefsKey = 'ws.active.v1';

  WorkSessionSnapshot? _snap;

  WorkSessionSnapshot? get snap => _snap;

  static final WorkSessionService I = WorkSessionService._();
  WorkSessionService._();

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    if (_snap == null) {
      await prefs.remove(_prefsKey);
      return;
    }
    await prefs.setString(_prefsKey, _snap!.toJson().toString());
  }

  Future<void> _loadFromPrefsIfAny() async {
    if (_snap != null) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return;
    // very small map -> parse safely
    final map = <String, Object?>{};
    for (final part in raw.substring(1, raw.length - 1).split(', ')) {
      final eq = part.indexOf(': ');
      if (eq <= 0) continue;
      final k = part.substring(0, eq);
      final v = part.substring(eq + 2);
      map[k] = v == 'null'
          ? null
          : (int.tryParse(v) ?? (v == 'working' || v == 'resting' ? v : v));
    }
    _snap = WorkSessionSnapshot.fromJson(map);
  }

  /// Called from the editor's "Create Session".
  /// 1) seeds all incomplete tasks with `semicomplete=false`
  /// 2) creates local running timers (persisted to SharedPrefs)
  Future<void> start({
    required String title,
    required String description,
    required String uid,
  }) async {
    // 1) tag all user's incomplete tasks with semicomplete=false
    final q = await FirebaseFirestore.instance
        .collection('tasks')
        .where('user', isEqualTo: uid)
        .where('completed', isEqualTo: false)
        .get();

    // write in batches (safe for 500+ tasks)
    WriteBatch? batch;
    int count = 0;
    void commitIfNeeded() async {
      if (batch != null && count >= 450) {
        await batch!.commit();
        batch = null;
        count = 0;
      }
    }

    for (final d in q.docs) {
      batch ??= FirebaseFirestore.instance.batch();
      batch!.update(d.reference, {'semicomplete': false});
      count++;
      commitIfNeeded();
    }
    if (batch != null) await batch!.commit();

    // 2) make a fresh local session
    final now = DateTime.now().millisecondsSinceEpoch;
    _snap = WorkSessionSnapshot(
      title: title,
      description: description,
      startedAtMs: now,
      workMs: 0,
      restMs: 0,
      mode: SessionMode.working,
      lastModeStartMs: now,
    );
    await _save();
  }

  /// Restore if the app was killed/backgrounded.
  Future<bool> ensureLoaded() async {
    if (_snap != null) return true;
    await _loadFromPrefsIfAny();
    return _snap != null;
  }

  /// Tick (calculate “now” work/rest dur) without storing every second.
  (Duration work, Duration rest, SessionMode mode) now() {
    if (_snap == null)
      return (Duration.zero, Duration.zero, SessionMode.working);
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    var work = _snap!.workMs;
    var rest = _snap!.restMs;
    final delta = nowMs - _snap!.lastModeStartMs;
    if (_snap!.mode == SessionMode.working) {
      work += delta;
    } else {
      rest += delta;
    }
    return (
      Duration(milliseconds: work),
      Duration(milliseconds: rest),
      _snap!.mode,
    );
  }

  Future<void> toggleMode() async {
    if (_snap == null) return;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final delta = nowMs - _snap!.lastModeStartMs;
    if (_snap!.mode == SessionMode.working) {
      _snap = WorkSessionSnapshot(
        title: _snap!.title,
        description: _snap!.description,
        startedAtMs: _snap!.startedAtMs,
        workMs: _snap!.workMs + delta,
        restMs: _snap!.restMs,
        mode: SessionMode.resting,
        lastModeStartMs: nowMs,
      );
    } else {
      _snap = WorkSessionSnapshot(
        title: _snap!.title,
        description: _snap!.description,
        startedAtMs: _snap!.startedAtMs,
        workMs: _snap!.workMs,
        restMs: _snap!.restMs + delta,
        mode: SessionMode.working,
        lastModeStartMs: nowMs,
      );
    }
    await _save();
  }

  /// Finalize counters right now (no DB mutations of tasks).
  Future<WorkSessionSnapshot?> stopAndFreeze() async {
    if (_snap == null) return null;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final delta = nowMs - _snap!.lastModeStartMs;
    _snap = _snap!.mode == SessionMode.working
        ? WorkSessionSnapshot(
            title: _snap!.title,
            description: _snap!.description,
            startedAtMs: _snap!.startedAtMs,
            workMs: _snap!.workMs + delta,
            restMs: _snap!.restMs,
            mode: _snap!.mode,
            lastModeStartMs: nowMs,
          )
        : WorkSessionSnapshot(
            title: _snap!.title,
            description: _snap!.description,
            startedAtMs: _snap!.startedAtMs,
            workMs: _snap!.workMs,
            restMs: _snap!.restMs + delta,
            mode: _snap!.mode,
            lastModeStartMs: nowMs,
          );
    await _save();
    return _snap;
  }

  /// Called on “Continue” in the results page: mark all semicomplete as
  /// completed=true and clear the semicomplete flags on the rest.
  Future<void> applyResultsAndClearFlags() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final col = FirebaseFirestore.instance.collection('tasks');

    final done = await col
        .where('user', isEqualTo: uid)
        .where('semicomplete', isEqualTo: true)
        .get();

    final notDone = await col
        .where('user', isEqualTo: uid)
        .where('semicomplete', isEqualTo: false)
        .get();

    // Two batches to avoid limits.
    final b1 = FirebaseFirestore.instance.batch();
    for (final d in done.docs) {
      b1.update(d.reference, {
        'completed': true,
        'semicomplete': FieldValue.delete(),
      });
    }
    await b1.commit();

    final b2 = FirebaseFirestore.instance.batch();
    for (final d in notDone.docs) {
      b2.update(d.reference, {'semicomplete': FieldValue.delete()});
    }
    await b2.commit();

    // Clear local session.
    _snap = null;
    await _save();
  }
}
