// lib/features/documents/presentation/providers/document_providers.dart

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/document_remote_data_source.dart';
import '../../data/repositories/document_repository_impl.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/entities/document_permission_entity.dart';
import '../../domain/repositories/document_repository.dart';

// 🔧 IMPORTAR EL UPLOAD PROVIDER
export 'document_upload_provider.dart';

// --- Providers de infraestructura ---
final documentRemoteDataSourceProvider = Provider<DocumentRemoteDataSource>((
  ref,
) {
  final apiClient = ref.watch(apiClientProvider);
  return DocumentRemoteDataSourceImpl(apiClient: apiClient);
});

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  final remoteDataSource = ref.watch(documentRemoteDataSourceProvider);
  return DocumentRepositoryImpl(remoteDataSource: remoteDataSource);
});

// --- Estados para la lista de documentos ---
abstract class DocumentListState {}

class DocumentListInitial extends DocumentListState {}

class DocumentListLoading extends DocumentListState {}

class DocumentListSuccess extends DocumentListState {
  final List<DocumentEntity> documents;

  DocumentListSuccess(this.documents);
}

class DocumentListFailure extends DocumentListState {
  final String message;

  DocumentListFailure(this.message);
}

// --- Notifier para la lista de documentos ---
class DocumentListNotifier extends StateNotifier<DocumentListState> {
  final DocumentRepository _documentRepository;

  DocumentListNotifier(this._documentRepository) : super(DocumentListInitial());

  Future<void> fetchAllDocuments() async {
    try {
      state = DocumentListLoading();
      print('📁 [DocumentList] Fetching all documents');

      final documents = await _documentRepository.getAllDocuments();
      print('📁 [DocumentList] Found ${documents.length} documents');

      state = DocumentListSuccess(documents);
    } catch (e) {
      print('🔴 [DocumentList] Error: $e');
      state = DocumentListFailure(e.toString());
    }
  }

  Future<void> fetchDocumentsByProject(String projectId) async {
    try {
      state = DocumentListLoading();
      print('📁 [DocumentList] Fetching documents for project: $projectId');

      final documents = await _documentRepository.getDocumentsByProject(
        projectId,
      );
      print(
        '📁 [DocumentList] Found ${documents.length} documents for project',
      );

      state = DocumentListSuccess(documents);
    } catch (e) {
      print('🔴 [DocumentList] Error: $e');
      state = DocumentListFailure(e.toString());
    }
  }

  Future<void> deleteDocument(String documentId) async {
    try {
      await _documentRepository.deleteDocument(documentId);
      print('📁 [DocumentList] Document deleted: $documentId');

      // Refrescar la lista después de eliminar
      if (state is DocumentListSuccess) {
        final currentDocuments = (state as DocumentListSuccess).documents;
        final updatedDocuments = currentDocuments
            .where((doc) => doc.id != documentId)
            .toList();
        state = DocumentListSuccess(updatedDocuments);
      }
    } catch (e) {
      print('🔴 [DocumentList] Error deleting document: $e');
      state = DocumentListFailure('Error al eliminar documento: $e');
    }
  }

  void resetState() {
    state = DocumentListInitial();
  }
}

// --- Provider del notifier para lista de documentos ---
final documentListProvider =
    StateNotifierProvider<DocumentListNotifier, DocumentListState>((ref) {
      final documentRepository = ref.watch(documentRepositoryProvider);
      return DocumentListNotifier(documentRepository);
    });

// --- Estados para permisos de documentos ---
abstract class DocumentPermissionState {}

class DocumentPermissionInitial extends DocumentPermissionState {}

class DocumentPermissionLoading extends DocumentPermissionState {}

class DocumentPermissionSuccess extends DocumentPermissionState {
  final List<DocumentPermissionEntity> permissions;

  DocumentPermissionSuccess(this.permissions);
}

class DocumentPermissionFailure extends DocumentPermissionState {
  final String message;

  DocumentPermissionFailure(this.message);
}

// --- Notifier para permisos de documentos ---
class DocumentPermissionNotifier
    extends StateNotifier<DocumentPermissionState> {
  final DocumentRepository _documentRepository;

  DocumentPermissionNotifier(this._documentRepository)
    : super(DocumentPermissionInitial());

  Future<void> fetchPermissionsByDocument(String documentId) async {
    try {
      state = DocumentPermissionLoading();
      print(
        '🔐 [DocumentPermission] Fetching permissions for document: $documentId',
      );

      final permissions = await _documentRepository.getPermissionsByDocument(
        documentId,
      );
      print('🔐 [DocumentPermission] Found ${permissions.length} permissions');

      state = DocumentPermissionSuccess(permissions);
    } catch (e) {
      print('🔴 [DocumentPermission] Error: $e');
      state = DocumentPermissionFailure(e.toString());
    }
  }

  Future<void> grantPermission({
    required String documentId,
    required String workerId,
    required bool canView,
  }) async {
    try {
      print('🔐 [DocumentPermission] Granting permission to worker: $workerId');

      await _documentRepository.grantPermission(
        documentId: documentId,
        workerId: workerId,
        canView: canView,
      );

      // Refrescar permisos después de otorgar
      await fetchPermissionsByDocument(documentId);
    } catch (e) {
      print('🔴 [DocumentPermission] Error granting permission: $e');
      state = DocumentPermissionFailure('Error al otorgar permiso: $e');
    }
  }

  Future<void> revokePermissionsByDocument(String documentId) async {
    try {
      await _documentRepository.revokePermissionsByDocument(documentId);
      print(
        '🔐 [DocumentPermission] Permissions revoked for document: $documentId',
      );

      // Limpiar el estado después de revocar
      state = DocumentPermissionSuccess([]);
    } catch (e) {
      print('🔴 [DocumentPermission] Error revoking permissions: $e');
      state = DocumentPermissionFailure('Error al revocar permisos: $e');
    }
  }

  void resetState() {
    state = DocumentPermissionInitial();
  }
}

// --- Provider del notifier para permisos ---
final documentPermissionProvider =
    StateNotifierProvider<DocumentPermissionNotifier, DocumentPermissionState>((
      ref,
    ) {
      final documentRepository = ref.watch(documentRepositoryProvider);
      return DocumentPermissionNotifier(documentRepository);
    });

// --- Estados para verificar permisos ---
abstract class DocumentAccessState {}

class DocumentAccessInitial extends DocumentAccessState {}

class DocumentAccessLoading extends DocumentAccessState {}

class DocumentAccessGranted extends DocumentAccessState {}

class DocumentAccessDenied extends DocumentAccessState {}

class DocumentAccessFailure extends DocumentAccessState {
  final String message;

  DocumentAccessFailure(this.message);
}

// --- Notifier para verificar acceso ---
class DocumentAccessNotifier extends StateNotifier<DocumentAccessState> {
  final DocumentRepository _documentRepository;

  DocumentAccessNotifier(this._documentRepository)
    : super(DocumentAccessInitial());

  Future<void> checkAccess(String documentId, String workerId) async {
    try {
      state = DocumentAccessLoading();

      final canAccess = await _documentRepository.canWorkerViewDocument(
        documentId,
        workerId,
      );

      if (canAccess) {
        state = DocumentAccessGranted();
      } else {
        state = DocumentAccessDenied();
      }
    } catch (e) {
      print('🔴 [DocumentAccess] Error checking access: $e');
      state = DocumentAccessFailure(e.toString());
    }
  }

  void resetState() {
    state = DocumentAccessInitial();
  }
}

// --- Provider del notifier para verificar acceso ---
final documentAccessProvider =
    StateNotifierProvider<DocumentAccessNotifier, DocumentAccessState>((ref) {
      final documentRepository = ref.watch(documentRepositoryProvider);
      return DocumentAccessNotifier(documentRepository);
    });
