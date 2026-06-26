import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import '../firebase/config.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseConfig.db;
  final String _collection = 'users';

  Future<UserProfile?> getUser(String uid) async {
    final doc = await _db.collection(_collection).doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromFirestore(doc.data()!, doc.id);
  }

  Future<void> createUser(String uid, Map<String, dynamic> data) async {
    await _db.collection(_collection).doc(uid).set({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection(_collection).doc(uid).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
