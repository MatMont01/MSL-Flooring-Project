// lib/features/inventory/presentation/screens/edit_tool_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/inventory_item_entity.dart';
import '../providers/edit_tool_providers.dart';
import '../providers/inventory_providers.dart';

class EditToolScreen extends ConsumerStatefulWidget {
  final InventoryItemEntity tool;

  const EditToolScreen({required this.tool, super.key});

  @override
  ConsumerState<EditToolScreen> createState() => _EditToolScreenState();
}

class _EditToolScreenState extends ConsumerState<EditToolScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    // Inicializar controladores con los valores actuales
    _nameController = TextEditingController(text: widget.tool.name);
    _descriptionController = TextEditingController(
      text: widget.tool.description,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final updatedToolData = {
        'name': _nameController.text,
        'description': _descriptionController.text,
      };

      // Llamar al provider para actualizar la herramienta
      ref
          .read(editToolProvider.notifier)
          .updateTool(widget.tool.id, updatedToolData);
    }
  }

  void _deleteTool() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Herramienta'),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${widget.tool.name}"?\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(editToolProvider.notifier).deleteTool(widget.tool.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editState = ref.watch(editToolProvider);

    // Escuchar cambios de estado
    ref.listen<EditToolState>(editToolProvider, (previous, next) {
      if (next is EditToolUpdateSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Herramienta "${next.toolName}" actualizada exitosamente',
            ),
            backgroundColor: Colors.green,
          ),
        );
        // Refrescar la lista de inventario
        ref.invalidate(inventoryListProvider);
        context.pop();
      }
      if (next is EditToolDeleteSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Herramienta "${next.toolName}" eliminada exitosamente',
            ),
            backgroundColor: Colors.green,
          ),
        );
        // Refrescar la lista de inventario
        ref.invalidate(inventoryListProvider);
        context.pop();
      }
      if (next is EditToolFailure) {
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
        title: const Text('Editar Herramienta'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: editState is EditToolLoading ? null : _deleteTool,
            tooltip: 'Eliminar Herramienta',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Información de la herramienta actual
              Card(
                color: Colors.orange.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.handyman, color: Colors.orange[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Editando: ${widget.tool.name}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.orange[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Formulario de edición
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la Herramienta',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.handyman),
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
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la descripción';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: editState is EditToolLoading
                          ? null
                          : () => context.pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: editState is EditToolLoading
                          ? null
                          : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: editState is EditToolLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text('Actualizar Herramienta'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Información adicional
              Card(
                color: Colors.grey.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información Adicional',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('ID: ${widget.tool.id}'),
                      Text('Tipo: ${widget.tool.category}'),
                      Text('Cantidad: ${widget.tool.quantity}'),
                      Text('Creado: ${_formatDate(widget.tool.createdAt)}'),
                      Text(
                        'Actualizado: ${_formatDate(widget.tool.updatedAt)}',
                      ),
                      const SizedBox(height: 8),
                      // Información sobre asignaciones (placeholder)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Colors.blue,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Estado: Disponible',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Nota informativa
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_outlined, color: Colors.amber),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Nota: Al eliminar una herramienta, se removerán todas las asignaciones asociadas.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
