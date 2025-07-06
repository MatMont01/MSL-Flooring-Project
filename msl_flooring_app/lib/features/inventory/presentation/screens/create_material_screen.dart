// lib/features/inventory/presentation/screens/create_material_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/create_material_providers.dart';
import '../providers/inventory_providers.dart';

class CreateMaterialScreen extends ConsumerStatefulWidget {
  const CreateMaterialScreen({super.key});

  @override
  ConsumerState<CreateMaterialScreen> createState() =>
      _CreateMaterialScreenState();
}

class _CreateMaterialScreenState extends ConsumerState<CreateMaterialScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final materialData = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'unitPrice': double.parse(_priceController.text),
      };

      // Llamar al provider para crear el material
      ref.read(createMaterialProvider.notifier).createMaterial(materialData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final createState = ref.watch(createMaterialProvider);

    // Escuchar cambios de estado
    ref.listen<CreateMaterialState>(createMaterialProvider, (previous, next) {
      if (next is CreateMaterialSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              // 👇 ARREGLA ESTA LÍNEA - usa materialName directamente
              'Material "${next.materialName}" creado exitosamente',
            ),
          ),
        );
        // Refrescar la lista de inventario
        ref.invalidate(inventoryListProvider);
        context.pop();
      }
      if (next is CreateMaterialFailure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${next.message}')));
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Crear Material')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Material',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la descripción';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Precio por Unidad',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el precio';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Por favor ingresa un precio válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: createState is CreateMaterialLoading
                      ? null
                      : _submitForm,
                  child: createState is CreateMaterialLoading
                      ? const CircularProgressIndicator()
                      : const Text('Crear Material'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
