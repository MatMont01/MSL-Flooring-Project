// lib/features/documents/domain/repositories/document_repository.dart

import 'dart:io';
import '../entities/document_entity.dart';
import '../entities/document_permission_entity.dart';

abstract class DocumentRepository {
  Future<DocumentEntity> uploadDocument({
    required String filename,
    required File file,
    required String uploadedBy,
    String? projectId,
  });

  Future<List<DocumentEntity>> getAllDocuments();

  Future<List<DocumentEntity>> getDocumentsByProject(String projectId);

  Future<DocumentEntity> getDocumentById(String documentId);

  Future<void> deleteDocument(String documentId);

  Future<File> downloadDocument(String documentId);

  // Gestión de permisos
  Future<DocumentPermissionEntity> grantPermission({
    required String documentId,
    required String workerId,
    required bool canView,
  });

  Future<List<DocumentPermissionEntity>> getPermissionsByDocument(
    String documentId,
  );

  Future<List<DocumentPermissionEntity>> getPermissionsByWorker(
    String workerId,
  );

  Future<bool> canWorkerViewDocument(String documentId, String workerId);

  Future<void> revokePermissionsByDocument(String documentId);

  Future<void> revokePermissionsByWorker(String workerId);
}
