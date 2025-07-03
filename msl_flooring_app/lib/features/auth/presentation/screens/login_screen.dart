// lib/features/auth/presentation/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_routes.dart';
import '../providers/auth_providers.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();

    // Observar el estado de autenticación
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next is AuthSuccess) {
        context.go(AppRoutes.home); // Navega a home si el login es exitoso
      }
      if (next is AuthFailure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.message)));
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar Sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Usuario'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 32),
            Consumer(
              builder: (context, ref, child) {
                final authState = ref.watch(authNotifierProvider);
                if (authState is AuthLoading) {
                  return const CircularProgressIndicator();
                }
                return ElevatedButton(
                  onPressed: () {
                    ref
                        .read(authNotifierProvider.notifier)
                        .login(
                          usernameController.text,
                          passwordController.text,
                        );
                  },
                  child: const Text('Login'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
