// lib/features/inventory/presentation/providers/material_assignment_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/inventory_remote_data_source.dart';
import '../../data/repositories/inventory_repository_impl.dart';
import '../../domain/repositories/inventory_repository.dart';

// --- Providers de infraestructura (reutilizamos los existentes) ---
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

// --- Estados para asignación de materiales ---
abstract class MaterialAssignmentState {}

class MaterialAssignmentInitial extends MaterialAssignmentState {}

class MaterialAssignmentLoading extends MaterialAssignmentState {}

class MaterialAssignmentSuccess extends MaterialAssignmentState {}

class MaterialAssignmentFailure extends MaterialAssignmentState {
  final String message;

  MaterialAssignmentFailure(this.message);
}

// --- Notifier para asignación de materiales ---
class MaterialAssignmentNotifier
    extends StateNotifier<MaterialAssignmentState> {
  final InventoryRepository _inventoryRepository;

  MaterialAssignmentNotifier(this._inventoryRepository)
    : super(MaterialAssignmentInitial());

  Future<void> assignMaterial(Map<String, dynamic> assignmentData) async {
    try {
      state = MaterialAssignmentLoading();

      // Crear el movimiento de inventario
      await _inventoryRepository.createInventoryMovement(assignmentData);

      state = MaterialAssignmentSuccess();
    } catch (e) {
      state = MaterialAssignmentFailure(e.toString());
    }
  }

  void resetState() {
    state = MaterialAssignmentInitial();
  }
}

// --- Provider del notifier ---
final materialAssignmentProvider =
    StateNotifierProvider<MaterialAssignmentNotifier, MaterialAssignmentState>((
      ref,
    ) {
      final inventoryRepository = ref.watch(inventoryRepositoryProvider);
      return MaterialAssignmentNotifier(inventoryRepository);
    });
