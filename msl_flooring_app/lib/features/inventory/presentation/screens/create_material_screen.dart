// lib/features/inventory/presentation/screens/create_material_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:msl_flooring_app/features/inventory/domain/entities/material_request_entity.dart';
import 'package:msl_flooring_app/features/inventory/presentation/providers/inventory_providers.dart';


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
  final _imageUrlController = TextEditingController();
  final _unitPriceController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _unitPriceController.dispose();
    super.dispose();
  }

  void _submitForm() {
    // Primero, validamos que el formulario esté correcto.
    if (_formKey.currentState!.validate()) {
      // Creamos la entidad con los datos del formulario.
      final materialRequest = MaterialRequestEntity(
        name: _nameController.text,
        description: _descriptionController.text,
        imageUrl: _imageUrlController.text.isNotEmpty
            ? _imageUrlController.text
            : null,
        unitPrice: double.tryParse(_unitPriceController.text) ?? 0.0,
      );

      // Llamamos al notifier para que inicie el proceso de creación.
      ref.read(createMaterialProvider.notifier).createMaterial(materialRequest);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos los cambios de estado para reaccionar (mostrar mensajes, navegar).
    ref.listen<CreateMaterialState>(createMaterialProvider, (previous, next) {
      if (next is CreateMaterialSuccess) {
        // Si tiene éxito, refrescamos la lista principal de inventario.
        ref.invalidate(inventoryStateProvider);
        // Volvemos a la pantalla anterior.
        context.pop();
        // Mostramos un mensaje de confirmación.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Material "${next.newMaterial.name}" creado con éxito.',
            ),
          ),
        );
      }
      if (next is CreateMaterialFailure) {
        // Si falla, mostramos un mensaje de error.
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${next.message}')));
      }
    });

    // Observamos el estado para cambiar la UI (ej. el botón).
    final createMaterialState = ref.watch(createMaterialProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Crear Nuevo Material')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Material',
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Este campo es requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (value) =>
                    value!.isEmpty ? 'Este campo es requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _unitPriceController,
                decoration: const InputDecoration(labelText: 'Precio Unitario'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Este campo es requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL de la Imagen (Opcional)',
                ),
              ),
              const SizedBox(height: 32),
              // --- Botón de Guardar ---
              ElevatedButton(
                // Si está cargando, se deshabilita; si no, llama a _submitForm.
                onPressed: createMaterialState is CreateMaterialLoading
                    ? null
                    : _submitForm,
                child: createMaterialState is CreateMaterialLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Guardar Material'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
