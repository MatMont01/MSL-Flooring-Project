// lib/features/inventory/presentation/screens/inventory_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/inventory_providers.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observamos el estado del provider de inventario
    final inventoryState = ref.watch(inventoryStateProvider);

    return DefaultTabController(
      length: 2, // Dos pestañas: Materiales y Herramientas
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Inventario'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Materiales'),
              Tab(text: 'Herramientas'),
            ],
          ),
        ),
        body: Center(
          // Usamos un switch para construir la UI según el estado actual
          child: switch (inventoryState) {
            InventoryInitial() ||
            InventoryLoading() => const CircularProgressIndicator(),
            InventorySuccess(materials: final materials, tools: final tools) =>
              TabBarView(
                children: [
                  // --- Pestaña de Materiales ---
                  ListView.builder(
                    itemCount: materials.length,
                    itemBuilder: (context, index) {
                      final material = materials[index];
                      return ListTile(
                        title: Text(material.name),
                        subtitle: Text(
                          'Precio: \$${material.unitPrice.toStringAsFixed(2)}',
                        ),
                      );
                    },
                  ),
                  // --- Pestaña de Herramientas ---
                  ListView.builder(
                    itemCount: tools.length,
                    itemBuilder: (context, index) {
                      final tool = tools[index];
                      return ListTile(
                        title: Text(tool.name),
                        subtitle: Text(tool.description),
                      );
                    },
                  ),
                ],
              ),
            InventoryFailure(message: final message) => Text('Error: $message'),
            // TODO: Handle this case.
            InventoryState() => throw UnimplementedError(),
          },
        ),
      ),
    );
  }
}
