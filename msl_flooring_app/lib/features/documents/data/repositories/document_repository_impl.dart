// lib/features/documents/data/repositories/document_repository_impl.dart

import 'dart:io';
import '../../../../core/error/failure.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/entities/document_permission_entity.dart';
import '../../domain/repositories/document_repository.dart';
import '../datasources/document_remote_data_source.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final DocumentRemoteDataSource remoteDataSource;

  DocumentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<DocumentEntity> uploadDocument({
    required String filename,
    required File file,
    required String uploadedBy,
    String? projectId,
  }) async {
    try {
      return await remoteDataSource.uploadDocument(
        filename: filename,
        file: file,
        uploadedBy: uploadedBy,
        projectId: projectId,
      );
    } on Failure {
      rethrow;
    } catch (e) {
      throw const ServerFailure('Error inesperado al subir el documento.');
    }
  }

  @override
  Future<List<DocumentEntity>> getAllDocuments() async {
    try {
      return await remoteDataSource.getAllDocuments();
    } on Failure {
      rethrow;
    } catch (e) {
      throw const ServerFailure('Error inesperado al obtener los documentos.');
    }
  }

  @override
  Future<List<DocumentEntity>> getDocumentsByProject(String projectId) async {
    try {
      return await remoteDataSource.getDocumentsByProject(projectId);
    } on Failure {
      rethrow;
    } catch (e) {
      throw const ServerFailure(
        'Error inesperado al obtener los documentos del proyecto.',
      );
    }
  }

  @override
  Future<DocumentEntity> getDocumentById(String documentId) async {
    try {
      return await remoteDataSource.getDocumentById(documentId);
    } on Failure {
      rethrow;
    } catch (e) {
      throw const ServerFailure('Error inesperado al obtener el documento.');
    }
  }

  @override
  Future<void> deleteDocument(String documentId) async {
    try {
      await remoteDataSource.deleteDocument(documentId);
    } on Failure {
      rethrow;
    } catch (e) {
      throw const ServerFailure('Error inesperado al eliminar el documento.');
    }
  }

  @override
  Future<File> downloadDocument(String documentId) async {
    try {
      return await remoteDataSource.downloadDocument(documentId);
    } on Failure {
      rethrow;
    } catch (e) {
      throw const ServerFailure('Error inesperado al descargar el documento.');
    }
  }

  @override
  Future<DocumentPermissionEntity> grantPermission({
    required String documentId,
    required String workerId,
    required bool canView,
  }) async {
    try {
      return await remoteDataSource.grantPermission(
        documentId: documentId,
        workerId: workerId,
        canView: canView,
      );
    } on Failure {
      rethrow;
    } catch (e) {
      throw const ServerFailure('Error inesperado al otorgar permiso.');
    }
  }

  @override
  Future<List<DocumentPermissionEntity>> getPermissionsByDocument(
    String documentId,
  ) async {
    try {
      return await remoteDataSource.getPermissionsByDocument(documentId);
    } on Failure {
      rethrow;
    } catch (e) {
      throw const ServerFailure(
        'Error inesperado al obtener permisos del documento.',
      );
    }
  }

  @override
  Future<List<DocumentPermissionEntity>> getPermissionsByWorker(
    String workerId,
  ) async {
    try {
      return await remoteDataSource.getPermissionsByWorker(workerId);
    } on Failure {
      rethrow;
    } catch (e) {
      throw const ServerFailure(
        'Error inesperado al obtener permisos del trabajador.',
      );
    }
  }

  @override
  Future<bool> canWorkerViewDocument(String documentId, String workerId) async {
    try {
      return await remoteDataSource.canWorkerViewDocument(documentId, workerId);
    } on Failure {
      rethrow;
    } catch (e) {
      throw const ServerFailure('Error inesperado al verificar permisos.');
    }
  }

  @override
  Future<void> revokePermissionsByDocument(String documentId) async {
    try {
      await remoteDataSource.revokePermissionsByDocument(documentId);
    } on Failure {
      rethrow;
    } catch (e) {
      throw const ServerFailure('Error inesperado al revocar permisos.');
    }
  }

  @override
  Future<void> revokePermissionsByWorker(String workerId) async {
    try {
      await remoteDataSource.revokePermissionsByWorker(workerId);
    } on Failure {
      rethrow;
    } catch (e) {
      throw const ServerFailure('Error inesperado al revocar permisos.');
    }
  }
}
