// lib/features/worker/data/datasources/worker_remote_data_source.dart

import '../../../../core/api/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/attendance_record_model.dart';
import '../models/check_in_request_model.dart';
import '../models/worker_model.dart';

// --- CONTRATO ACTUALIZADO ---
abstract class WorkerRemoteDataSource {
  Future<List<WorkerModel>> getAllWorkers();

  Future<List<WorkerModel>> getWorkersByIds(List<String> workerIds);

  // --- MÉTODOS AÑADIDOS AL CONTRATO ---
  Future<AttendanceRecordModel> checkIn(CheckInRequestModel checkInData);

  Future<AttendanceRecordModel> checkOut(
    String attendanceId,
    double latitude,
    double longitude,
  );
}

class WorkerRemoteDataSourceImpl implements WorkerRemoteDataSource {
  final ApiClient _apiClient;

  WorkerRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<WorkerModel>> getAllWorkers() async {
    final response = await _apiClient.get(
      ApiConstants.workerServiceBaseUrl,
      '',
    );
    final List<dynamic> workerListJson = response;
    return workerListJson.map((json) => WorkerModel.fromJson(json)).toList();
  }

  @override
  Future<List<WorkerModel>> getWorkersByIds(List<String> workerIds) async {
    final response = await _apiClient.post(
      ApiConstants.workerServiceBaseUrl,
      '/batch',
      {'workerIds': workerIds},
    );
    final List<dynamic> workerListJson = response;
    return workerListJson.map((json) => WorkerModel.fromJson(json)).toList();
  }

  // --- IMPLEMENTACIÓN DE checkIn ---
  @override
  Future<AttendanceRecordModel> checkIn(CheckInRequestModel checkInData) async {
    final response = await _apiClient.post(
      ApiConstants.workerServiceBaseUrl,
      '/attendance/check-in',
      checkInData.toJson(),
    );
    return AttendanceRecordModel.fromJson(response);
  }

  // --- IMPLEMENTACIÓN DE checkOut ---
  @override
  Future<AttendanceRecordModel> checkOut(
    String attendanceId,
    double latitude,
    double longitude,
  ) async {
    final endpoint = '/attendance/check-out/$attendanceId';
    final body = {'latitude': latitude, 'longitude': longitude};

    final response = await _apiClient.post(
      ApiConstants.workerServiceBaseUrl,
      endpoint,
      body,
    );
    return AttendanceRecordModel.fromJson(response);
  }
}
