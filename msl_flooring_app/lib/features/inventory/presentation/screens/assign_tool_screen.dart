// lib/features/inventory/presentation/screens/assign_tool_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/inventory_item_entity.dart';
import '../../../worker/domain/entities/worker_entity.dart';
import '../../../worker/presentation/providers/worker_providers.dart';
import '../providers/tool_assignment_providers.dart';
import '../providers/inventory_providers.dart';

class AssignToolScreen extends ConsumerStatefulWidget {
  final InventoryItemEntity tool;

  const AssignToolScreen({required this.tool, super.key});

  @override
  ConsumerState<AssignToolScreen> createState() => _AssignToolScreenState();
}

class _AssignToolScreenState extends ConsumerState<AssignToolScreen> {
  final _formKey = GlobalKey<FormState>();
  WorkerEntity? _selectedWorker;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🔧 [AssignToolScreen] Fetching workers...');
      ref.read(workerListProvider.notifier).fetchWorkers();
    });
  }

  void _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Seleccionar fecha de devolución',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );

    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _submitAssignment() {
    if (_formKey.currentState!.validate() &&
        _selectedWorker != null &&
        _dueDate != null) {
      final dueDateFormatted = DateTime(
        _dueDate!.year,
        _dueDate!.month,
        _dueDate!.day,
        23,
        59,
        59,
      ).toUtc().toIso8601String();

      final assignmentData = {
        'toolId': widget.tool.id,
        'workerId': _selectedWorker!.id,
        'projectId': null,
        'dueDate': dueDateFormatted,
      };

      print('🔧 [AssignToolScreen] Submitting assignment: $assignmentData');
      ref.read(toolAssignmentProvider.notifier).assignTool(assignmentData);
    } else {
      String message = '';
      if (_selectedWorker == null)
        message = 'Por favor selecciona un trabajador';
      else if (_dueDate == null)
        message = 'Por favor selecciona una fecha de devolución';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final workersState = ref.watch(workerListProvider);
    final assignmentState = ref.watch(toolAssignmentProvider);

    ref.listen<ToolAssignmentState>(toolAssignmentProvider, (previous, next) {
      if (next is ToolAssignmentSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Herramienta asignada a ${_selectedWorker!.fullName} exitosamente',
            ),
            backgroundColor: Colors.green,
          ),
        );
        ref.invalidate(inventoryListProvider);
        context.pop();
      }
      if (next is ToolAssignmentFailure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${next.message}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 6),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Asignar Herramienta'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información de la herramienta
              Card(
                color: Colors.orange.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.orange,
                        child: Icon(Icons.handyman, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.tool.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.tool.description,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.green.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 14,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Disponible',
                                    style: TextStyle(
                                      color: Colors.green,
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

              const SizedBox(height: 24),

              // Selector de trabajador
              Text(
                'Seleccionar Trabajador',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),

              switch (workersState) {
                WorkerListLoading() => Container(
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(child: CircularProgressIndicator()),
                ),
                WorkerListSuccess(workers: final workers) => Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonFormField<WorkerEntity>(
                    value: _selectedWorker,
                    decoration: const InputDecoration(
                      hintText: 'Selecciona un trabajador',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      prefixIcon: Icon(Icons.person),
                    ),
                    isExpanded: true,
                    items: workers.map((worker) {
                      return DropdownMenuItem<WorkerEntity>(
                        value: worker,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.blue[100],
                              child: Text(
                                worker.firstName[0].toUpperCase(),
                                style: TextStyle(
                                  color: Colors.blue[800],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                worker.fullName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (WorkerEntity? worker) {
                      setState(() {
                        _selectedWorker = worker;
                      });
                      if (worker != null) {
                        print(
                          '🔧 [AssignToolScreen] Selected worker: ${worker.fullName} (${worker.id})',
                        );
                      }
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Por favor selecciona un trabajador';
                      }
                      return null;
                    },
                  ),
                ),
                WorkerListFailure(message: final message) => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Text('Error al cargar trabajadores'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          ref.read(workerListProvider.notifier).fetchWorkers();
                        },
                        icon: Icon(Icons.refresh, size: 16),
                        label: Text('Reintentar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          minimumSize: Size(0, 32),
                        ),
                      ),
                    ],
                  ),
                ),
                _ => const SizedBox(),
              },

              const SizedBox(height: 24),

              // Selector de fecha de devolución
              Text(
                'Fecha de Devolución',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),

              InkWell(
                onTap: _selectDueDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.grey[600]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _dueDate == null
                              ? 'Seleccionar fecha de devolución'
                              : 'Devolver el: ${_formatDate(_dueDate!)}',
                          style: TextStyle(
                            color: _dueDate == null
                                ? Colors.grey[600]
                                : Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: assignmentState is ToolAssignmentLoading
                          ? null
                          : () => context.pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: assignmentState is ToolAssignmentLoading
                          ? null
                          : _submitAssignment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: assignmentState is ToolAssignmentLoading
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
                          : const Text('Asignar Herramienta'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Información adicional simplificada
              if (_selectedWorker != null && _dueDate != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Colors.blue,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Resumen:',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '→ ${_selectedWorker!.fullName}',
                        style: const TextStyle(fontSize: 13),
                      ),
                      Text(
                        '→ Hasta: ${_formatDate(_dueDate!)}',
                        style: const TextStyle(fontSize: 13),
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
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
