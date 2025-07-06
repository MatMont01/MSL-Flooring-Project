// lib/features/worker/presentation/providers/worker_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/worker_remote_data_source.dart';
import '../../data/repositories/worker_repository_impl.dart';
import '../../domain/entities/attendance_record_entity.dart';
import '../../domain/entities/check_in_request_entity.dart';
import '../../domain/entities/worker_entity.dart';
import '../../domain/repositories/worker_repository.dart';
import '../../domain/services/geolocation_service.dart';

// --- Providers de Infraestructura (se mantienen igual) ---
final workerRemoteDataSourceProvider = Provider<WorkerRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return WorkerRemoteDataSourceImpl(apiClient: apiClient);
});

final workerRepositoryProvider = Provider<WorkerRepository>((ref) {
  final remoteDataSource = ref.watch(workerRemoteDataSourceProvider);
  return WorkerRepositoryImpl(remoteDataSource: remoteDataSource);
});

final geolocationServiceProvider = Provider<GeolocationService>((ref) {
  return GeolocationService();
});

// --- Provider de la Lista de Trabajadores (se mantiene igual) ---
final workerListProvider =
StateNotifierProvider<WorkerListNotifier, WorkerListState>((ref) {
  final workerRepository = ref.watch(workerRepositoryProvider);
  return WorkerListNotifier(workerRepository)..fetchWorkers();
});
class WorkerListNotifier extends StateNotifier<WorkerListState> {
  final WorkerRepository _workerRepository;
  WorkerListNotifier(this._workerRepository) : super(WorkerListInitial());
  Future<void> fetchWorkers() async {
    try {
      state = WorkerListLoading();
      final workers = await _workerRepository.getAllWorkers();
      state = WorkerListSuccess(workers);
    } catch (e) {
      state = WorkerListFailure(e.toString());
    }
  }
}
abstract class WorkerListState {}
class WorkerListInitial extends WorkerListState {}
class WorkerListLoading extends WorkerListState {}
class WorkerListSuccess extends WorkerListState {
  final List<WorkerEntity> workers;
  WorkerListSuccess(this.workers);
}
class WorkerListFailure extends WorkerListState {
  final String message;
  WorkerListFailure(this.message);
}

// --- Lógica de Asistencia (sin cambios) ---
abstract class AttendanceState {}
class AttendanceInitial extends AttendanceState {}
class AttendanceLoading extends AttendanceState {}
class AttendanceSuccess extends AttendanceState {
  final AttendanceRecordEntity? activeRecord;
  AttendanceSuccess(this.activeRecord);
}
class AttendanceFailure extends AttendanceState {
  final String message;
  AttendanceFailure(this.message);
}
class AttendanceNotifier extends StateNotifier<AttendanceState> {
  final WorkerRepository _workerRepository;
  final GeolocationService _geolocationService;
  final String _workerId;
  AttendanceNotifier(this._workerRepository, this._geolocationService, this._workerId)
      : super(AttendanceInitial());

  Future<void> getStatus(String projectId) async {
    try {
      state = AttendanceLoading();
      final record = await _workerRepository.getActiveAttendanceRecord(projectId);
      state = AttendanceSuccess(record);
    } catch (e) {
      state = AttendanceFailure(e.toString());
    }
  }

  Future<void> performCheckIn(String projectId) async {
    try {
      state = AttendanceLoading();
      final position = await _geolocationService.getCurrentPosition();
      final request = CheckInRequestEntity(
          workerId: _workerId,
          projectId: projectId,
          latitude: position.latitude,
          longitude: position.longitude);
      final newRecord = await _workerRepository.checkIn(request);
      state = AttendanceSuccess(newRecord);
    } catch (e) {
      state = AttendanceFailure(e.toString());
    }
  }

  Future<void> performCheckOut(String attendanceId) async {
    try {
      state = AttendanceLoading();
      final position = await _geolocationService.getCurrentPosition();
      final updatedRecord = await _workerRepository.checkOut(
          attendanceId: attendanceId,
          latitude: position.latitude,
          longitude: position.longitude);
      state = AttendanceSuccess(null);
    } catch (e) {
      state = AttendanceFailure(e.toString());
    }
  }
}

// --- Provider de Asistencia (CORREGIDO) ---
final attendanceProvider = StateNotifierProvider.autoDispose
    .family<AttendanceNotifier, AttendanceState, String>((ref, workerId) {
  final workerRepository = ref.watch(workerRepositoryProvider);
  final geolocationService = ref.watch(geolocationServiceProvider);
  // El Notifier se crea con el workerId que se le pasa, es más seguro.
  return AttendanceNotifier(workerRepository, geolocationService, workerId);
});