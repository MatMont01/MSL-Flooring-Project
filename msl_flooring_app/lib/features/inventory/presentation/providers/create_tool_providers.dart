// lib/features/inventory/presentation/providers/create_tool_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

// Estados para la creación
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

// Notifier
class CreateToolNotifier extends StateNotifier<CreateToolState> {
  final ApiClient _apiClient;

  CreateToolNotifier(this._apiClient) : super(CreateToolInitial());

  Future<void> createTool(Map<String, dynamic> toolData) async {
    try {
      state = CreateToolLoading();

      final response = await _apiClient.post(
        ApiConstants.inventoryServiceBaseUrl,
        '/tools',
        toolData,
      );

      final toolName = response['name'] as String? ?? 'Herramienta';
      state = CreateToolSuccess(toolName);
    } catch (e) {
      state = CreateToolFailure(e.toString());
    }
  }
}

// Provider
final createToolProvider =
    StateNotifierProvider<CreateToolNotifier, CreateToolState>((ref) {
      final apiClient = ref.watch(apiClientProvider);
      return CreateToolNotifier(apiClient);
    });
