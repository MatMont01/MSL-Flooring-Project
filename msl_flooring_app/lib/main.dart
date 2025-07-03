// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/navigation/app_router.dart';

void main() {
  runApp(
    // 1. Envolvemos la app en un ProviderScope para que Riverpod funcione.
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. Usamos MaterialApp.router para integrar GoRouter.
    return MaterialApp.router(
      title: 'MSL Flooring App',
      debugShowCheckedModeBanner: false,
      // Opcional: para quitar la cinta de "Debug"
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // 3. Le pasamos la configuración de nuestro router.
      routerConfig: AppRouter.router,
    );
  }
}
