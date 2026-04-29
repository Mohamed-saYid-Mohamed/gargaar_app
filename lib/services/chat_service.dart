import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/incidents/models/chat_message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ChatMessage>> getMessages(String incidentId) {
    return _firestore
        .collection('incident_messages')
        .where('incidentId', isEqualTo: incidentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> sendMessage({
    required String incidentId,
    required String senderId,
    required String senderName,
    required String text,
    bool isAdmin = false,
  }) async {
    await _firestore.collection('incident_messages').add({
      'incidentId': incidentId,
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
      'isAdmin': isAdmin,
    });
  }
}
