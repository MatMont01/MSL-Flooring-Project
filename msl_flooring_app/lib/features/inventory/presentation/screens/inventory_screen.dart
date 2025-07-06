// lib/features/inventory/presentation/screens/inventory_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/session_provider.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Observamos el proveedor de sesión para saber el rol del usuario
    final sessionState = ref.watch(sessionProvider);
    final bool isAdmin = sessionState?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Lógica para refrescar inventario
            },
          ),
        ],
      ),
      // 2. Añadimos el FloatingActionButton condicionalmente
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () {
                // Mostrar diálogo o navegar a pantalla de añadir material/herramienta
                _showAddItemDialog(context);
              },
              child: const Icon(Icons.add),
            )
          : null, // Si no es admin, el botón no se muestra
      body: const Center(
        child: Text('Lista de inventario aquí'),
        // Aquí irá tu lista de materiales/herramientas
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Añadir Item'),
        content: const Text('¿Qué deseas añadir?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navegar a pantalla de añadir material
            },
            child: const Text('Material'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navegar a pantalla de añadir herramienta
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
}
