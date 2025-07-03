// lib/features/analytics/data/datasources/analytics_remote_data_source.dart

import '../../../../core/api/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/dashboard_metric_model.dart';
import '../models/report_model.dart';

abstract class AnalyticsRemoteDataSource {
  Future<List<DashboardMetricModel>> getLatestDashboardMetrics();

  Future<List<ReportModel>> getLatestReports();
}

class AnalyticsRemoteDataSourceImpl implements AnalyticsRemoteDataSource {
  final ApiClient _apiClient;

  AnalyticsRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<DashboardMetricModel>> getLatestDashboardMetrics() async {
    final response = await _apiClient.get(
      ApiConstants.analyticsServiceBaseUrl,
      '/dashboard-metrics/latest', // Endpoint para obtener últimas métricas
    );

    final List<dynamic> metricListJson = response;
    return metricListJson
        .map((json) => DashboardMetricModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<ReportModel>> getLatestReports() async {
    final response = await _apiClient.get(
      ApiConstants.analyticsServiceBaseUrl,
      '/reports/latest', // Endpoint para obtener últimos reportes
    );

    final List<dynamic> reportListJson = response;
    return reportListJson.map((json) => ReportModel.fromJson(json)).toList();
  }
}
