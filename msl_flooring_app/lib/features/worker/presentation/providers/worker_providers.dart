// lib/features/worker/presentation/providers/worker_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/worker_remote_data_source.dart';
import '../../data/repositories/worker_repository_impl.dart';
import '../../domain/entities/worker_entity.dart';
import '../../domain/repositories/worker_repository.dart';

// --- Providers para la infraestructura de datos de Worker ---

// 1. Provider para el WorkerRemoteDataSource
final workerRemoteDataSourceProvider = Provider<WorkerRemoteDataSource>((ref) {
  // Reutilizamos el apiClientProvider que ya maneja el token
  final apiClient = ref.watch(apiClientProvider);
  return WorkerRemoteDataSourceImpl(apiClient: apiClient);
});

// 2. Provider para el WorkerRepository
final workerRepositoryProvider = Provider<WorkerRepository>((ref) {
  final remoteDataSource = ref.watch(workerRemoteDataSourceProvider);
  return WorkerRepositoryImpl(remoteDataSource: remoteDataSource);
});

// --- State Notifier para la lista de Trabajadores ---

// 3. Provider del Notifier que nuestra UI observará
final workerListProvider =
    StateNotifierProvider<WorkerListNotifier, WorkerListState>((ref) {
      final workerRepository = ref.watch(workerRepositoryProvider);
      // Creamos la instancia y llamamos al método para cargar los datos
      return WorkerListNotifier(workerRepository)..fetchWorkers();
    });

// --- Clases de Estado para la UI ---

// 4. Definimos los posibles estados de nuestra pantalla de trabajadores
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

// --- El Notifier ---

// 5. La clase que contiene la lógica para obtener los datos y manejar el estado
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
