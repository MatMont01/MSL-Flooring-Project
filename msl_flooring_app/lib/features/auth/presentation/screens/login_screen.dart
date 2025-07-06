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
    print('🔥 [LoginScreen] Building LoginScreen');

    final sharedPrefsAsyncValue = ref.watch(sharedPreferencesProvider);

    return sharedPrefsAsyncValue.when(
      loading: () {
        print('🔥 [LoginScreen] SharedPreferences loading');
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
      error: (err, stack) {
        print('🔴 [LoginScreen] SharedPreferences error: $err');
        return Scaffold(
          body: Center(child: Text('Error al inicializar la app: $err')),
        );
      },
      data: (_) {
        print('🔥 [LoginScreen] SharedPreferences ready, building LoginView');
        return const _LoginView();
      },
    );
  }
}

class _LoginView extends ConsumerWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('🔥 [LoginView] Building LoginView');

    final usernameController = TextEditingController();
    final passwordController = TextEditingController();

    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      print('🔥 [LoginView] AuthState changed: ${next.runtimeType}');

      if (next is AuthSuccess) {
        print(
          '🔥 [LoginView] Login successful, navigating to: ${AppRoutes.home}',
        );
        try {
          context.go(AppRoutes.home);
          print('🔥 [LoginView] Navigation completed');
        } catch (e) {
          print('🔴 [LoginView] Navigation error: $e');
        }
      }
      if (next is AuthFailure) {
        print('🔴 [LoginView] Login failed: ${next.message}');
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
            Consumer(
              builder: (context, ref, child) {
                final authState = ref.watch(authNotifierProvider);
                print(
                  '🔥 [LoginView] Current authState: ${authState.runtimeType}',
                );

                if (authState is AuthLoading) {
                  return const CircularProgressIndicator();
                }
                return ElevatedButton(
                  onPressed: () {
                    final username = usernameController.text;
                    final password = passwordController.text;
                    print(
                      '🔥 [LoginView] Login button pressed with user: $username',
                    );
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
