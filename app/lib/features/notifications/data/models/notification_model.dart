import '../../domain/entities/notification.dart';

class NotificationModel extends Notification {
  const NotificationModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.title,
    required super.message,
    super.data,
    required super.read,
    required super.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      userId: json['user_id'],
      type: json['type'],
      title: json['title'],
      message: json['message'],
      data: json['data'],
      read: json['read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'title': title,
      'message': message,
      'data': data,
      'read': read,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
