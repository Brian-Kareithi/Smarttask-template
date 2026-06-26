import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';
import '../firebase/config.dart';

class TaskService {
  final FirebaseFirestore _db = FirebaseConfig.db;
  final String _collection = 'tasks';

  Stream<List<Task>> streamTasks(String userId) {
    return _db
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Task.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  Future<String> createTask(Task task) async {
    final docRef = await _db.collection(_collection).add({
      ...task.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Future<void> updateTask(String id, Map<String, dynamic> data) async {
    await _db.collection(_collection).doc(id).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteTask(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }

  Future<void> addCollaborator(String taskId, String email) async {
    final userQuery = await _db
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (userQuery.docs.isEmpty) {
      throw Exception('User not found');
    }

    final uid = userQuery.docs.first.id;
    await _db.collection(_collection).doc(taskId).update({
      'collaborators': FieldValue.arrayUnion([uid]),
    });
  }

  Future<void> removeCollaborator(String taskId, String uid) async {
    await _db.collection(_collection).doc(taskId).update({
      'collaborators': FieldValue.arrayRemove([uid]),
    });
  }
}
