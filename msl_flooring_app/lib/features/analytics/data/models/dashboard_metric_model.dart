// lib/features/analytics/data/models/dashboard_metric_model.dart

import '../../domain/entities/dashboard_metric_entity.dart';

class DashboardMetricModel extends DashboardMetricEntity {
  const DashboardMetricModel({
    required super.id,
    required super.name,
    super.value,
    required super.capturedAt,
  });

  factory DashboardMetricModel.fromJson(Map<String, dynamic> json) {
    return DashboardMetricModel(
      id: json['id'],
      name: json['name'],
      // El valor puede ser nulo, así que lo manejamos con seguridad.
      value: (json['value'] as num?)?.toDouble(),
      capturedAt: DateTime.parse(json['capturedAt']),
    );
  }
}
