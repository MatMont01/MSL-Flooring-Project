// lib/features/analytics/domain/entities/report_entity.dart

class ReportEntity {
  final String id;
  final String reportType;
  final String? parameters; // JSON en formato String
  final DateTime generatedAt;
  final String? data; // JSON en formato String

  const ReportEntity({
    required this.id,
    required this.reportType,
    this.parameters,
    required this.generatedAt,
    this.data,
  });
}
