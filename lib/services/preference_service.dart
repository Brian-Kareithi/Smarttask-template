import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/preferences.dart';
import '../firebase/config.dart';

class PreferenceService {
  final FirebaseFirestore _db = FirebaseConfig.db;
  final String _collection = 'preferences';

  Stream<Preferences> streamPreferences(String uid) {
    return _db.collection(_collection).doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) return Preferences();
      return Preferences.fromFirestore(snapshot.data()!);
    });
  }

  Future<void> setPreference(String uid, String key, dynamic value) async {
    await _db.collection(_collection).doc(uid).set({
      key: value,
    }, SetOptions(merge: true));
  }

  Future<void> createDefaults(String uid) async {
    await _db.collection(_collection).doc(uid).set(Preferences().toMap());
  }
}
