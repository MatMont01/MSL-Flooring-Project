// lib/features/documents/data/datasources/document_remote_data_source.dart

import 'dart:io';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/document_model.dart';
import '../models/document_permission_model.dart';

abstract class DocumentRemoteDataSource {
  Future<DocumentModel> uploadDocument({
    required String filename,
    required File file,
    required String uploadedBy,
    String? projectId,
  });

  Future<List<DocumentModel>> getAllDocuments();

  Future<List<DocumentModel>> getDocumentsByProject(String projectId);

  Future<DocumentModel> getDocumentById(String documentId);

  Future<void> deleteDocument(String documentId);

  Future<File> downloadDocument(String documentId);

  // Permisos
  Future<DocumentPermissionModel> grantPermission({
    required String documentId,
    required String workerId,
    required bool canView,
  });

  Future<List<DocumentPermissionModel>> getPermissionsByDocument(
    String documentId,
  );

  Future<List<DocumentPermissionModel>> getPermissionsByWorker(String workerId);

  Future<bool> canWorkerViewDocument(String documentId, String workerId);

  Future<void> revokePermissionsByDocument(String documentId);

  Future<void> revokePermissionsByWorker(String workerId);
}

class DocumentRemoteDataSourceImpl implements DocumentRemoteDataSource {
  final ApiClient _apiClient;

  DocumentRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<DocumentModel> uploadDocument({
    required String filename,
    required File file,
    required String uploadedBy,
    String? projectId,
  }) async {
    print('📁 [DocumentDataSource] Uploading file: $filename');

    try {
      // 🔧 USAR EL NUEVO MÉTODO uploadFile DEL ApiClient
      final fields = <String, String>{
        'filename': filename,
        'uploadedBy': uploadedBy,
      };

      if (projectId != null) {
        fields['projectId'] = projectId;
      }

      final response = await _apiClient.uploadFile(
        baseUrl: ApiConstants.notificationServiceBaseUrl,
        endpoint: '/documents/upload',
        file: file,
        filename: filename,
        fields: fields,
        fileFieldName: 'file',
      );

      print('📁 [DocumentDataSource] Upload successful');
      return DocumentModel.fromJson(response);
    } catch (e) {
      print('🔴 [DocumentDataSource] Upload failed: $e');
      rethrow;
    }
  }

  @override
  Future<List<DocumentModel>> getAllDocuments() async {
    print('📁 [DocumentDataSource] Fetching all documents');
    final response = await _apiClient.get(
      ApiConstants.notificationServiceBaseUrl,
      '/documents',
    );
    final List<dynamic> documentsJson = response;
    return documentsJson.map((json) => DocumentModel.fromJson(json)).toList();
  }

  @override
  Future<List<DocumentModel>> getDocumentsByProject(String projectId) async {
    print('📁 [DocumentDataSource] Fetching documents for project: $projectId');
    final response = await _apiClient.get(
      ApiConstants.notificationServiceBaseUrl,
      '/documents/project/$projectId',
    );
    final List<dynamic> documentsJson = response;
    return documentsJson.map((json) => DocumentModel.fromJson(json)).toList();
  }

  @override
  Future<DocumentModel> getDocumentById(String documentId) async {
    final response = await _apiClient.get(
      ApiConstants.notificationServiceBaseUrl,
      '/documents/$documentId',
    );
    return DocumentModel.fromJson(response);
  }

  @override
  Future<void> deleteDocument(String documentId) async {
    print('📁 [DocumentDataSource] Deleting document: $documentId');
    await _apiClient.delete(
      ApiConstants.notificationServiceBaseUrl,
      '/documents/$documentId',
    );
  }

  @override
  Future<File> downloadDocument(String documentId) async {
    print('📁 [DocumentDataSource] Downloading document: $documentId');
    throw UnimplementedError('Download functionality needs implementation');
  }

  // --- MÉTODOS DE PERMISOS ---

  @override
  Future<DocumentPermissionModel> grantPermission({
    required String documentId,
    required String workerId,
    required bool canView,
  }) async {
    print(
      '🔐 [DocumentDataSource] Granting permission - Document: $documentId, Worker: $workerId',
    );
    final body = {
      'documentId': documentId,
      'workerId': workerId,
      'canView': canView,
    };
    final response = await _apiClient.post(
      ApiConstants.notificationServiceBaseUrl,
      '/document-permissions',
      body,
    );
    return DocumentPermissionModel.fromJson(response);
  }

  @override
  Future<List<DocumentPermissionModel>> getPermissionsByDocument(
    String documentId,
  ) async {
    final response = await _apiClient.get(
      ApiConstants.notificationServiceBaseUrl,
      '/document-permissions/document/$documentId',
    );
    final List<dynamic> permissionsJson = response;
    return permissionsJson
        .map((json) => DocumentPermissionModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<DocumentPermissionModel>> getPermissionsByWorker(
    String workerId,
  ) async {
    final response = await _apiClient.get(
      ApiConstants.notificationServiceBaseUrl,
      '/document-permissions/worker/$workerId',
    );
    final List<dynamic> permissionsJson = response;
    return permissionsJson
        .map((json) => DocumentPermissionModel.fromJson(json))
        .toList();
  }

  @override
  Future<bool> canWorkerViewDocument(String documentId, String workerId) async {
    final response = await _apiClient.get(
      ApiConstants.notificationServiceBaseUrl,
      '/document-permissions/check?documentId=$documentId&workerId=$workerId',
    );
    return response as bool;
  }

  @override
  Future<void> revokePermissionsByDocument(String documentId) async {
    await _apiClient.delete(
      ApiConstants.notificationServiceBaseUrl,
      '/document-permissions/document/$documentId',
    );
  }

  @override
  Future<void> revokePermissionsByWorker(String workerId) async {
    await _apiClient.delete(
      ApiConstants.notificationServiceBaseUrl,
      '/document-permissions/worker/$workerId',
    );
  }
}
