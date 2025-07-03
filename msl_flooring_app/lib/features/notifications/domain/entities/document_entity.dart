// lib/features/notification/domain/entities/document_entity.dart

class DocumentEntity {
  final String id;
  final String filename;
  final String fileUrl;
  final String uploadedBy; // Es un UUID del usuario
  final String? projectId; // Puede ser nulo
  final DateTime uploadedAt;

  const DocumentEntity({
    required this.id,
    required this.filename,
    required this.fileUrl,
    required this.uploadedBy,
    this.projectId,
    required this.uploadedAt,
  });
}
