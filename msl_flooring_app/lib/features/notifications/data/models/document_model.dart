// lib/features/notification/data/models/document_model.dart

import '../../domain/entities/document_entity.dart';

class DocumentModel extends DocumentEntity {
  const DocumentModel({
    required super.id,
    required super.filename,
    required super.fileUrl,
    required super.uploadedBy,
    super.projectId,
    required super.uploadedAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'],
      filename: json['filename'],
      fileUrl: json['fileUrl'],
      uploadedBy: json['uploadedBy'],
      projectId: json['projectId'],
      // Puede ser nulo
      uploadedAt: DateTime.parse(json['uploadedAt']),
    );
  }
}
