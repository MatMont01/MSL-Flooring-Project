// lib/features/inventory/presentation/providers/create_material_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

// Estados para la creación
abstract class CreateMaterialState {}
class CreateMaterialInitial extends CreateMaterialState {}
class CreateMaterialLoading extends CreateMaterialState {}
class CreateMaterialSuccess extends CreateMaterialState {
  final String materialName; // 👈 CAMBIA ESTO - usar solo el nombre
  CreateMaterialSuccess(this.materialName);
}
class CreateMaterialFailure extends CreateMaterialState {
  final String message;
  CreateMaterialFailure(this.message);
}

// Notifier
class CreateMaterialNotifier extends StateNotifier<CreateMaterialState> {
  final ApiClient _apiClient;

  CreateMaterialNotifier(this._apiClient) : super(CreateMaterialInitial());

  Future<void> createMaterial(Map<String, dynamic> materialData) async {
    try {
      state = CreateMaterialLoading();

      final response = await _apiClient.post(
        ApiConstants.inventoryServiceBaseUrl,
        '/materials',
        materialData,
      );

      // 👇 CAMBIA ESTO - extraer el nombre del response
      final materialName = response['name'] as String? ?? 'Material';
      state = CreateMaterialSuccess(materialName);
    } catch (e) {
      state = CreateMaterialFailure(e.toString());
    }
  }
}

// Provider
final createMaterialProvider = StateNotifierProvider<CreateMaterialNotifier, CreateMaterialState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CreateMaterialNotifier(apiClient);
});