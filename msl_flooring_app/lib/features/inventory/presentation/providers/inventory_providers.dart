// lib/features/inventory/presentation/providers/inventory_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:msl_flooring_app/features/auth/presentation/providers/auth_providers.dart';

import '../../data/datasources/inventory_remote_data_source.dart';
import '../../data/repositories/inventory_repository_impl.dart';
import '../../domain/entities/material_entity.dart';
import '../../domain/entities/tool_entity.dart';
import '../../domain/repositories/inventory_repository.dart';

// --- Providers para la infraestructura de datos de Inventario ---

// 1. Provider para el InventoryRemoteDataSource
final inventoryRemoteDataSourceProvider = Provider<InventoryRemoteDataSource>((
  ref,
) {
  // Reutilizamos el apiClientProvider que ya maneja el token
  final apiClient = ref.watch(apiClientProvider);
  return InventoryRemoteDataSourceImpl(apiClient: apiClient);
});

// 2. Provider para el InventoryRepository
final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  final remoteDataSource = ref.watch(inventoryRemoteDataSourceProvider);
  return InventoryRepositoryImpl(remoteDataSource: remoteDataSource);
});

// --- State Notifier para la lista de Inventario ---

// 3. Provider del Notifier que nuestra UI observará
final inventoryStateProvider =
    StateNotifierProvider<InventoryNotifier, InventoryState>((ref) {
      final inventoryRepository = ref.watch(inventoryRepositoryProvider);
      // Creamos la instancia y llamamos al método para cargar los datos iniciales
      return InventoryNotifier(inventoryRepository)..fetchInventory();
    });

// --- Clases de Estado para la UI ---

// 4. Definimos los posibles estados de nuestra pantalla de inventario
abstract class InventoryState {}

class InventoryInitial extends InventoryState {}

class InventoryLoading extends InventoryState {}

class InventorySuccess extends InventoryState {
  final List<MaterialEntity> materials;
  final List<ToolEntity> tools;

  InventorySuccess({required this.materials, required this.tools});
}

class InventoryFailure extends InventoryState {
  final String message;

  InventoryFailure(this.message);
}

// --- El Notifier ---

// 5. La clase que contiene la lógica para obtener los datos y manejar el estado
class InventoryNotifier extends StateNotifier<InventoryState> {
  final InventoryRepository _inventoryRepository;

  InventoryNotifier(this._inventoryRepository) : super(InventoryInitial());

  Future<void> fetchInventory() async {
    try {
      state = InventoryLoading(); // Cambiamos el estado a "cargando"

      // Hacemos las dos llamadas a la API en paralelo para mayor eficiencia
      final results = await Future.wait([
        _inventoryRepository.getAllMaterials(),
        _inventoryRepository.getAllTools(),
      ]);

      // Asignamos los resultados a sus respectivas listas
      final materials = results[0] as List<MaterialEntity>;
      final tools = results[1] as List<ToolEntity>;

      // Si todo sale bien, actualizamos el estado con los datos
      state = InventorySuccess(materials: materials, tools: tools);
    } catch (e) {
      // Si algo falla, actualizamos el estado con el mensaje de error
      state = InventoryFailure(e.toString());
    }
  }
}
