import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/incident_message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Watch messages for a specific incident in real-time
  Stream<List<IncidentMessageModel>> watchMessages(String incidentId) {
    return _firestore
        .collection('incident_chats')
        .doc(incidentId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => IncidentMessageModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Send a message to the incident chat
  Future<void> sendMessage({
    required String incidentId,
    required String senderId,
    required String senderRole,
    required String message,
  }) async {
    final messageData = IncidentMessageModel(
      id: '', // Firestore will generate this
      incidentId: incidentId,
      senderId: senderId,
      senderRole: senderRole,
      message: message,
      createdAt: DateTime.now(),
      isRead: false,
    );

    await _firestore
        .collection('incident_chats')
        .doc(incidentId)
        .collection('messages')
        .add(messageData.toFirestore());

    // Update the last message or metadata in the main incident_chats document if needed
    await _firestore.collection('incident_chats').doc(incidentId).set({
      'lastMessage': message,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'incidentId': incidentId,
    }, SetOptions(merge: true));
  }

  /// Mark messages as read for an incident
  Future<void> markMessagesAsRead(String incidentId, String role) async {
    // Only mark messages from the OTHER role as read
    final otherRole = role == 'user' ? 'admin' : 'user';
    
    final querySnapshot = await _firestore
        .collection('incident_chats')
        .doc(incidentId)
        .collection('messages')
        .where('senderRole', isEqualTo: otherRole)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (var doc in querySnapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    
    if (querySnapshot.docs.isNotEmpty) {
      await batch.commit();
    }
  }
}
