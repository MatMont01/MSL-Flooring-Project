// lib/features/analytics/presentation/providers/enhanced_analytics_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/chart_data_entity.dart';
import '../../domain/services/analytics_service.dart';

import '../../data/datasources/analytics_api_data_source.dart';
import '../../services/real_analytics_service.dart';

// --- Estados mejorados (se mantienen igual) ---
abstract class EnhancedAnalyticsState {}

class EnhancedAnalyticsInitial extends EnhancedAnalyticsState {}

class EnhancedAnalyticsLoading extends EnhancedAnalyticsState {}

class EnhancedAnalyticsSuccess extends EnhancedAnalyticsState {
  final List<KpiEntity> kpis;
  final List<ChartDataEntity> projectStatus;
  final List<ChartDataEntity> budgetAnalysis;
  final List<ChartDataEntity> workerProductivity;
  final List<TimeSeriesDataEntity> progressOverTime;
  final List<ChartDataEntity> materialUsage;
  final Map<String, dynamic> financialSummary;

  EnhancedAnalyticsSuccess({
    required this.kpis,
    required this.projectStatus,
    required this.budgetAnalysis,
    required this.workerProductivity,
    required this.progressOverTime,
    required this.materialUsage,
    required this.financialSummary,
  });
}

class EnhancedAnalyticsFailure extends EnhancedAnalyticsState {
  final String message;

  EnhancedAnalyticsFailure(this.message);
}

// --- Notifier (se mantiene igual) ---
class EnhancedAnalyticsNotifier extends StateNotifier<EnhancedAnalyticsState> {
  final AnalyticsService _analyticsService;

  EnhancedAnalyticsNotifier(this._analyticsService)
    : super(EnhancedAnalyticsInitial());

  Future<void> fetchAllAnalytics() async {
    try {
      print('📊 [AnalyticsNotifier] Starting to fetch real analytics data...');
      state = EnhancedAnalyticsLoading();

      // Cargar todos los datos en paralelo
      final results = await Future.wait([
        _analyticsService.getKpis(),
        _analyticsService.getProjectStatusData(),
        _analyticsService.getBudgetAnalysis(),
        _analyticsService.getWorkerProductivity(),
        _analyticsService.getProjectProgressOverTime(),
        _analyticsService.getMaterialUsage(),
        _analyticsService.getFinancialSummary(),
      ]);

      print('📊 [AnalyticsNotifier] All analytics data loaded successfully');

      state = EnhancedAnalyticsSuccess(
        kpis: results[0] as List<KpiEntity>,
        projectStatus: results[1] as List<ChartDataEntity>,
        budgetAnalysis: results[2] as List<ChartDataEntity>,
        workerProductivity: results[3] as List<ChartDataEntity>,
        progressOverTime: results[4] as List<TimeSeriesDataEntity>,
        materialUsage: results[5] as List<ChartDataEntity>,
        financialSummary: results[6] as Map<String, dynamic>,
      );
    } catch (e) {
      print('🔴 [AnalyticsNotifier] Error fetching analytics: $e');
      state = EnhancedAnalyticsFailure(e.toString());
    }
  }

  void refreshAnalytics() {
    print('📊 [AnalyticsNotifier] Refreshing analytics data...');
    fetchAllAnalytics();
  }
}

// --- Providers actualizados para usar datos reales ---
final analyticsApiDataSourceProvider = Provider<AnalyticsApiDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AnalyticsApiDataSourceImpl(apiClient: apiClient);
});

final realAnalyticsServiceProvider = Provider<AnalyticsService>((ref) {
  final apiDataSource = ref.watch(analyticsApiDataSourceProvider);
  return RealAnalyticsService(apiDataSource);
});

final enhancedAnalyticsProvider =
    StateNotifierProvider<EnhancedAnalyticsNotifier, EnhancedAnalyticsState>((
      ref,
    ) {
      final analyticsService = ref.watch(realAnalyticsServiceProvider);
      return EnhancedAnalyticsNotifier(analyticsService);
    });
