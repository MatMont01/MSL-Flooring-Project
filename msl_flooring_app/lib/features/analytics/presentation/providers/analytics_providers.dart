// lib/features/analytics/presentation/providers/analytics_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/analytics_remote_data_source.dart';
import '../../data/repositories/analytics_repository_impl.dart';
import '../../domain/entities/dashboard_metric_entity.dart';
import '../../domain/entities/report_entity.dart';
import '../../domain/repositories/analytics_repository.dart';

// --- Providers para la infraestructura de datos de Analytics ---

// 1. Provider para el AnalyticsRemoteDataSource
final analyticsRemoteDataSourceProvider = Provider<AnalyticsRemoteDataSource>((
  ref,
) {
  final apiClient = ref.watch(apiClientProvider);
  return AnalyticsRemoteDataSourceImpl(apiClient: apiClient);
});

// 2. Provider para el AnalyticsRepository
final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  final remoteDataSource = ref.watch(analyticsRemoteDataSourceProvider);
  return AnalyticsRepositoryImpl(remoteDataSource: remoteDataSource);
});

// --- State Notifier para los datos de Analíticas ---

// 3. Provider del Notifier que nuestra UI observará
final analyticsStateProvider =
    StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
      final analyticsRepository = ref.watch(analyticsRepositoryProvider);
      return AnalyticsNotifier(analyticsRepository)..fetchAnalyticsData();
    });

// --- Clases de Estado para la UI ---

// 4. Definimos los posibles estados de nuestra pantalla
abstract class AnalyticsState {}

class AnalyticsInitial extends AnalyticsState {}

class AnalyticsLoading extends AnalyticsState {}

class AnalyticsSuccess extends AnalyticsState {
  final List<DashboardMetricEntity> metrics;
  final List<ReportEntity> reports;

  AnalyticsSuccess({required this.metrics, required this.reports});
}

class AnalyticsFailure extends AnalyticsState {
  final String message;

  AnalyticsFailure(this.message);
}

// --- El Notifier ---

// 5. La clase que contiene la lógica para obtener los datos y manejar el estado
class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  final AnalyticsRepository _analyticsRepository;

  AnalyticsNotifier(this._analyticsRepository) : super(AnalyticsInitial());

  Future<void> fetchAnalyticsData() async {
    try {
      state = AnalyticsLoading();

      final results = await Future.wait([
        _analyticsRepository.getLatestDashboardMetrics(),
        _analyticsRepository.getLatestReports(),
      ]);

      final metrics = results[0] as List<DashboardMetricEntity>;
      final reports = results[1] as List<ReportEntity>;

      state = AnalyticsSuccess(metrics: metrics, reports: reports);
    } catch (e) {
      state = AnalyticsFailure(e.toString());
    }
  }
}
