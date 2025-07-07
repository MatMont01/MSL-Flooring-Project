// lib/features/documents/domain/entities/document_entity.dart

class DocumentEntity {
  final String id;
  final String filename;
  final String fileUrl;
  final String uploadedBy;
  final String? projectId;
  final DateTime uploadedAt;
  final int fileSize; // En bytes
  final String fileType; // MIME type

  const DocumentEntity({
    required this.id,
    required this.filename,
    required this.fileUrl,
    required this.uploadedBy,
    this.projectId,
    required this.uploadedAt,
    required this.fileSize,
    required this.fileType,
  });

  String get fileSizeFormatted {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get fileExtension {
    return filename.split('.').last.toUpperCase();
  }

  bool get isImage {
    const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
    return imageExtensions.contains(fileExtension.toLowerCase());
  }

  bool get isPdf {
    return fileExtension.toLowerCase() == 'pdf';
  }
}