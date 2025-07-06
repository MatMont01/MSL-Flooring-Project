// lib/features/inventory/presentation/screens/assign_material_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/inventory_item_entity.dart';
import '../../../projects/domain/entities/project_entity.dart';
import '../../../projects/presentation/providers/project_providers.dart';
import '../providers/material_assignment_providers.dart'; // 🔧 SOLO ESTE IMPORT
import '../providers/inventory_providers.dart';

class AssignMaterialScreen extends ConsumerStatefulWidget {
  final InventoryItemEntity material;

  const AssignMaterialScreen({required this.material, super.key});

  @override
  ConsumerState<AssignMaterialScreen> createState() =>
      _AssignMaterialScreenState();
}

class _AssignMaterialScreenState extends ConsumerState<AssignMaterialScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  ProjectEntity? _selectedProject;

  @override
  void initState() {
    super.initState();
    // 🔧 CARGAR PROYECTOS AL INICIAR LA PANTALLA
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🔧 [AssignMaterialScreen] Fetching projects...');
      ref.read(projectListProvider.notifier).fetchProjects();
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _submitAssignment() {
    if (_formKey.currentState!.validate() && _selectedProject != null) {
      final assignmentData = {
        'materialId': widget.material.id,
        'projectId': _selectedProject!.id,
        'quantity': int.parse(_quantityController.text),
        'movementType': 'OUT',
      };

      print('🔧 [AssignMaterialScreen] Submitting assignment: $assignmentData');
      ref
          .read(materialAssignmentProvider.notifier)
          .assignMaterial(assignmentData);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona un proyecto')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectsState = ref.watch(projectListProvider);
    final assignmentState = ref.watch(materialAssignmentProvider);

    // Escuchar cambios de estado
    ref.listen<MaterialAssignmentState>(materialAssignmentProvider, (
      previous,
      next,
    ) {
      if (next is MaterialAssignmentSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Material asignado al proyecto exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        ref.invalidate(inventoryListProvider);
        context.pop();
      }
      if (next is MaterialAssignmentFailure) {
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
        title: const Text('Asignar Material'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          // 🔧 AÑADIR SCROLL
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información del material
              Card(
                color: Colors.blue.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.build_outlined, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.material.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Disponible: ${widget.material.quantity} unidades',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Precio: \$${widget.material.unitPrice.toStringAsFixed(2)}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Selector de proyecto
              Text(
                'Seleccionar Proyecto',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),

              switch (projectsState) {
                ProjectListLoading() => Container(
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(child: CircularProgressIndicator()),
                ),
                ProjectListSuccess(projects: final projects) => Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonFormField<ProjectEntity>(
                    value: _selectedProject,
                    decoration: const InputDecoration(
                      hintText: 'Selecciona un proyecto',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      prefixIcon: Icon(Icons.business_center),
                    ),
                    isExpanded: true,
                    // 🔧 IMPORTANTE: Permite que el dropdown use todo el ancho
                    items: projects.map((project) {
                      return DropdownMenuItem<ProjectEntity>(
                        value: project,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              project.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              project.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (ProjectEntity? project) {
                      setState(() {
                        _selectedProject = project;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Por favor selecciona un proyecto';
                      }
                      return null;
                    },
                  ),
                ),
                ProjectListFailure(message: final message) => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Error al cargar proyectos'),
                            Text(
                              message,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () {
                                ref
                                    .read(projectListProvider.notifier)
                                    .fetchProjects();
                              },
                              icon: Icon(Icons.refresh, size: 16),
                              label: Text('Reintentar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                minimumSize: Size(0, 30),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                _ => const SizedBox(),
              },

              const SizedBox(height: 24),

              // Campo de cantidad
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Cantidad a asignar',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                  suffixText: 'unidades',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la cantidad';
                  }
                  final quantity = int.tryParse(value);
                  if (quantity == null || quantity <= 0) {
                    return 'Por favor ingresa una cantidad válida';
                  }
                  if (quantity > widget.material.quantity) {
                    return 'Cantidad no puede ser mayor a ${widget.material.quantity}';
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
                      onPressed: assignmentState is MaterialAssignmentLoading
                          ? null
                          : () => context.pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: assignmentState is MaterialAssignmentLoading
                          ? null
                          : _submitAssignment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: assignmentState is MaterialAssignmentLoading
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
                          : const Text('Asignar Material'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Información adicional
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.amber),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Información importante:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '• Esta asignación reducirá el stock disponible',
                            style: TextStyle(fontSize: 12),
                          ),
                          const Text(
                            '• El material será enviado al proyecto seleccionado',
                            style: TextStyle(fontSize: 12),
                          ),
                          Text(
                            '• Costo total: \$${_calculateTotalCost()}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
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

  String _calculateTotalCost() {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final total = quantity * widget.material.unitPrice;
    return total.toStringAsFixed(2);
  }
}
