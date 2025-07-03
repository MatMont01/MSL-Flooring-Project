// lib/features/notification/domain/repositories/notification_repository.dart

import '../entities/document_entity.dart';
import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  // Contrato para obtener una lista de todas las notificaciones.
  Future<List<NotificationEntity>> getAllNotifications();

  // Contrato para obtener una lista de todos los documentos.
  Future<List<DocumentEntity>> getAllDocuments();
}
