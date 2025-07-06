// lib/features/inventory/presentation/screens/create_material_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateMaterialScreen extends ConsumerWidget {
  const CreateMaterialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Material'),
      ),
      body: const Center(
        child: Text('Pantalla de creación de material - Por implementar'),
      ),
    );
  }
}