// lib/features/analytics/data/datasources/analytics_api_data_source.dart

import '../../../../core/api/api_client.dart';
import '../../../../core/constants/api_constants.dart';

abstract class AnalyticsApiDataSource {
  Future<Map<String, dynamic>> getProjectsAnalytics();

  Future<Map<String, dynamic>> getWorkersAnalytics();

  Future<Map<String, dynamic>> getInventoryAnalytics();

  Future<Map<String, dynamic>> getBudgetAnalytics();

  Future<Map<String, dynamic>> getFinancialSummary();
}

class AnalyticsApiDataSourceImpl implements AnalyticsApiDataSource {
  final ApiClient _apiClient;

  AnalyticsApiDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<Map<String, dynamic>> getProjectsAnalytics() async {
    print('📊 [AnalyticsAPI] Fetching projects analytics...');

    try {
      // Obtener todos los proyectos
      final projects = await _apiClient.get(
        ApiConstants.projectServiceBaseUrl,
        '',
      );

      // Calcular estadísticas
      final List<dynamic> projectList = projects as List<dynamic>;

      int totalProjects = projectList.length;
      int completedProjects = 0;
      int inProgressProjects = 0;
      int plannedProjects = 0;
      double totalBudget = 0;
      double averageCompletion = 0;

      for (var project in projectList) {
        final completion = (project['percentCompleted'] as num)
            .toDouble(); // 🔧 FIXED
        final budget = (project['budget'] as num).toDouble(); // 🔧 FIXED

        totalBudget += budget;
        averageCompletion += completion;

        if (completion >= 100) {
          completedProjects++;
        } else if (completion > 0) {
          inProgressProjects++;
        } else {
          plannedProjects++;
        }
      }

      averageCompletion = totalProjects > 0
          ? averageCompletion / totalProjects
          : 0;

      return {
        'totalProjects': totalProjects,
        'completedProjects': completedProjects,
        'inProgressProjects': inProgressProjects,
        'plannedProjects': plannedProjects,
        'totalBudget': totalBudget,
        'averageCompletion': averageCompletion,
        'projectsList': projectList,
      };
    } catch (e) {
      print('🔴 [AnalyticsAPI] Error fetching projects: $e');
      throw Exception('Error al obtener datos de proyectos: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getWorkersAnalytics() async {
    print('📊 [AnalyticsAPI] Fetching workers analytics...');

    try {
      final workers = await _apiClient.get(
        ApiConstants.workerServiceBaseUrl,
        '',
      );

      final List<dynamic> workerList = workers as List<dynamic>;

      return {
        'totalWorkers': workerList.length,
        'activeWorkers': workerList.length, // Todos están activos por defecto
        'workersList': workerList,
      };
    } catch (e) {
      print('🔴 [AnalyticsAPI] Error fetching workers: $e');
      throw Exception('Error al obtener datos de trabajadores: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getInventoryAnalytics() async {
    print('📊 [AnalyticsAPI] Fetching inventory analytics...');

    try {
      // Obtener materiales y herramientas en paralelo
      final results = await Future.wait([
        _apiClient.get(ApiConstants.inventoryServiceBaseUrl, '/materials'),
        _apiClient.get(ApiConstants.inventoryServiceBaseUrl, '/tools'),
      ]);

      final List<dynamic> materials = results[0] as List<dynamic>;
      final List<dynamic> tools = results[1] as List<dynamic>;

      double totalMaterialsValue = 0;
      Map<String, double> materialUsage = {}; // 🔧 CHANGED to double

      for (var material in materials) {
        final price = (material['unitPrice'] as num).toDouble(); // 🔧 FIXED
        totalMaterialsValue += price;

        // Simular uso de materiales (en producción esto vendría de movimientos)
        materialUsage[material['name']] =
            (price / 100); // 🔧 FIXED - return double
      }

      return {
        'totalMaterials': materials.length,
        'totalTools': tools.length,
        'totalInventoryValue': totalMaterialsValue,
        'materialUsage': materialUsage,
        'materialsList': materials,
        'toolsList': tools,
      };
    } catch (e) {
      print('🔴 [AnalyticsAPI] Error fetching inventory: $e');
      throw Exception('Error al obtener datos de inventario: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getBudgetAnalytics() async {
    print('📊 [AnalyticsAPI] Fetching budget analytics...');

    try {
      final projectsData = await getProjectsAnalytics();
      final inventoryData = await getInventoryAnalytics();
      final workersData = await getWorkersAnalytics();

      final totalBudget = (projectsData['totalBudget'] as num)
          .toDouble(); // 🔧 FIXED
      final materialsValue = (inventoryData['totalInventoryValue'] as num)
          .toDouble(); // 🔧 FIXED
      final workersCount = workersData['totalWorkers'] as int;

      // Estimaciones de distribución de presupuesto
      final materialsCost = materialsValue;
      final laborCost =
          (workersCount * 50000.0); // Estimación promedio por trabajador
      final equipmentCost = totalBudget * 0.15; // 15% del presupuesto
      final otherCosts = totalBudget * 0.10; // 10% otros gastos

      return {
        'totalBudget': totalBudget,
        'materialsCost': materialsCost,
        'laborCost': laborCost,
        'equipmentCost': equipmentCost,
        'otherCosts': otherCosts,
        'allocatedBudget':
            materialsCost + laborCost + equipmentCost + otherCosts,
        'remainingBudget':
            totalBudget -
            (materialsCost + laborCost + equipmentCost + otherCosts),
      };
    } catch (e) {
      print('🔴 [AnalyticsAPI] Error calculating budget: $e');
      throw Exception('Error al calcular análisis de presupuesto: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getFinancialSummary() async {
    print('📊 [AnalyticsAPI] Fetching financial summary...');

    try {
      final budgetData = await getBudgetAnalytics();

      final totalRevenue = (budgetData['totalBudget'] as num)
          .toDouble(); // 🔧 FIXED
      final totalExpenses = (budgetData['allocatedBudget'] as num)
          .toDouble(); // 🔧 FIXED
      final profit = totalRevenue - totalExpenses;
      final profitMargin = totalRevenue > 0
          ? (profit / totalRevenue) * 100
          : 0.0;

      return {
        'totalRevenue': totalRevenue,
        'totalExpenses': totalExpenses,
        'profit': profit,
        'profitMargin': profitMargin,
        'monthlyGrowth': 8.5,
        // Esto podría calcularse comparando con datos anteriores
        'yearlyGrowth': 15.2,
        // Esto también requeriría datos históricos
      };
    } catch (e) {
      print('🔴 [AnalyticsAPI] Error calculating financial summary: $e');
      throw Exception('Error al obtener resumen financiero: $e');
    }
  }
}
