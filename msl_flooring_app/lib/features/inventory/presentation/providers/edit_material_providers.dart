// lib/features/inventory/presentation/providers/edit_material_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/material_remote_data_source.dart';
import '../../data/repositories/material_repository_impl.dart';
import '../../domain/entities/material_entity.dart';
import '../../domain/entities/material_request_entity.dart';
import '../../domain/repositories/material_repository.dart';

// --- Providers de infraestructura ---
final materialRemoteDataSourceProvider = Provider<MaterialRemoteDataSource>((
  ref,
) {
  final apiClient = ref.watch(apiClientProvider);
  return MaterialRemoteDataSourceImpl(apiClient: apiClient);
});

final materialRepositoryProvider = Provider<MaterialRepository>((ref) {
  final remoteDataSource = ref.watch(materialRemoteDataSourceProvider);
  return MaterialRepositoryImpl(remoteDataSource: remoteDataSource);
});

// --- Estados para editar material ---
abstract class EditMaterialState {}

class EditMaterialInitial extends EditMaterialState {}

class EditMaterialLoading extends EditMaterialState {}

class EditMaterialUpdateSuccess extends EditMaterialState {
  final String materialName;

  EditMaterialUpdateSuccess(this.materialName);
}

class EditMaterialDeleteSuccess extends EditMaterialState {
  final String materialName;

  EditMaterialDeleteSuccess(this.materialName);
}

class EditMaterialFailure extends EditMaterialState {
  final String message;

  EditMaterialFailure(this.message);
}

// --- Notifier para editar material ---
class EditMaterialNotifier extends StateNotifier<EditMaterialState> {
  final MaterialRepository _materialRepository;

  EditMaterialNotifier(this._materialRepository) : super(EditMaterialInitial());

  Future<void> updateMaterial(
    String materialId,
    Map<String, dynamic> materialData,
  ) async {
    try {
      state = EditMaterialLoading();

      final materialRequest = MaterialRequestEntity(
        name: materialData['name'],
        description: materialData['description'],
        unitPrice: materialData['unitPrice'],
      );

      final updatedMaterial = await _materialRepository.updateMaterial(
        materialId,
        materialRequest,
      );
      state = EditMaterialUpdateSuccess(updatedMaterial.name);
    } catch (e) {
      state = EditMaterialFailure(e.toString());
    }
  }

  Future<void> deleteMaterial(String materialId) async {
    try {
      state = EditMaterialLoading();

      // Primero obtenemos el material para saber su nombre
      final material = await _materialRepository.getMaterialById(materialId);

      // Luego lo eliminamos
      await _materialRepository.deleteMaterial(materialId);

      state = EditMaterialDeleteSuccess(material.name);
    } catch (e) {
      state = EditMaterialFailure(e.toString());
    }
  }

  void resetState() {
    state = EditMaterialInitial();
  }
}

// --- Provider del notifier ---
final editMaterialProvider =
    StateNotifierProvider<EditMaterialNotifier, EditMaterialState>((ref) {
      final materialRepository = ref.watch(materialRepositoryProvider);
      return EditMaterialNotifier(materialRepository);
    });
