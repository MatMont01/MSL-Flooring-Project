// lib/features/inventory/presentation/screens/inventory_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../../core/navigation/app_routes.dart';
import '../providers/inventory_providers.dart';
import 'create_tool_screen.dart';
import 'assign_material_screen.dart';
import 'assign_tool_screen.dart';
import 'view_assignments_screen.dart';

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
        heroTag: "inventory_fab",
        onPressed: () => _showAddItemDialog(context),
        child: const Icon(Icons.add),
      )
          : null,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(inventoryListProvider.notifier).fetchItems();
        },
        child: _buildBody(inventoryState, isAdmin),
      ),
    );
  }

  Widget _buildBody(InventoryListState state, bool isAdmin) {
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
                      if (item.category.toLowerCase() == 'material')
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
              trailing: PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(value, item, isAdmin),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'view_assignments',
                    child: Row(
                      children: [
                        Icon(Icons.visibility, size: 16),
                        SizedBox(width: 8),
                        Text('Ver asignaciones'),
                      ],
                    ),
                  ),
                  if (isAdmin) ...[
                    PopupMenuItem(
                      value: 'assign',
                      child: Row(
                        children: [
                          Icon(
                            item.category.toLowerCase() == 'material'
                                ? Icons.send
                                : Icons.person_add,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item.category.toLowerCase() == 'material'
                                ? 'Asignar a proyecto'
                                : 'Asignar a trabajador',
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Eliminar', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
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
      InventoryListState() => throw UnimplementedError(),
    };
  }

  void _handleMenuAction(String action, item, bool isAdmin) {
    switch (action) {
      case 'view_assignments':
        _showAssignments(item);
        break;
      case 'assign':
        if (isAdmin) {
          _showAssignItem(item);
        }
        break;
      case 'edit':
        if (isAdmin) {
          _editItem(item);
        }
        break;
      case 'delete':
        if (isAdmin) {
          _deleteItem(item);
        }
        break;
    }
  }

  void _showAssignments(item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ViewAssignmentsScreen(item: item),
      ),
    ).then((_) {
      // Refrescar cuando regrese de ver asignaciones
      ref.read(inventoryListProvider.notifier).fetchItems();
    });
  }

  void _showAssignItem(item) {
    if (item.category.toLowerCase() == 'material') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AssignMaterialScreen(material: item),
        ),
      ).then((_) {
        ref.read(inventoryListProvider.notifier).fetchItems();
      });
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AssignToolScreen(tool: item),
        ),
      ).then((_) {
        ref.read(inventoryListProvider.notifier).fetchItems();
      });
    }
  }

  void _editItem(item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editar ${item.name} - Funcionalidad pendiente')),
    );
  }

  void _deleteItem(item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar ${item.category}'),
        content: Text('¿Estás seguro de que quieres eliminar "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${item.name} eliminado - Funcionalidad pendiente')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
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
            if (item.category.toLowerCase() == 'material') ...[
              Text('Cantidad: ${item.quantity}'),
              const SizedBox(height: 8),
              Text('Precio unitario: \$${item.unitPrice.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              Text('Valor total: \$${item.totalValue.toStringAsFixed(2)}'),
            ],
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