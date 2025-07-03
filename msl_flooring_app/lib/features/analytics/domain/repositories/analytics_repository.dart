// lib/features/analytics/domain/repositories/analytics_repository.dart

import '../entities/dashboard_metric_entity.dart';
import '../entities/report_entity.dart';

abstract class AnalyticsRepository {
  // Contrato para obtener las últimas métricas del dashboard.
  Future<List<DashboardMetricEntity>> getLatestDashboardMetrics();

  // Contrato para obtener los últimos reportes generados.
  Future<List<ReportEntity>> getLatestReports();
}
