// lib/core/common_widgets/home_shell.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (int index) => _onTap(context, index),
        // Se recomienda añadir un tipo para evitar que el estilo cambie
        // cuando hay más de 3 ítems.
        type: BottomNavigationBarType.fixed,
        items: const [
          // Pestaña 0: Proyectos
          BottomNavigationBarItem(
            icon: Icon(Icons.business_center),
            label: 'Proyectos',
          ),
          // Pestaña 1: Inventario
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Inventario',
          ),
          // Pestaña 2: Trabajadores
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Trabajadores',
          ),
          // Pestaña 3: Comunicaciones
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Comunicaciones',
          ),
          // Pestaña 4: Analíticas (NUEVA)
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analíticas',
          ),
        ],
      ),
    );
  }
}
