// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/navigation/app_router.dart';

void main() {
  print('🔥🔥🔥 [MAIN] APP STARTING - ESTO ES UNA PRUEBA 🔥🔥🔥');
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('🔥🔥🔥 [MyApp] Building MyApp 🔥🔥🔥');
    return MaterialApp.router(
      title: 'MSL Flooring App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routerConfig: AppRouter.router,
    );
  }
}
