// lib/features/worker/presentation/providers/worker_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/worker_remote_data_source.dart';
import '../../data/repositories/worker_repository_impl.dart';
import '../../domain/entities/attendance_record_entity.dart'; // Import corregido
import '../../domain/entities/check_in_request_entity.dart';
import '../../domain/entities/worker_entity.dart';
import '../../domain/repositories/worker_repository.dart';
import '../../domain/services/geolocation_service.dart';

// --- Providers para la infraestructura de datos de Worker ---
final workerRemoteDataSourceProvider = Provider<WorkerRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return WorkerRemoteDataSourceImpl(apiClient: apiClient);
});

final workerRepositoryProvider = Provider<WorkerRepository>((ref) {
  final remoteDataSource = ref.watch(workerRemoteDataSourceProvider);
  return WorkerRepositoryImpl(remoteDataSource: remoteDataSource);
});

// --- State Notifier para la lista de Trabajadores ---
final workerListProvider =
    StateNotifierProvider<WorkerListNotifier, WorkerListState>((ref) {
      final workerRepository = ref.watch(workerRepositoryProvider);
      return WorkerListNotifier(workerRepository)..fetchWorkers();
    });

// --- Provider para el Servicio de Geolocalización (CORREGIDO) ---
// Se ha movido aquí para ser una variable top-level.
final geolocationServiceProvider = Provider<GeolocationService>((ref) {
  return GeolocationService();
});

// --- Clases de Estado para la UI ---
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

// --- El Notifier de la Lista ---
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

// --- Providers y Lógica para la Asistencia (Check-in/Check-out) ---

// 1. Definimos los estados para la asistencia de un proyecto.
abstract class AttendanceState {}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

// El estado de éxito contendrá el registro de asistencia activo (o null si no hay ninguno).
class AttendanceSuccess extends AttendanceState {
  final AttendanceRecordEntity? activeRecord;

  AttendanceSuccess(this.activeRecord);
}

class AttendanceFailure extends AttendanceState {
  final String message;

  AttendanceFailure(this.message);
}

// 2. Creamos el Notifier que manejará la lógica de la acción.
// --- El Notifier de Asistencia (MODIFICADO CON LOGS) ---
class AttendanceNotifier extends StateNotifier<AttendanceState> {
  final WorkerRepository _workerRepository;
  final GeolocationService _geolocationService;
  final String _workerId;

  AttendanceNotifier(
    this._workerRepository,
    this._geolocationService,
    this._workerId,
  ) : super(AttendanceInitial()) {
    // Log para saber cuándo se crea una instancia del Notifier
    print('[AttendanceNotifier] Instance created for worker ID: $_workerId');
  }

  // --- Lógica para obtener el estado actual ---
  Future<void> getStatus(String projectId) async {
    print('[AttendanceNotifier] getStatus called for project ID: $projectId');
    try {
      state = AttendanceLoading();
      print('[AttendanceNotifier] State set to Loading.');

      final record = await _workerRepository.getActiveAttendanceRecord(
        projectId,
      );

      if (record == null) {
        print('[AttendanceNotifier] No active record found.');
      } else {
        print('[AttendanceNotifier] Active record found: ${record.id}');
      }

      state = AttendanceSuccess(record);
      print('[AttendanceNotifier] State set to Success.');
    } catch (e, s) {
      print('======================================================');
      print('!!! ERROR en AttendanceNotifier.getStatus !!!');
      print('Error: $e');
      print('StackTrace: \n$s');
      print('======================================================');
      state = AttendanceFailure(e.toString());
    }
  }

  // --- Lógica para el Check-in ---
  Future<void> performCheckIn(String projectId) async {
    try {
      state = AttendanceLoading();
      final position = await _geolocationService.getCurrentPosition();
      final request = CheckInRequestEntity(
        workerId: _workerId,
        projectId: projectId,
        latitude: position.latitude,
        longitude: position.longitude,
      );
      final newRecord = await _workerRepository.checkIn(request);
      state = AttendanceSuccess(newRecord);
    } catch (e) {
      state = AttendanceFailure(e.toString());
    }
  }

  // --- Lógica para el Check-out ---
  Future<void> performCheckOut(String attendanceId) async {
    try {
      state = AttendanceLoading();
      final position = await _geolocationService.getCurrentPosition();
      final updatedRecord = await _workerRepository.checkOut(
        attendanceId: attendanceId,
        latitude: position.latitude,
        longitude: position.longitude,
      );
      // Después del check-out, no hay registro activo, así que pasamos null.
      state = AttendanceSuccess(null);
    } catch (e) {
      state = AttendanceFailure(e.toString());
    }
  }
}

// 3. Creamos el Provider.family para nuestro nuevo Notifier.
final attendanceProvider = StateNotifierProvider.autoDispose
    .family<AttendanceNotifier, AttendanceState, String>((ref, projectId) {
      final workerRepository = ref.watch(workerRepositoryProvider);
      final geolocationService = ref.watch(geolocationServiceProvider);

      // Es seguro usar ! aquí porque este provider solo será accedido por un trabajador logueado.
      final workerId = ref.watch(sessionProvider)!.id;

      // La lógica de llamar a getStatus se mueve aquí.
      // Cuando el provider se cree, inmediatamente llamará a su propio método.
      return AttendanceNotifier(workerRepository, geolocationService, workerId)
        ..getStatus(projectId);
    });
