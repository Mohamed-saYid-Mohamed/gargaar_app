import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String incidentId;
  final String senderId;
  final String senderName;
  final String text;
  final Timestamp createdAt;
  final bool isAdmin;

  ChatMessage({
    required this.id,
    required this.incidentId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.createdAt,
    this.isAdmin = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'incidentId': incidentId,
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'createdAt': createdAt,
      'isAdmin': isAdmin,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map, String id) {
    return ChatMessage(
      id: id,
      incidentId: map['incidentId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      text: map['text'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      isAdmin: map['isAdmin'] ?? false,
    );
  }
}
