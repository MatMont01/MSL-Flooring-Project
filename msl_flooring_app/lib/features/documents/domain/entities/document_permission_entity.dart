// lib/features/documents/domain/entities/document_permission_entity.dart

class DocumentPermissionEntity {
  final String id;
  final String documentId;
  final String workerId;
  final bool canView;
  final DateTime grantedAt;

  const DocumentPermissionEntity({
    required this.id,
    required this.documentId,
    required this.workerId,
    required this.canView,
    required this.grantedAt,
  });
}
