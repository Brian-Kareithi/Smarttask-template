import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/stats.dart';
import '../firebase/config.dart';

class StatsService {
  final FirebaseFirestore _db = FirebaseConfig.db;
  final String _collection = 'stats';

  Stream<Stats> streamStats(String uid) {
    return _db.collection(_collection).doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) return Stats();
      return Stats.fromFirestore(snapshot.data()!);
    });
  }

  Future<void> updateStats(String uid, Map<String, dynamic> data) async {
    await _db.collection(_collection).doc(uid).set({
      ...data,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> createDefaults(String uid) async {
    await _db.collection(_collection).doc(uid).set(Stats().toMap());
  }
}
