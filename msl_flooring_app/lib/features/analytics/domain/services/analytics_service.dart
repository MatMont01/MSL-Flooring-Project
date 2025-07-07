// lib/features/analytics/domain/services/analytics_service.dart

import '../entities/chart_data_entity.dart';

abstract class AnalyticsService {
  Future<List<KpiEntity>> getKpis();

  Future<List<ChartDataEntity>> getProjectStatusData();

  Future<List<ChartDataEntity>> getBudgetAnalysis();

  Future<List<ChartDataEntity>> getWorkerProductivity();

  Future<List<TimeSeriesDataEntity>> getProjectProgressOverTime();

  Future<List<ChartDataEntity>> getMaterialUsage();

  Future<Map<String, dynamic>> getFinancialSummary();
}

class AnalyticsServiceImpl implements AnalyticsService {
  @override
  Future<List<KpiEntity>> getKpis() async {
    // Simular datos KPI - en producción vendría del backend
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      const KpiEntity(
        id: 'total_projects',
        title: 'Proyectos Activos',
        value: '12',
        subtitle: 'En progreso',
        percentageChange: 15.5,
        isPositive: true,
        icon: 'business_center',
        color: 'blue',
      ),
      const KpiEntity(
        id: 'total_budget',
        title: 'Presupuesto Total',
        value: '\$2.4M',
        subtitle: 'Este mes',
        percentageChange: 8.2,
        isPositive: true,
        icon: 'attach_money',
        color: 'green',
      ),
      const KpiEntity(
        id: 'completion_rate',
        title: 'Tasa de Finalización',
        value: '87%',
        subtitle: 'Promedio',
        percentageChange: -2.1,
        isPositive: false,
        icon: 'trending_up',
        color: 'orange',
      ),
      const KpiEntity(
        id: 'active_workers',
        title: 'Trabajadores Activos',
        value: '45',
        subtitle: 'En campo',
        percentageChange: 12.0,
        isPositive: true,
        icon: 'people',
        color: 'purple',
      ),
    ];
  }

  @override
  Future<List<ChartDataEntity>> getProjectStatusData() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return [
      const ChartDataEntity(label: 'Completados', value: 8, category: 'status'),
      const ChartDataEntity(
        label: 'En Progreso',
        value: 12,
        category: 'status',
      ),
      const ChartDataEntity(
        label: 'Planificados',
        value: 5,
        category: 'status',
      ),
      const ChartDataEntity(label: 'En Pausa', value: 2, category: 'status'),
    ];
  }

  @override
  Future<List<ChartDataEntity>> getBudgetAnalysis() async {
    await Future.delayed(const Duration(milliseconds: 400));

    return [
      const ChartDataEntity(
        label: 'Materiales',
        value: 1200000,
        category: 'budget',
      ),
      const ChartDataEntity(
        label: 'Mano de Obra',
        value: 800000,
        category: 'budget',
      ),
      const ChartDataEntity(
        label: 'Equipos',
        value: 300000,
        category: 'budget',
      ),
      const ChartDataEntity(label: 'Otros', value: 100000, category: 'budget'),
    ];
  }

  @override
  Future<List<ChartDataEntity>> getWorkerProductivity() async {
    await Future.delayed(const Duration(milliseconds: 350));

    return [
      const ChartDataEntity(
        label: 'Juan Pérez',
        value: 95,
        category: 'productivity',
      ),
      const ChartDataEntity(
        label: 'María García',
        value: 88,
        category: 'productivity',
      ),
      const ChartDataEntity(
        label: 'Carlos López',
        value: 92,
        category: 'productivity',
      ),
      const ChartDataEntity(
        label: 'Ana Martínez',
        value: 90,
        category: 'productivity',
      ),
      const ChartDataEntity(
        label: 'Luis Rodríguez',
        value: 85,
        category: 'productivity',
      ),
    ];
  }

  @override
  Future<List<TimeSeriesDataEntity>> getProjectProgressOverTime() async {
    await Future.delayed(const Duration(milliseconds: 600));

    final now = DateTime.now();
    return List.generate(30, (index) {
      final date = now.subtract(Duration(days: 29 - index));
      final value =
          20 + (index * 2.5) + (index % 3 * 5); // Simulación de progreso
      return TimeSeriesDataEntity(date: date, value: value, metric: 'progress');
    });
  }

  @override
  Future<List<ChartDataEntity>> getMaterialUsage() async {
    await Future.delayed(const Duration(milliseconds: 450));

    return [
      const ChartDataEntity(
        label: 'Alfombras',
        value: 45,
        category: 'materials',
      ),
      const ChartDataEntity(
        label: 'Pisos Laminados',
        value: 30,
        category: 'materials',
      ),
      const ChartDataEntity(
        label: 'Baldosas',
        value: 15,
        category: 'materials',
      ),
      const ChartDataEntity(label: 'Madera', value: 10, category: 'materials'),
    ];
  }

  @override
  Future<Map<String, dynamic>> getFinancialSummary() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return {
      'totalRevenue': 2400000,
      'totalExpenses': 1850000,
      'profit': 550000,
      'profitMargin': 22.9,
      'monthlyGrowth': 8.5,
      'yearlyGrowth': 15.2,
    };
  }
}
