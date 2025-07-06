// lib/features/inventory/presentation/screens/edit_material_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/inventory_item_entity.dart';
import '../providers/edit_material_providers.dart';
import '../providers/inventory_providers.dart';

class EditMaterialScreen extends ConsumerStatefulWidget {
  final InventoryItemEntity material;

  const EditMaterialScreen({required this.material, super.key});

  @override
  ConsumerState<EditMaterialScreen> createState() => _EditMaterialScreenState();
}

class _EditMaterialScreenState extends ConsumerState<EditMaterialScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    // Inicializar controladores con los valores actuales
    _nameController = TextEditingController(text: widget.material.name);
    _descriptionController = TextEditingController(
      text: widget.material.description,
    );
    _priceController = TextEditingController(
      text: widget.material.unitPrice.toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final updatedMaterialData = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'unitPrice': double.parse(_priceController.text),
      };

      // Llamar al provider para actualizar el material
      ref
          .read(editMaterialProvider.notifier)
          .updateMaterial(widget.material.id, updatedMaterialData);
    }
  }

  void _deleteMaterial() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Material'),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${widget.material.name}"?\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(editMaterialProvider.notifier)
                  .deleteMaterial(widget.material.id);
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
    final editState = ref.watch(editMaterialProvider);

    // Escuchar cambios de estado
    ref.listen<EditMaterialState>(editMaterialProvider, (previous, next) {
      if (next is EditMaterialUpdateSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Material "${next.materialName}" actualizado exitosamente',
            ),
            backgroundColor: Colors.green,
          ),
        );
        // Refrescar la lista de inventario
        ref.invalidate(inventoryListProvider);
        context.pop();
      }
      if (next is EditMaterialDeleteSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Material "${next.materialName}" eliminado exitosamente',
            ),
            backgroundColor: Colors.green,
          ),
        );
        // Refrescar la lista de inventario
        ref.invalidate(inventoryListProvider);
        context.pop();
      }
      if (next is EditMaterialFailure) {
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
        title: const Text('Editar Material'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: editState is EditMaterialLoading
                ? null
                : _deleteMaterial,
            tooltip: 'Eliminar Material',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Información del material actual
              Card(
                color: Colors.blue.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Editando: ${widget.material.name}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.blue[700],
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
                  labelText: 'Nombre del Material',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory),
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
              const SizedBox(height: 16),

              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Precio por Unidad',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
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
                  if (double.parse(value) <= 0) {
                    return 'El precio debe ser mayor a 0';
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
                      onPressed: editState is EditMaterialLoading
                          ? null
                          : () => context.pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: editState is EditMaterialLoading
                          ? null
                          : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: editState is EditMaterialLoading
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
                          : const Text('Actualizar Material'),
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
                      Text('ID: ${widget.material.id}'),
                      Text('Cantidad actual: ${widget.material.quantity}'),
                      Text(
                        'Valor total actual: \$${widget.material.totalValue.toStringAsFixed(2)}',
                      ),
                      Text('Creado: ${_formatDate(widget.material.createdAt)}'),
                      Text(
                        'Actualizado: ${_formatDate(widget.material.updatedAt)}',
                      ),
                    ],
                  ),
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
