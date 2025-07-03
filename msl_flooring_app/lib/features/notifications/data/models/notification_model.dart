// lib/features/notification/data/models/notification_model.dart

import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    super.targetWorkerId,
    super.targetRole,
    super.title,
    super.message,
    super.type,
    required super.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      targetWorkerId: json['targetWorkerId'],
      targetRole: json['targetRole'],
      title: json['title'],
      message: json['message'],
      type: json['type'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
