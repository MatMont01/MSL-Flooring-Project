// lib/features/inventory/presentation/screens/inventory_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../../core/navigation/app_routes.dart';
import '../providers/inventory_providers.dart';
import 'create_tool_screen.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch inventory items when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(inventoryListProvider.notifier).fetchItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final inventoryState = ref.watch(inventoryListProvider);
    final bool isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(inventoryListProvider.notifier).fetchItems();
            },
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              heroTag: "inventory_fab", // 👈 AÑADE ESTA LÍNEA
              onPressed: () => _showAddItemDialog(context),
              child: const Icon(Icons.add),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(inventoryListProvider.notifier).fetchItems();
        },
        child: _buildBody(inventoryState),
      ),
    );
  }

  Widget _buildBody(InventoryListState state) {
    return switch (state) {
      InventoryListInitial() || InventoryListLoading() => const Center(
        child: CircularProgressIndicator(),
      ),
      InventoryListSuccess(items: final items) =>
        items.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No hay elementos en el inventario',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Añade materiales y herramientas usando el botón +',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getCategoryColor(item.category),
                        child: Icon(
                          _getCategoryIcon(item.category),
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.description),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Chip(
                                label: Text(item.category),
                                backgroundColor: _getCategoryColor(
                                  item.category,
                                ).withOpacity(0.2),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Cantidad: ${item.quantity}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${item.unitPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Total: \$${item.totalValue.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      onTap: () => _showItemDetails(context, item),
                    ),
                  );
                },
              ),
      InventoryListFailure(message: final message) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error al cargar inventario',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(inventoryListProvider.notifier).fetchItems();
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
      // TODO: Handle this case.
      InventoryListState() => throw UnimplementedError(),
    };
  }

  void _showAddItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Añadir al Inventario'),
        content: const Text('¿Qué deseas añadir?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.push(AppRoutes.createMaterial);
            },
            child: const Text('Material'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // 👇 CAMBIA ESTO - usa push normal en lugar de MaterialPageRoute
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CreateToolScreen(),
                ),
              );
            },
            child: const Text('Herramienta'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _showItemDetails(BuildContext context, item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Descripción: ${item.description}'),
            const SizedBox(height: 8),
            Text('Categoría: ${item.category}'),
            const SizedBox(height: 8),
            Text('Cantidad: ${item.quantity}'),
            const SizedBox(height: 8),
            Text('Precio unitario: \$${item.unitPrice.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text('Valor total: \$${item.totalValue.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text('Creado: ${_formatDate(item.createdAt)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'material':
        return Colors.blue;
      case 'herramienta':
        return Colors.orange;
      case 'tool':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'material':
        return Icons.build_outlined;
      case 'herramienta':
      case 'tool':
        return Icons.handyman;
      default:
        return Icons.inventory;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
