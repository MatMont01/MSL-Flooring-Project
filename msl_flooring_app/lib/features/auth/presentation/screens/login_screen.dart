// lib/features/auth/presentation/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_routes.dart';
import '../providers/auth_providers.dart';

// La pantalla principal ahora es un ConsumerWidget que maneja el estado asíncrono.
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observamos el FutureProvider directamente.
    final sharedPrefsAsyncValue = ref.watch(sharedPreferencesProvider);

    // Usamos el método .when() para manejar los 3 estados del Future:
    // loading, error y data (éxito).
    return sharedPrefsAsyncValue.when(
      // 1. Mientras SharedPreferences está cargando, mostramos un spinner.
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      // 2. Si hay un error al cargar SharedPreferences, mostramos un mensaje.
      error: (err, stack) => Scaffold(
        body: Center(child: Text('Error al inicializar la app: $err')),
      ),
      // 3. Cuando SharedPreferences está LISTO, construimos la vista del login.
      data: (_) => const _LoginView(),
    );
  }
}

// He movido la lógica de la vista a un widget privado para mayor limpieza.
class _LoginView extends ConsumerWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();

    // Escuchamos los cambios de estado del login para navegar o mostrar errores.
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next is AuthSuccess) {
        context.go(AppRoutes.home);
      }
      if (next is AuthFailure) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.message)));
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
            // Observamos el estado del login para mostrar el botón o el spinner.
            Consumer(
              builder: (context, ref, child) {
                final authState = ref.watch(authNotifierProvider);
                if (authState is AuthLoading) {
                  return const CircularProgressIndicator();
                }
                return ElevatedButton(
                  onPressed: () {
                    final username = usernameController.text;
                    final password = passwordController.text;
                    if (username.isNotEmpty && password.isNotEmpty) {
                      ref
                          .read(authNotifierProvider.notifier)
                          .login(username, password);
                    }
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
