// lib/core/common_widgets/session_handler.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:msl_flooring_app/core/common_widgets/home_shell.dart';
import 'package:msl_flooring_app/core/providers/session_provider.dart';
import 'package:msl_flooring_app/features/auth/domain/entities/session_entity.dart';

class SessionHandler extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const SessionHandler({
    required this.navigationShell,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos los cambios en el sessionProvider.
    ref.listen<SessionEntity?>(sessionProvider, (previous, next) {
      if (next != null) {
        // Cuando la sesión se establece, podemos forzar una actualización
        // o simplemente confiar en que los widgets que observan la sesión
        // se reconstruirán.
        print("[SessionHandler] Sesión detectada para el usuario: ${next.username}");
      }
    });

    // Pasamos el navigationShell al HomeShell.
    return HomeShell(navigationShell: navigationShell);
  }
}