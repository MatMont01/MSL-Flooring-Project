// lib/features/worker/data/datasources/worker_remote_data_source.dart

import '../../../../core/api/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/worker_model.dart';

abstract class WorkerRemoteDataSource {
  Future<List<WorkerModel>> getAllWorkers();
}

class WorkerRemoteDataSourceImpl implements WorkerRemoteDataSource {
  final ApiClient _apiClient;

  WorkerRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<WorkerModel>> getAllWorkers() async {
    // Hacemos la llamada GET al endpoint de trabajadores
    final response = await _apiClient.get(
      ApiConstants.workerServiceBaseUrl,
      '', // El endpoint es la raíz del servicio de workers, según tu controller
    );

    // La API devuelve una lista de objetos JSON
    final List<dynamic> workerListJson = response;

    // Mapeamos la lista de JSON a una lista de WorkerModel
    return workerListJson.map((json) => WorkerModel.fromJson(json)).toList();
  }
}
