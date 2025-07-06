// lib/features/inventory/presentation/providers/assignment_list_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/tool_assignment_remote_data_source.dart';
import '../../data/repositories/tool_assignment_repository_impl.dart';
import '../../domain/repositories/tool_assignment_repository.dart';
import '../../domain/repositories/inventory_repository.dart';
import 'inventory_providers.dart';

// --- Providers de infraestructura para Tool Assignments ---
final toolAssignmentRemoteDataSourceProvider =
    Provider<ToolAssignmentRemoteDataSource>((ref) {
      final apiClient = ref.watch(apiClientProvider);
      return ToolAssignmentRemoteDataSourceImpl(apiClient: apiClient);
    });

final toolAssignmentRepositoryProvider = Provider<ToolAssignmentRepository>((
  ref,
) {
  final remoteDataSource = ref.watch(toolAssignmentRemoteDataSourceProvider);
  return ToolAssignmentRepositoryImpl(remoteDataSource: remoteDataSource);
});

// --- Estados para listar asignaciones de herramientas ---
abstract class ToolAssignmentsListState {}

class ToolAssignmentsInitial extends ToolAssignmentsListState {}

class ToolAssignmentsLoading extends ToolAssignmentsListState {}

class ToolAssignmentsSuccess extends ToolAssignmentsListState {
  final List<Map<String, dynamic>> assignments;

  ToolAssignmentsSuccess(this.assignments);
}

class ToolAssignmentsFailure extends ToolAssignmentsListState {
  final String message;

  ToolAssignmentsFailure(this.message);
}

// --- Notifier para asignaciones de herramientas ---
class ToolAssignmentsListNotifier
    extends StateNotifier<ToolAssignmentsListState> {
  final ToolAssignmentRepository _toolAssignmentRepository;

  ToolAssignmentsListNotifier(this._toolAssignmentRepository)
    : super(ToolAssignmentsInitial());

  Future<void> fetchAssignments(String toolId) async {
    try {
      state = ToolAssignmentsLoading();
      print('🔍 [ToolAssignments] Fetching assignments for tool: $toolId');

      final assignments = await _toolAssignmentRepository.getAssignmentsByTool(
        toolId,
      );
      print('🔍 [ToolAssignments] Found ${assignments.length} assignments');

      state = ToolAssignmentsSuccess(assignments);
    } catch (e) {
      print('🔴 [ToolAssignments] Error: $e');
      state = ToolAssignmentsFailure(e.toString());
    }
  }

  void resetState() {
    state = ToolAssignmentsInitial();
  }
}

// --- Provider del notifier para Tool Assignments ---
final toolAssignmentsListProvider =
    StateNotifierProvider<
      ToolAssignmentsListNotifier,
      ToolAssignmentsListState
    >((ref) {
      final toolAssignmentRepository = ref.watch(
        toolAssignmentRepositoryProvider,
      );
      return ToolAssignmentsListNotifier(toolAssignmentRepository);
    });

// --- Estados para movimientos de materiales ---
abstract class MaterialMovementsState {}

class MaterialMovementsInitial extends MaterialMovementsState {}

class MaterialMovementsLoading extends MaterialMovementsState {}

class MaterialMovementsSuccess extends MaterialMovementsState {
  final List<Map<String, dynamic>> movements;

  MaterialMovementsSuccess(this.movements);
}

class MaterialMovementsFailure extends MaterialMovementsState {
  final String message;

  MaterialMovementsFailure(this.message);
}

// --- Notifier para movimientos de materiales ---
class MaterialMovementsNotifier extends StateNotifier<MaterialMovementsState> {
  final InventoryRepository _inventoryRepository;

  MaterialMovementsNotifier(this._inventoryRepository)
    : super(MaterialMovementsInitial());

  Future<void> fetchMovements(String materialId) async {
    try {
      state = MaterialMovementsLoading();
      print(
        '🔍 [MaterialMovements] Fetching movements for material: $materialId',
      );

      final movements = await _inventoryRepository.getMovementsByMaterial(
        materialId,
      );
      print('🔍 [MaterialMovements] Found ${movements.length} movements');

      state = MaterialMovementsSuccess(movements);
    } catch (e) {
      print('🔴 [MaterialMovements] Error: $e');
      state = MaterialMovementsFailure(e.toString());
    }
  }

  void resetState() {
    state = MaterialMovementsInitial();
  }
}

// --- Provider del notifier para Material Movements ---
final materialMovementsProvider =
    StateNotifierProvider<MaterialMovementsNotifier, MaterialMovementsState>((
      ref,
    ) {
      final inventoryRepository = ref.watch(inventoryRepositoryProvider);
      return MaterialMovementsNotifier(inventoryRepository);
    });
