// lib/features/inventory/presentation/providers/inventory_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:msl_flooring_app/features/auth/domain/entities/session_entity.dart';
import 'package:msl_flooring_app/features/auth/presentation/providers/auth_providers.dart';

import '../../../../core/providers/session_provider.dart';
import '../../data/datasources/inventory_remote_data_source.dart';
import '../../data/repositories/inventory_repository_impl.dart';
import '../../domain/entities/material_entity.dart';
import '../../domain/entities/material_request_entity.dart';
import '../../domain/entities/tool_entity.dart';
import '../../domain/repositories/inventory_repository.dart';

// --- Providers de Infraestructura (SIN CAMBIOS) ---
final inventoryRemoteDataSourceProvider = Provider<InventoryRemoteDataSource>((
  ref,
) {
  final apiClient = ref.watch(apiClientProvider);
  return InventoryRemoteDataSourceImpl(apiClient: apiClient);
});

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  final remoteDataSource = ref.watch(inventoryRemoteDataSourceProvider);
  return InventoryRepositoryImpl(remoteDataSource: remoteDataSource);
});

// --- Lógica de Estado para la Lista de Inventario (SIN CAMBIOS EN ESTAS CLASES) ---
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

class InventoryNotifier extends StateNotifier<InventoryState> {
  final InventoryRepository _inventoryRepository;

  InventoryNotifier(this._inventoryRepository) : super(InventoryInitial());

  Future<void> fetchInventory() async {
    if (state is InventoryLoading) return;
    try {
      state = InventoryLoading();
      final results = await Future.wait([
        _inventoryRepository.getAllMaterials(),
        _inventoryRepository.getAllTools(),
      ]);
      final materials = results[0] as List<MaterialEntity>;
      final tools = results[1] as List<ToolEntity>;
      state = InventorySuccess(materials: materials, tools: tools);
    } catch (e) {
      state = InventoryFailure(e.toString());
    }
  }
}

// --- Provider de Inventario (ARQUITECTURA CORREGIDA Y DEFINITIVA) ---
final inventoryStateProvider =
    StateNotifierProvider.autoDispose<InventoryNotifier, InventoryState>((ref) {
      final inventoryRepository = ref.watch(inventoryRepositoryProvider);
      final notifier = InventoryNotifier(inventoryRepository);

      // Escuchamos el sessionProvider. Esto es reactivo.
      ref.listen<SessionEntity?>(sessionProvider, (previous, next) {
        // Cuando la sesión se establece por primera vez (pasa de null a tener datos)...
        if (previous == null && next != null) {
          print(
            "[inventoryStateProvider] Sesión detectada. Cargando inventario...",
          );
          // ...le damos la orden al notifier de que busque los datos.
          notifier.fetchInventory();
        }
      });

      return notifier;
    });

// --- Lógica para la CREACIÓN de un Material (se mantiene igual) ---
abstract class CreateMaterialState {}

class CreateMaterialInitial extends CreateMaterialState {}

class CreateMaterialLoading extends CreateMaterialState {}

class CreateMaterialSuccess extends CreateMaterialState {
  final MaterialEntity newMaterial;

  CreateMaterialSuccess(this.newMaterial);
}

class CreateMaterialFailure extends CreateMaterialState {
  final String message;

  CreateMaterialFailure(this.message);
}

class CreateMaterialNotifier extends StateNotifier<CreateMaterialState> {
  final InventoryRepository _inventoryRepository;

  CreateMaterialNotifier(this._inventoryRepository)
    : super(CreateMaterialInitial());

  Future<void> createMaterial(MaterialRequestEntity material) async {
    try {
      state = CreateMaterialLoading();
      final newMaterial = await _inventoryRepository.createMaterial(material);
      state = CreateMaterialSuccess(newMaterial);
    } catch (e) {
      state = CreateMaterialFailure(e.toString());
    }
  }
}

final createMaterialProvider =
    StateNotifierProvider<CreateMaterialNotifier, CreateMaterialState>((ref) {
      final inventoryRepository = ref.watch(inventoryRepositoryProvider);
      return CreateMaterialNotifier(inventoryRepository);
    });
