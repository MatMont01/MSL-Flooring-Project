// lib/features/notification/data/datasources/notification_remote_data_source.dart

import '../../../../core/api/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/document_model.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getAllNotifications();

  Future<List<DocumentModel>> getAllDocuments();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiClient _apiClient;

  NotificationRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<NotificationModel>> getAllNotifications() async {
    final response = await _apiClient.get(
      ApiConstants.notificationServiceBaseUrl,
      '/notifications', // Endpoint para obtener notificaciones
    );

    final List<dynamic> notificationListJson = response;
    return notificationListJson
        .map((json) => NotificationModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<DocumentModel>> getAllDocuments() async {
    final response = await _apiClient.get(
      ApiConstants.notificationServiceBaseUrl,
      '/documents', // Endpoint para obtener documentos
    );

    final List<dynamic> documentListJson = response;
    return documentListJson
        .map((json) => DocumentModel.fromJson(json))
        .toList();
  }
}
