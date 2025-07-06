// lib/features/inventory/presentation/providers/create_tool_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/tool_remote_data_source.dart';
import '../../data/repositories/tool_repository_impl.dart';
import '../../domain/entities/tool_entity.dart';
import '../../domain/entities/tool_request_entity.dart';
import '../../domain/repositories/tool_repository.dart';

// --- Providers de infraestructura ---
final toolRemoteDataSourceProvider = Provider<ToolRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ToolRemoteDataSourceImpl(apiClient: apiClient);
});

final toolRepositoryProvider = Provider<ToolRepository>((ref) {
  final remoteDataSource = ref.watch(toolRemoteDataSourceProvider);
  return ToolRepositoryImpl(remoteDataSource: remoteDataSource);
});

// --- Estados para crear herramienta ---
abstract class CreateToolState {}

class CreateToolInitial extends CreateToolState {}

class CreateToolLoading extends CreateToolState {}

class CreateToolSuccess extends CreateToolState {
  final String toolName;

  CreateToolSuccess(this.toolName);
}

class CreateToolFailure extends CreateToolState {
  final String message;

  CreateToolFailure(this.message);
}

// --- Notifier para crear herramienta ---
class CreateToolNotifier extends StateNotifier<CreateToolState> {
  final ToolRepository _toolRepository;

  CreateToolNotifier(this._toolRepository) : super(CreateToolInitial());

  Future<void> createTool(Map<String, dynamic> toolData) async {
    try {
      state = CreateToolLoading();

      final toolRequest = ToolRequestEntity(
        name: toolData['name'],
        description: toolData['description'],
      );

      final newTool = await _toolRepository.createTool(toolRequest);
      state = CreateToolSuccess(newTool.name);
    } catch (e) {
      state = CreateToolFailure(e.toString());
    }
  }
}

// --- Provider del notifier ---
final createToolProvider =
    StateNotifierProvider<CreateToolNotifier, CreateToolState>((ref) {
      final toolRepository = ref.watch(toolRepositoryProvider);
      return CreateToolNotifier(toolRepository);
    });
