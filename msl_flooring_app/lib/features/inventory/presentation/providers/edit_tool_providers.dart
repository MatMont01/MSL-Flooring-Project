// lib/features/inventory/presentation/providers/edit_tool_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/tool_remote_data_source.dart';
import '../../data/repositories/tool_repository_impl.dart';
import '../../domain/entities/tool_entity.dart';
import '../../domain/entities/tool_request_entity.dart';
import '../../domain/repositories/tool_repository.dart';
import 'create_tool_providers.dart';

// --- Providers de infraestructura (reutilizamos los ya creados) ---
// Los providers toolRemoteDataSourceProvider y toolRepositoryProvider
// ya están definidos en create_tool_providers.dart, así que los importamos

// --- Estados para editar herramienta ---
abstract class EditToolState {}

class EditToolInitial extends EditToolState {}

class EditToolLoading extends EditToolState {}

class EditToolUpdateSuccess extends EditToolState {
  final String toolName;

  EditToolUpdateSuccess(this.toolName);
}

class EditToolDeleteSuccess extends EditToolState {
  final String toolName;

  EditToolDeleteSuccess(this.toolName);
}

class EditToolFailure extends EditToolState {
  final String message;

  EditToolFailure(this.message);
}

// --- Notifier para editar herramienta ---
class EditToolNotifier extends StateNotifier<EditToolState> {
  final ToolRepository _toolRepository;

  EditToolNotifier(this._toolRepository) : super(EditToolInitial());

  Future<void> updateTool(String toolId, Map<String, dynamic> toolData) async {
    try {
      state = EditToolLoading();

      final toolRequest = ToolRequestEntity(
        name: toolData['name'],
        description: toolData['description'],
      );

      final updatedTool = await _toolRepository.updateTool(toolId, toolRequest);
      state = EditToolUpdateSuccess(updatedTool.name);
    } catch (e) {
      state = EditToolFailure(e.toString());
    }
  }

  Future<void> deleteTool(String toolId) async {
    try {
      state = EditToolLoading();

      // Primero obtenemos la herramienta para saber su nombre
      final tool = await _toolRepository.getToolById(toolId);

      // Luego la eliminamos
      await _toolRepository.deleteTool(toolId);

      state = EditToolDeleteSuccess(tool.name);
    } catch (e) {
      state = EditToolFailure(e.toString());
    }
  }

  void resetState() {
    state = EditToolInitial();
  }
}

// --- Provider del notifier ---
final editToolProvider = StateNotifierProvider<EditToolNotifier, EditToolState>(
  (ref) {
    // Reutilizamos el toolRepositoryProvider de create_tool_providers.dart
    final toolRepository = ref.watch(toolRepositoryProvider);
    return EditToolNotifier(toolRepository);
  },
);
