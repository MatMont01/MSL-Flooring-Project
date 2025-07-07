// lib/features/documents/data/models/document_permission_model.dart

import '../../domain/entities/document_permission_entity.dart';

class DocumentPermissionModel extends DocumentPermissionEntity {
  const DocumentPermissionModel({
    required super.id,
    required super.documentId,
    required super.workerId,
    required super.canView,
    required super.grantedAt,
  });

  factory DocumentPermissionModel.fromJson(Map<String, dynamic> json) {
    return DocumentPermissionModel(
      id: json['id'],
      documentId: json['documentId'],
      workerId: json['workerId'],
      canView: json['canView'] ?? true,
      grantedAt: DateTime.parse(json['grantedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentId': documentId,
      'workerId': workerId,
      'canView': canView,
      'grantedAt': grantedAt.toIso8601String(),
    };
  }
}
