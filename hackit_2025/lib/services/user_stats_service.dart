import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserStatsService {
  UserStatsService._();
  static final I = UserStatsService._();

  DocumentReference<Map<String, dynamic>> _userRef() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance.collection('users').doc(uid);
  }

  Future<void> _ensureUserDoc() async {
    final ref = _userRef();
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({'xp': 0, 'studySecondsTotal': 0}, SetOptions(merge: true));
    }
  }

  Future<void> incrementXp(int delta) async {
    await _ensureUserDoc();
    await _userRef().set({
      'xp': FieldValue.increment(delta),
    }, SetOptions(merge: true));
  }

  Future<void> incrementStudySeconds(int delta) async {
    if (delta <= 0) return;
    await _ensureUserDoc();
    await _userRef().set({
      'studySecondsTotal': FieldValue.increment(delta),
    }, SetOptions(merge: true));
  }

  Future<int> getXp() async {
    final snap = await _userRef().get();
    return (snap.data()?['xp'] as int?) ?? 0;
  }

  Future<Duration> getStudyTotal() async {
    final snap = await _userRef().get();
    final secs = (snap.data()?['studySecondsTotal'] as int?) ?? 0;
    return Duration(seconds: secs);
  }
}
