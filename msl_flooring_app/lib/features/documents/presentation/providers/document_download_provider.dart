// lib/features/documents/presentation/providers/document_download_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/services/document_download_service.dart';

// --- Estados para descarga ---
abstract class DocumentDownloadState {}

class DocumentDownloadInitial extends DocumentDownloadState {}

class DocumentDownloadProgress extends DocumentDownloadState {
  final String documentId;
  final String filename;
  final double progress;

  DocumentDownloadProgress({
    required this.documentId,
    required this.filename,
    required this.progress,
  });
}

class DocumentDownloadSuccess extends DocumentDownloadState {
  final String documentId;
  final String filename;
  final String filePath;
  final String fileSize;

  DocumentDownloadSuccess({
    required this.documentId,
    required this.filename,
    required this.filePath,
    required this.fileSize,
  });
}

class DocumentDownloadFailure extends DocumentDownloadState {
  final String documentId;
  final String errorMessage;

  DocumentDownloadFailure({
    required this.documentId,
    required this.errorMessage,
  });
}

// --- Notifier ---
class DocumentDownloadNotifier extends StateNotifier<DocumentDownloadState> {
  final DocumentDownloadService _downloadService;

  DocumentDownloadNotifier(this._downloadService)
    : super(DocumentDownloadInitial());

  Future<void> downloadDocument({
    required String documentId,
    required String filename,
    required String downloadUrl,
  }) async {
    try {
      print('📥 [DownloadNotifier] Starting download for: $filename');

      state = DocumentDownloadProgress(
        documentId: documentId,
        filename: filename,
        progress: 0.0,
      );

      final result = await _downloadService.downloadDocument(
        documentId: documentId,
        filename: filename,
        downloadUrl: downloadUrl,
        onProgress: (progress) {
          state = DocumentDownloadProgress(
            documentId: documentId,
            filename: filename,
            progress: progress,
          );
        },
      );

      if (result.isSuccess) {
        print('📥 [DownloadNotifier] Download successful: ${result.filePath}');
        state = DocumentDownloadSuccess(
          documentId: documentId,
          filename: result.filename!,
          filePath: result.filePath!,
          fileSize: result.formattedFileSize,
        );
      } else {
        print('🔴 [DownloadNotifier] Download failed: ${result.errorMessage}');
        state = DocumentDownloadFailure(
          documentId: documentId,
          errorMessage: result.errorMessage!,
        );
      }
    } catch (e) {
      print('🔴 [DownloadNotifier] Exception during download: $e');
      state = DocumentDownloadFailure(
        documentId: documentId,
        errorMessage: 'Error inesperado: $e',
      );
    }
  }

  Future<void> openDownloadedFile(String filePath) async {
    try {
      print('📱 [DownloadNotifier] Opening file: $filePath');
      final success = await _downloadService.openDownloadedFile(filePath);
      if (!success) {
        print('🔴 [DownloadNotifier] Failed to open file');
        // Podrías añadir un estado de error aquí si es necesario
      }
    } catch (e) {
      print('🔴 [DownloadNotifier] Error opening file: $e');
    }
  }

  void resetState() {
    print('📥 [DownloadNotifier] Resetting state');
    state = DocumentDownloadInitial();
  }
}

// --- Providers ---
final documentDownloadServiceProvider = Provider<DocumentDownloadService>((
  ref,
) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider).requireValue;
  return DocumentDownloadService(sharedPreferences: sharedPreferences);
});

final documentDownloadProvider =
    StateNotifierProvider<DocumentDownloadNotifier, DocumentDownloadState>((
      ref,
    ) {
      final downloadService = ref.watch(documentDownloadServiceProvider);
      return DocumentDownloadNotifier(downloadService);
    });
