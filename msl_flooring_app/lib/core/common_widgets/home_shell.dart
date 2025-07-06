// lib/core/common_widgets/home_shell.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:msl_flooring_app/core/providers/session_provider.dart';

class HomeShell extends ConsumerWidget {
  const HomeShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _onTap(BuildContext context, int index) {
    print('🔥 [HomeShell] Tab tapped: $index');
    print('🔥 [HomeShell] Current index: ${navigationShell.currentIndex}');

    // Debug: imprimir qué pestaña se está tocando
    switch (index) {
      case 0:
        print('🔥 [HomeShell] Navigating to Proyectos');
        break;
      case 1:
        print('🔥 [HomeShell] Navigating to Inventario');
        break;
      case 2:
        print('🔥 [HomeShell] Navigating to Trabajadores');
        break;
      case 3:
        print('🔥 [HomeShell] Navigating to Comunicaciones');
        break;
      case 4:
        print('🔥 [HomeShell] Navigating to Analíticas');
        break;
    }

    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );

    print('🔥 [HomeShell] Navigation completed to index: $index');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('🔥 [HomeShell] build() called');

    final session = ref.watch(sessionProvider);

    if (session == null) {
      print('🔥 [HomeShell] Session is null, showing loading');
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    print('🔥 [HomeShell] Session found for user: ${session.username}');
    print(
      '🔥 [HomeShell] Building HomeShell with current index: ${navigationShell.currentIndex}',
    );

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
