// lib/features/inventory/presentation/providers/inventory_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/inventory_remote_data_source.dart';
import '../../data/repositories/inventory_repository_impl.dart';
import '../../domain/entities/inventory_item_entity.dart';
import '../../domain/repositories/inventory_repository.dart';

// --- Providers de infraestructura ---
final inventoryRemoteDataSourceProvider = Provider<InventoryRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return InventoryRemoteDataSourceImpl(apiClient: apiClient);
});

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  final remoteDataSource = ref.watch(inventoryRemoteDataSourceProvider);
  return InventoryRepositoryImpl(remoteDataSource: remoteDataSource);
});

// --- State Notifier para la lista de inventario ---
final inventoryListProvider =
StateNotifierProvider<InventoryListNotifier, InventoryListState>((ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return InventoryListNotifier(repository);
});

// --- Estados ---
abstract class InventoryListState {}

class InventoryListInitial extends InventoryListState {}

class InventoryListLoading extends InventoryListState {}

class InventoryListSuccess extends InventoryListState {
  final List<InventoryItemEntity> items;

  InventoryListSuccess(this.items);
}

class InventoryListFailure extends InventoryListState {
  final String message;

  InventoryListFailure(this.message);
}

// --- Notifier ---
class InventoryListNotifier extends StateNotifier<InventoryListState> {
  final InventoryRepository _repository;

  InventoryListNotifier(this._repository) : super(InventoryListInitial());

  Future<void> fetchItems() async {
    try {
      state = InventoryListLoading();
      final items = await _repository.getAllItems();
      state = InventoryListSuccess(items);
    } catch (e) {
      state = InventoryListFailure(e.toString());
    }
  }

  Future<void> fetchItemsByProject(String projectId) async {
    try {
      state = InventoryListLoading();
      final items = await _repository.getItemsByProject(projectId);
      state = InventoryListSuccess(items);
    } catch (e) {
      state = InventoryListFailure(e.toString());
    }
  }
}