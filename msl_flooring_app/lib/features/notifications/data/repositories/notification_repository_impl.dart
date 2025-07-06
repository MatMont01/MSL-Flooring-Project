// lib/features/notification/data/repositories/notification_repository_impl.dart

import '../../../../core/error/failure.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<NotificationEntity>> getAllNotifications() async {
    try {
      return await remoteDataSource.getAllNotifications();
    } on Failure {
      // Si el error ya es una Falla conocida, la relanzamos.
      rethrow;
    } catch (e) {
      // Para cualquier otro error, lo envolvemos en una Falla genérica.
      throw const ServerFailure(
        'Ocurrió un error inesperado al obtener las notificaciones.',
      );
    }
  }

  @override
  Future<List<DocumentEntity>> getAllDocuments() async {
    try {
      return await remoteDataSource.getAllDocuments();
    } on Failure {
      rethrow;
    } catch (e) {
      throw const ServerFailure(
        'Ocurrió un error inesperado al obtener los documentos.',
      );
    }
  }
}
