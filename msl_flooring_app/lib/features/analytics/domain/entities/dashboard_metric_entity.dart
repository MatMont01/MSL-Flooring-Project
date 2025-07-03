// lib/features/analytics/domain/entities/dashboard_metric_entity.dart

class DashboardMetricEntity {
  final String id;
  final String name;
  final double? value;
  final DateTime capturedAt;

  const DashboardMetricEntity({
    required this.id,
    required this.name,
    this.value,
    required this.capturedAt,
  });
}
