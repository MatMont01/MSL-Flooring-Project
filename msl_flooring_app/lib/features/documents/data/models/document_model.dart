// lib/features/documents/data/models/document_model.dart

import '../../domain/entities/document_entity.dart';

class DocumentModel extends DocumentEntity {
  const DocumentModel({
    required super.id,
    required super.filename,
    required super.fileUrl,
    required super.uploadedBy,
    super.projectId,
    required super.uploadedAt,
    required super.fileSize,
    required super.fileType,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'],
      filename: json['filename'],
      fileUrl: json['fileUrl'],
      uploadedBy: json['uploadedBy'],
      projectId: json['projectId'],
      uploadedAt: DateTime.parse(json['uploadedAt']),
      fileSize: json['fileSize'] ?? 0,
      fileType: json['fileType'] ?? 'application/octet-stream',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filename': filename,
      'fileUrl': fileUrl,
      'uploadedBy': uploadedBy,
      'projectId': projectId,
      'uploadedAt': uploadedAt.toIso8601String(),
      'fileSize': fileSize,
      'fileType': fileType,
    };
  }
}
