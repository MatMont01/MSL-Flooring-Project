// lib/features/notification/domain/entities/notification_entity.dart

class NotificationEntity {
  final String id;
  final String? targetWorkerId; // Puede ser nulo
  final String? targetRole; // Puede ser nulo
  final String? title;
  final String? message;
  final String? type;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    this.targetWorkerId,
    this.targetRole,
    this.title,
    this.message,
    this.type,
    required this.createdAt,
  });
}
