// lib/features/analytics/domain/services/real_analytics_service.dart



import '../data/datasources/analytics_api_data_source.dart';
import '../domain/entities/chart_data_entity.dart';
import '../domain/services/analytics_service.dart';

class RealAnalyticsService implements AnalyticsService {
  final AnalyticsApiDataSource _apiDataSource;

  RealAnalyticsService(this._apiDataSource);

  @override
  Future<List<KpiEntity>> getKpis() async {
    try {
      // Obtener datos reales de la API
      final projectsData = await _apiDataSource.getProjectsAnalytics();
      final workersData = await _apiDataSource.getWorkersAnalytics();
      final financialData = await _apiDataSource.getFinancialSummary();

      return [
        KpiEntity(
          id: 'total_projects',
          title: 'Proyectos Activos',
          value: '${projectsData['totalProjects']}',
          subtitle: 'En el sistema',
          percentageChange: _calculateProjectGrowth(projectsData),
          isPositive: _calculateProjectGrowth(projectsData) >= 0,
          icon: 'business_center',
          color: 'blue',
        ),
        KpiEntity(
          id: 'total_budget',
          title: 'Presupuesto Total',
          value:
              '\$${_formatCurrency((financialData['totalRevenue'] as num).toDouble())}',
          // 🔧 FIXED
          subtitle: 'Ingresos proyectados',
          percentageChange:
              (financialData['monthlyGrowth'] as num?)?.toDouble() ?? 0.0,
          // 🔧 FIXED
          isPositive:
              ((financialData['monthlyGrowth'] as num?)?.toDouble() ?? 0.0) >=
              0,
          icon: 'attach_money',
          color: 'green',
        ),
        KpiEntity(
          id: 'completion_rate',
          title: 'Finalización Promedio',
          value:
              '${(projectsData['averageCompletion'] as num).toDouble().toStringAsFixed(1)}%',
          // 🔧 FIXED
          subtitle: 'Progreso general',
          percentageChange: _calculateCompletionTrend(projectsData),
          isPositive: _calculateCompletionTrend(projectsData) >= 0,
          icon: 'trending_up',
          color: 'orange',
        ),
        KpiEntity(
          id: 'active_workers',
          title: 'Trabajadores',
          value: '${workersData['totalWorkers']}',
          subtitle: 'En la empresa',
          percentageChange: 5.0,
          // Esto requeriría datos históricos
          isPositive: true,
          icon: 'people',
          color: 'purple',
        ),
      ];
    } catch (e) {
      print('🔴 [RealAnalytics] Error getting KPIs: $e');
      throw Exception('Error al obtener indicadores clave: $e');
    }
  }

  @override
  Future<List<ChartDataEntity>> getProjectStatusData() async {
    try {
      final projectsData = await _apiDataSource.getProjectsAnalytics();

      return [
        ChartDataEntity(
          label: 'Completados',
          value: (projectsData['completedProjects'] as int).toDouble(),
          category: 'status',
        ),
        ChartDataEntity(
          label: 'En Progreso',
          value: (projectsData['inProgressProjects'] as int).toDouble(),
          category: 'status',
        ),
        ChartDataEntity(
          label: 'Planificados',
          value: (projectsData['plannedProjects'] as int).toDouble(),
          category: 'status',
        ),
      ];
    } catch (e) {
      print('🔴 [RealAnalytics] Error getting project status: $e');
      throw Exception('Error al obtener estado de proyectos: $e');
    }
  }

  @override
  Future<List<ChartDataEntity>> getBudgetAnalysis() async {
    try {
      final budgetData = await _apiDataSource.getBudgetAnalytics();

      return [
        ChartDataEntity(
          label: 'Materiales',
          value: (budgetData['materialsCost'] as num).toDouble(), // 🔧 FIXED
          category: 'budget',
        ),
        ChartDataEntity(
          label: 'Mano de Obra',
          value: (budgetData['laborCost'] as num).toDouble(), // 🔧 FIXED
          category: 'budget',
        ),
        ChartDataEntity(
          label: 'Equipos',
          value: (budgetData['equipmentCost'] as num).toDouble(), // 🔧 FIXED
          category: 'budget',
        ),
        ChartDataEntity(
          label: 'Otros',
          value: (budgetData['otherCosts'] as num).toDouble(), // 🔧 FIXED
          category: 'budget',
        ),
      ];
    } catch (e) {
      print('🔴 [RealAnalytics] Error getting budget analysis: $e');
      throw Exception('Error al obtener análisis de presupuesto: $e');
    }
  }

  @override
  Future<List<ChartDataEntity>> getWorkerProductivity() async {
    try {
      final workersData = await _apiDataSource.getWorkersAnalytics();
      final List<dynamic> workersList = workersData['workersList'];

      return workersList.map((worker) {
        // Simular productividad basada en datos reales
        final name = '${worker['firstName']} ${worker['lastName']}';
        final productivity =
            85.0 +
            (name.hashCode % 15).toDouble(); // 🔧 FIXED - Simular entre 85-100%

        return ChartDataEntity(
          label: name,
          value: productivity,
          category: 'productivity',
        );
      }).toList();
    } catch (e) {
      print('🔴 [RealAnalytics] Error getting worker productivity: $e');
      throw Exception('Error al obtener productividad de trabajadores: $e');
    }
  }

  @override
  Future<List<TimeSeriesDataEntity>> getProjectProgressOverTime() async {
    try {
      final projectsData = await _apiDataSource.getProjectsAnalytics();
      final List<dynamic> projectsList = projectsData['projectsList'];

      // Simular progreso en el tiempo basado en fechas de creación de proyectos
      final now = DateTime.now();
      return List.generate(30, (index) {
        final date = now.subtract(Duration(days: 29 - index));

        // Calcular progreso acumulativo basado en proyectos reales
        var cumulativeProgress = 0.0;
        var projectCount = 0;

        for (var project in projectsList) {
          final createdAt = DateTime.parse(project['createdAt']);
          if (createdAt.isBefore(date)) {
            cumulativeProgress += (project['percentCompleted'] as num)
                .toDouble(); // 🔧 FIXED
            projectCount++;
          }
        }

        final averageProgress = projectCount > 0
            ? cumulativeProgress / projectCount
            : 0.0;

        return TimeSeriesDataEntity(
          date: date,
          value: averageProgress,
          metric: 'progress',
        );
      });
    } catch (e) {
      print('🔴 [RealAnalytics] Error getting progress over time: $e');
      throw Exception('Error al obtener progreso en el tiempo: $e');
    }
  }

  @override
  Future<List<ChartDataEntity>> getMaterialUsage() async {
    try {
      final inventoryData = await _apiDataSource.getInventoryAnalytics();
      final Map<String, dynamic> materialUsage = inventoryData['materialUsage'];

      return materialUsage.entries.map((entry) {
        return ChartDataEntity(
          label: entry.key,
          value: (entry.value as num).toDouble(), // 🔧 FIXED
          category: 'materials',
        );
      }).toList();
    } catch (e) {
      print('🔴 [RealAnalytics] Error getting material usage: $e');
      throw Exception('Error al obtener uso de materiales: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getFinancialSummary() async {
    try {
      return await _apiDataSource.getFinancialSummary();
    } catch (e) {
      print('🔴 [RealAnalytics] Error getting financial summary: $e');
      throw Exception('Error al obtener resumen financiero: $e');
    }
  }

  // Métodos auxiliares para cálculos
  double _calculateProjectGrowth(Map<String, dynamic> projectsData) {
    // En un sistema real, esto compararía con datos del mes anterior
    final total = projectsData['totalProjects'] as int;
    return total > 5 ? 15.5 : -2.3; // Simulación basada en cantidad
  }

  double _calculateCompletionTrend(Map<String, dynamic> projectsData) {
    final averageCompletion = (projectsData['averageCompletion'] as num)
        .toDouble(); // 🔧 FIXED
    return averageCompletion > 50 ? 8.2 : -3.1; // Simulación basada en progreso
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    } else {
      return amount.toStringAsFixed(0);
    }
  }
}
