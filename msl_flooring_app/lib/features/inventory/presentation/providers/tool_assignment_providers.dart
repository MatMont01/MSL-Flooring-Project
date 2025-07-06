// lib/features/inventory/presentation/providers/tool_assignment_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/tool_assignment_remote_data_source.dart';
import '../../data/repositories/tool_assignment_repository_impl.dart';
import '../../domain/repositories/tool_assignment_repository.dart';

// --- Providers de infraestructura ---
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

// --- Estados para asignación de herramientas ---
abstract class ToolAssignmentState {}

class ToolAssignmentInitial extends ToolAssignmentState {}

class ToolAssignmentLoading extends ToolAssignmentState {}

class ToolAssignmentSuccess extends ToolAssignmentState {}

class ToolAssignmentFailure extends ToolAssignmentState {
  final String message;

  ToolAssignmentFailure(this.message);
}

// --- Notifier para asignación de herramientas ---
class ToolAssignmentNotifier extends StateNotifier<ToolAssignmentState> {
  final ToolAssignmentRepository _toolAssignmentRepository;

  ToolAssignmentNotifier(this._toolAssignmentRepository)
    : super(ToolAssignmentInitial());

  Future<void> assignTool(Map<String, dynamic> assignmentData) async {
    try {
      state = ToolAssignmentLoading();

      // Crear la asignación de herramienta
      await _toolAssignmentRepository.createToolAssignment(assignmentData);

      state = ToolAssignmentSuccess();
    } catch (e) {
      state = ToolAssignmentFailure(e.toString());
    }
  }

  void resetState() {
    state = ToolAssignmentInitial();
  }
}

// --- Provider del notifier ---
final toolAssignmentProvider =
    StateNotifierProvider<ToolAssignmentNotifier, ToolAssignmentState>((ref) {
      final toolAssignmentRepository = ref.watch(
        toolAssignmentRepositoryProvider,
      );
      return ToolAssignmentNotifier(toolAssignmentRepository);
    });
