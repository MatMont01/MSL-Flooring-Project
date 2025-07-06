// lib/features/inventory/presentation/screens/inventory_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/providers/session_provider.dart';
import '../providers/inventory_providers.dart';

// Lo convertimos a ConsumerStatefulWidget para tener un control preciso del ciclo de vida
class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  @override
  void initState() {
    super.initState();
    // En initState, disparamos la carga de datos del inventario.
    // Esto es seguro y se hace una sola vez cuando la pestaña se crea.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(inventoryStateProvider.notifier).fetchInventory();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Observamos el proveedor de sesión.
    final session = ref.watch(sessionProvider);

    // 2. Si la sesión aún no está lista, mostramos una pantalla de carga.
    // ESTA ES LA CLAVE DE LA SOLUCIÓN. Evita que se construya el resto
    // de la UI con datos nulos o desactualizados.
    if (session == null) {
      print(
        "[InventoryScreen.build] - La sesión es nula, mostrando pantalla de carga.",
      );
      return Scaffold(
        appBar: AppBar(title: const Text('Inventario')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // 3. Si llegamos aquí, es porque la sesión YA está disponible.
    // Ahora podemos calcular 'isAdmin' de forma segura.
    final bool isAdmin = session.isAdmin;
    final inventoryState = ref.watch(inventoryStateProvider);

    print(
      "[InventoryScreen.build] - Sesión DISPONIBLE. Usuario: ${session.username}, Es Admin: $isAdmin",
    );

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Inventario'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Materiales'),
              Tab(text: 'Herramientas'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.read(inventoryStateProvider.notifier).fetchInventory();
              },
            ),
          ],
        ),
        // 'isAdmin' ahora tendrá el valor correcto cuando se construya este botón.
        floatingActionButton: isAdmin
            ? FloatingActionButton(
                onPressed: () {
                  context.push(AppRoutes.createMaterial);
                },
                child: const Icon(Icons.add),
              )
            : null,
        body: Center(
          child: switch (inventoryState) {
            InventoryInitial() ||
            InventoryLoading() => const CircularProgressIndicator(),
            InventorySuccess(materials: final materials, tools: final tools) =>
              TabBarView(
                children: [
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
            _ => const SizedBox.shrink(),
          },
        ),
      ),
    );
  }
}
