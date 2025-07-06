// lib/features/inventory/presentation/screens/inventory_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/session_provider.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtengamos ambos valores para debug
    final sessionState = ref.watch(sessionProvider);
    final bool isAdmin = ref.watch(isAdminProvider);

    // 🐛 DEBUG: Agreguemos prints para verificar
    print('=== INVENTORY SCREEN DEBUG ===');
    print('Session state: $sessionState');
    print('Session roles: ${sessionState?.roles}');
    print('isAdmin from provider: $isAdmin');
    print('isAdmin from session: ${sessionState?.isAdmin}');
    print('===============================');

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
      // ✅ El FloatingActionButton ahora debería aparecer para admins
      floatingActionButton: isAdmin
          ? FloatingActionButton(
        onPressed: () {
          print('🟢 FloatingActionButton pressed!');
          _showAddItemDialog(context);
        },
        child: const Icon(Icons.add),
      )
          : null,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Lista de inventario aquí'),
          const SizedBox(height: 20),
          // 🐛 DEBUG: Widget temporal para mostrar estado
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text('DEBUG INFO:'),
                Text('isAdmin: $isAdmin'),
                Text('Session: ${sessionState != null ? "Active" : "Null"}'),
                Text('Roles: ${sessionState?.roles ?? "No roles"}'),
                if (isAdmin)
                  const Text('✅ Admin button should be visible',
                      style: TextStyle(color: Colors.green))
                else
                  const Text('❌ Not admin - no button',
                      style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
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