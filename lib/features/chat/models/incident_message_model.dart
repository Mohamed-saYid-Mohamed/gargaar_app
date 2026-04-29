import 'package:cloud_firestore/cloud_firestore.dart';

class IncidentMessageModel {
  final String id;
  final String incidentId;
  final String senderId;
  final String senderRole; // 'user' or 'admin'
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final List<String>? attachments;
  final String messageType; // 'text', 'image', 'voice'

  IncidentMessageModel({
    required this.id,
    required this.incidentId,
    required this.senderId,
    required this.senderRole,
    required this.message,
    required this.createdAt,
    this.isRead = false,
    this.attachments,
    this.messageType = 'text',
  });

  factory IncidentMessageModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return IncidentMessageModel(
      id: doc.id,
      incidentId: data['incidentId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderRole: data['senderRole'] ?? 'user',
      message: data['message'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
      attachments: data['attachments'] != null ? List<String>.from(data['attachments']) : null,
      messageType: data['messageType'] ?? 'text',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'incidentId': incidentId,
      'senderId': senderId,
      'senderRole': senderRole,
      'message': message,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
      'attachments': attachments,
      'messageType': messageType,
    };
  }

  bool get isAdmin => senderRole == 'admin';
  bool get isUser => senderRole == 'user';
}
