// lib/features/analytics/data/repositories/analytics_repository_impl.dart

import '../../../../core/error/failure.dart';
import '../../domain/entities/dashboard_metric_entity.dart';
import '../../domain/entities/report_entity.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../datasources/analytics_remote_data_source.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDataSource remoteDataSource;

  AnalyticsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<DashboardMetricEntity>> getLatestDashboardMetrics() async {
    try {
      return await remoteDataSource.getLatestDashboardMetrics();
    } on Failure {
      // Si el error ya es una Falla conocida, la relanzamos.
      rethrow;
    } catch (e) {
      // Para cualquier otro error, lo envolvemos en una Falla genérica.
      throw const ServerFailure(
        'Ocurrió un error inesperado al obtener las métricas.',
      );
    }
  }

  @override
  Future<List<ReportEntity>> getLatestReports() async {
    try {
      return await remoteDataSource.getLatestReports();
    } on Failure {
      rethrow;
    } catch (e) {
      throw const ServerFailure(
        'Ocurrió un error inesperado al obtener los reportes.',
      );
    }
  }
}
