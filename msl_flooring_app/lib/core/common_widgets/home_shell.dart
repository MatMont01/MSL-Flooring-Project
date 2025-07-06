// lib/core/common_widgets/home_shell.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:msl_flooring_app/core/providers/session_provider.dart';

// 1. Lo convertimos en un ConsumerWidget para que pueda observar providers.
class HomeShell extends ConsumerWidget {
  const HomeShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 2. OBSERVAMOS LA SESIÓN AQUÍ, EN EL WIDGET PADRE.
    final session = ref.watch(sessionProvider);

    // 3. SI LA SESIÓN NO ESTÁ LISTA, MOSTRAMOS UNA PANTALLA DE CARGA.
    // Esto previene que cualquiera de las pestañas se construya prematuramente.
    if (session == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 4. Si llegamos aquí, la sesión está lista. Construimos la UI normal.
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (int index) => _onTap(context, index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.business_center),
            label: 'Proyectos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Inventario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Trabajadores',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Comunicaciones',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analíticas',
          ),
        ],
      ),
    );
  }
}
