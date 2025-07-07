// lib/features/documents/presentation/providers/document_upload_provider.dart

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/document_remote_data_source.dart';
import '../../data/repositories/document_repository_impl.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/repositories/document_repository.dart';

// --- Providers de infraestructura específicos para upload ---
final documentUploadRemoteDataSourceProvider =
    Provider<DocumentRemoteDataSource>((ref) {
      final apiClient = ref.watch(apiClientProvider);
      return DocumentRemoteDataSourceImpl(apiClient: apiClient);
    });

final documentUploadRepositoryProvider = Provider<DocumentRepository>((ref) {
  final remoteDataSource = ref.watch(documentUploadRemoteDataSourceProvider);
  return DocumentRepositoryImpl(remoteDataSource: remoteDataSource);
});

// --- Estados para la subida de documentos ---
abstract class DocumentUploadState {
  const DocumentUploadState();
}

class DocumentUploadInitial extends DocumentUploadState {
  const DocumentUploadInitial();
}

class DocumentUploadLoading extends DocumentUploadState {
  final String? progressMessage;

  const DocumentUploadLoading({this.progressMessage});
}

class DocumentUploadProgress extends DocumentUploadState {
  final double progress; // 0.0 a 1.0
  final String message;

  const DocumentUploadProgress({required this.progress, required this.message});
}

class DocumentUploadSuccess extends DocumentUploadState {
  final DocumentEntity document;
  final String message;

  const DocumentUploadSuccess({
    required this.document,
    this.message = 'Documento subido exitosamente',
  });
}

class DocumentUploadFailure extends DocumentUploadState {
  final String message;
  final String? errorCode;

  const DocumentUploadFailure({required this.message, this.errorCode});
}

// --- Notifier para la subida de documentos ---
class DocumentUploadNotifier extends StateNotifier<DocumentUploadState> {
  final DocumentRepository _documentRepository;

  DocumentUploadNotifier(this._documentRepository)
    : super(const DocumentUploadInitial());

  /// Método principal para subir un documento
  Future<void> uploadDocument({
    required String filename,
    required File file,
    required String uploadedBy,
    String? projectId,
    String? description,
  }) async {
    try {
      // Validaciones previas
      if (!_validateFile(file)) {
        return;
      }

      // Iniciar el proceso de subida
      state = const DocumentUploadLoading(
        progressMessage: 'Preparando archivo...',
      );

      print('📁 [DocumentUpload] Starting upload process');
      print('📁 [DocumentUpload] File: $filename');
      print(
        '📁 [DocumentUpload] Size: ${_formatFileSize(await file.length())}',
      );
      print('📁 [DocumentUpload] Uploaded by: $uploadedBy');
      print('📁 [DocumentUpload] Project ID: $projectId');

      // Simular progreso de preparación
      await Future.delayed(const Duration(milliseconds: 500));
      state = const DocumentUploadProgress(
        progress: 0.1,
        message: 'Validando archivo...',
      );

      // Validar el tamaño del archivo
      final fileSize = await file.length();
      if (fileSize > 10 * 1024 * 1024) {
        // 10MB
        state = const DocumentUploadFailure(
          message: 'El archivo es demasiado grande. Máximo permitido: 10MB',
          errorCode: 'FILE_TOO_LARGE',
        );
        return;
      }

      // Actualizar progreso
      state = const DocumentUploadProgress(
        progress: 0.3,
        message: 'Conectando con el servidor...',
      );

      await Future.delayed(const Duration(milliseconds: 300));

      // Subir el archivo
      state = const DocumentUploadProgress(
        progress: 0.5,
        message: 'Subiendo archivo...',
      );

      final document = await _documentRepository.uploadDocument(
        filename: filename,
        file: file,
        uploadedBy: uploadedBy,
        projectId: projectId,
      );

      // Progreso final
      state = const DocumentUploadProgress(
        progress: 0.9,
        message: 'Finalizando...',
      );

      await Future.delayed(const Duration(milliseconds: 200));

      print('📁 [DocumentUpload] Upload successful');
      print('📁 [DocumentUpload] Document ID: ${document.id}');
      print('📁 [DocumentUpload] Document URL: ${document.fileUrl}');

      // Éxito
      state = DocumentUploadSuccess(
        document: document,
        message: 'Documento "${document.filename}" subido exitosamente',
      );
    } catch (e, stackTrace) {
      print('🔴 [DocumentUpload] Upload failed: $e');
      print('🔴 [DocumentUpload] StackTrace: $stackTrace');

      // Determinar el tipo de error
      String errorMessage;
      String? errorCode;

      if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        errorMessage =
            'Error de conexión. Verifica tu internet e intenta nuevamente.';
        errorCode = 'NETWORK_ERROR';
      } else if (e.toString().contains('unauthorized')) {
        errorMessage = 'No tienes permisos para subir este documento.';
        errorCode = 'UNAUTHORIZED';
      } else if (e.toString().contains('file too large')) {
        errorMessage = 'El archivo es demasiado grande.';
        errorCode = 'FILE_TOO_LARGE';
      } else if (e.toString().contains('invalid file type')) {
        errorMessage = 'Tipo de archivo no permitido.';
        errorCode = 'INVALID_FILE_TYPE';
      } else {
        errorMessage =
            'Error inesperado al subir el documento: ${e.toString()}';
        errorCode = 'UNKNOWN_ERROR';
      }

      state = DocumentUploadFailure(
        message: errorMessage,
        errorCode: errorCode,
      );
    }
  }

  /// Método para subir múltiples documentos
  Future<void> uploadMultipleDocuments({
    required List<File> files,
    required String uploadedBy,
    String? projectId,
    String? description,
  }) async {
    if (files.isEmpty) {
      state = const DocumentUploadFailure(
        message: 'No se seleccionaron archivos para subir',
        errorCode: 'NO_FILES_SELECTED',
      );
      return;
    }

    try {
      state = const DocumentUploadLoading(
        progressMessage: 'Preparando archivos...',
      );

      final List<DocumentEntity> uploadedDocuments = [];

      for (int i = 0; i < files.length; i++) {
        final file = files[i];
        final filename = file.path.split('/').last;

        // Actualizar progreso por archivo
        final progress = i / files.length;
        state = DocumentUploadProgress(
          progress: progress,
          message: 'Subiendo archivo ${i + 1} de ${files.length}: $filename',
        );

        try {
          final document = await _documentRepository.uploadDocument(
            filename: filename,
            file: file,
            uploadedBy: uploadedBy,
            projectId: projectId,
          );

          uploadedDocuments.add(document);
          print(
            '📁 [DocumentUpload] File ${i + 1}/${files.length} uploaded: ${document.id}',
          );
        } catch (e) {
          print('🔴 [DocumentUpload] Failed to upload file $filename: $e');
          // Continuar con el siguiente archivo
        }
      }

      if (uploadedDocuments.isEmpty) {
        state = const DocumentUploadFailure(
          message: 'No se pudo subir ningún archivo',
          errorCode: 'ALL_UPLOADS_FAILED',
        );
      } else if (uploadedDocuments.length < files.length) {
        // Algunos archivos fallaron
        state = DocumentUploadSuccess(
          document: uploadedDocuments.first, // Devolver el primero como ejemplo
          message:
              'Se subieron ${uploadedDocuments.length} de ${files.length} archivos',
        );
      } else {
        // Todos los archivos se subieron exitosamente
        state = DocumentUploadSuccess(
          document: uploadedDocuments.first,
          message:
              'Todos los ${uploadedDocuments.length} archivos se subieron exitosamente',
        );
      }
    } catch (e) {
      print('🔴 [DocumentUpload] Multiple upload failed: $e');
      state = DocumentUploadFailure(
        message: 'Error al subir archivos: ${e.toString()}',
        errorCode: 'MULTIPLE_UPLOAD_ERROR',
      );
    }
  }

  /// Validar archivo antes de subir
  bool _validateFile(File file) {
    // Verificar que el archivo existe
    if (!file.existsSync()) {
      state = const DocumentUploadFailure(
        message: 'El archivo seleccionado no existe',
        errorCode: 'FILE_NOT_EXISTS',
      );
      return false;
    }

    // Verificar extensión del archivo
    final filename = file.path.split('/').last;
    final extension = filename.split('.').last.toLowerCase();

    const allowedExtensions = [
      'pdf',
      'doc',
      'docx',
      'xls',
      'xlsx',
      'ppt',
      'pptx',
      'jpg',
      'jpeg',
      'png',
      'gif',
      'bmp',
      'webp',
      'txt',
      'rtf',
      'zip',
      'rar',
    ];

    if (!allowedExtensions.contains(extension)) {
      state = DocumentUploadFailure(
        message: 'Tipo de archivo no permitido: .$extension',
        errorCode: 'INVALID_FILE_TYPE',
      );
      return false;
    }

    return true;
  }

  /// Formatear tamaño de archivo
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Cancelar subida (si es posible)
  void cancelUpload() {
    if (state is DocumentUploadLoading || state is DocumentUploadProgress) {
      print('📁 [DocumentUpload] Upload cancelled by user');
      state = const DocumentUploadFailure(
        message: 'Subida cancelada por el usuario',
        errorCode: 'CANCELLED_BY_USER',
      );
    }
  }

  /// Reiniciar el estado
  void resetState() {
    print('📁 [DocumentUpload] Resetting state');
    state = const DocumentUploadInitial();
  }

  /// Reintentar la última subida fallida
  void retryLastUpload() {
    if (state is DocumentUploadFailure) {
      print('📁 [DocumentUpload] Retrying last upload');
      // En una implementación real, guardarías los parámetros de la última subida
      // Por ahora, solo reseteamos el estado
      resetState();
    }
  }

  /// Obtener información del estado actual
  Map<String, dynamic> getStateInfo() {
    return switch (state) {
      DocumentUploadInitial() => {
        'status': 'initial',
        'canUpload': true,
        'message': 'Listo para subir documentos',
      },
      DocumentUploadLoading(progressMessage: final message) => {
        'status': 'loading',
        'canUpload': false,
        'message': message ?? 'Subiendo...',
      },
      DocumentUploadProgress(
        progress: final progress,
        message: final message,
      ) =>
        {
          'status': 'progress',
          'canUpload': false,
          'progress': progress,
          'message': message,
          'progressPercentage': '${(progress * 100).toInt()}%',
        },
      DocumentUploadSuccess(document: final document, message: final message) =>
        {
          'status': 'success',
          'canUpload': true,
          'message': message,
          'documentId': document.id,
          'documentName': document.filename,
        },
      DocumentUploadFailure(
        message: final message,
        errorCode: final errorCode,
      ) =>
        {
          'status': 'failure',
          'canUpload': true,
          'message': message,
          'errorCode': errorCode,
          'canRetry': true,
        },
      // TODO: Handle this case.
      DocumentUploadState() => throw UnimplementedError(),
    };
  }
}

// --- Provider del notifier ---
final documentUploadProvider =
    StateNotifierProvider<DocumentUploadNotifier, DocumentUploadState>((ref) {
      final documentRepository = ref.watch(documentUploadRepositoryProvider);
      return DocumentUploadNotifier(documentRepository);
    });

// --- Provider adicional para obtener información del estado ---
final documentUploadInfoProvider = Provider<Map<String, dynamic>>((ref) {
  final uploadNotifier = ref.watch(documentUploadProvider.notifier);
  return uploadNotifier.getStateInfo();
});

// --- Provider para verificar si se puede subir ---
final canUploadDocumentProvider = Provider<bool>((ref) {
  final uploadState = ref.watch(documentUploadProvider);
  return uploadState is! DocumentUploadLoading &&
      uploadState is! DocumentUploadProgress;
});
