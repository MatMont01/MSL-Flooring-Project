// lib/features/inventory/presentation/screens/create_tool_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/create_tool_providers.dart';
import '../providers/inventory_providers.dart';

class CreateToolScreen extends ConsumerStatefulWidget {
  const CreateToolScreen({super.key});

  @override
  ConsumerState<CreateToolScreen> createState() => _CreateToolScreenState();
}

class _CreateToolScreenState extends ConsumerState<CreateToolScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final toolData = {
        'name': _nameController.text,
        'description': _descriptionController.text,
      };

      // Llamar al provider para crear la herramienta
      ref.read(createToolProvider.notifier).createTool(toolData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final createState = ref.watch(createToolProvider);

    // Escuchar cambios de estado
    ref.listen<CreateToolState>(createToolProvider, (previous, next) {
      if (next is CreateToolSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Herramienta "${next.toolName}" creada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        // Refrescar la lista de inventario
        ref.invalidate(inventoryListProvider);
        context.pop();
      }
      if (next is CreateToolFailure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${next.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nueva Herramienta'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
      ),
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
                  labelText: 'Nombre de la Herramienta',
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
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la descripción';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: createState is CreateToolLoading
                    ? null
                    : _submitForm,
                child: createState is CreateToolLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text('Crear Herramienta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
