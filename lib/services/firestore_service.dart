import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createSession(String title) async {
    final sessionId = const Uuid().v4();

    await _firestore.collection('sessions').doc(sessionId).set({
      'createdAt': FieldValue.serverTimestamp(),
      'title': title,
    });

    return sessionId;
  }

  Stream<List<QueryDocumentSnapshot>> getMessagesForSession(String sessionId) {
    return _firestore
        .collection('chats')
        .where('sessionId', isEqualTo: sessionId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  Future<void> saveMessage({
    required String content,
    required String role,
    required String sessionId,
  }) async {
    await _firestore.collection('chats').add({
      'content': content,
      'role': role,
      'timestamp': FieldValue.serverTimestamp(),
      'sessionId': sessionId,
    });
  }

  Future<void> deleteSession(String sessionId) async {
    await _firestore.collection('sessions').doc(sessionId).delete();

    final chats = await _firestore
        .collection('chats')
        .where('sessionId', isEqualTo: sessionId)
        .get();

    for (var chat in chats.docs) {
      await _firestore.collection('chats').doc(chat.id).delete();
    }
  }

  Stream<Map<String, List<QueryDocumentSnapshot>>> getGroupedSessionsStream() {
    return _firestore.collection('sessions').orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      final now = DateTime.now();
      final groupedSessions = <String, List<QueryDocumentSnapshot>>{};

      for (var doc in snapshot.docs) {
        final sessionDate = (doc['createdAt'] as Timestamp?)?.toDate();
        if (sessionDate == null) continue;

        final difference = now.difference(sessionDate);
        final key = difference.inDays == 0
            ? 'Today'
            : difference.inDays <= 7
                ? 'Last 7 Days'
                : 'Earlier';

        groupedSessions.putIfAbsent(key, () => []).add(doc);
      }

      return groupedSessions;
    });
  }
}
