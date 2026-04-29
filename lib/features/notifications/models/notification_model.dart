import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType { info, warning, emergency }

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final String? target;
  final Timestamp createdAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.target,
    required this.createdAt,
    this.isRead = false,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    String? target,
    Timestamp? createdAt,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      target: target ?? this.target,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.name,
      'target': target,
      'createdAt': createdAt,
      'isRead': isRead,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      title: (map['title'] ?? '').toString(),
      message: (map['message'] ?? '').toString(),
      type: NotificationType.values.firstWhere(
        (e) => e.name == map['type']?.toString(),
        orElse: () => NotificationType.info,
      ),
      target: map['target']?.toString(),
      createdAt: map['createdAt'] is Timestamp 
          ? map['createdAt'] 
          : Timestamp.now(),
      isRead: map['isRead'] == true, // Handle bool safely
    );
  }
}
