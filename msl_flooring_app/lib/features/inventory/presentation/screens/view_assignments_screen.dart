// lib/features/inventory/presentation/screens/view_assignments_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/inventory_item_entity.dart';
import '../providers/assignment_list_providers.dart';

class ViewAssignmentsScreen extends ConsumerStatefulWidget {
  final InventoryItemEntity item;

  const ViewAssignmentsScreen({required this.item, super.key});

  @override
  ConsumerState<ViewAssignmentsScreen> createState() =>
      _ViewAssignmentsScreenState();
}

class _ViewAssignmentsScreenState extends ConsumerState<ViewAssignmentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.item.category.toLowerCase() == 'material') {
        print(
          '🔍 [ViewAssignments] Loading material movements for: ${widget.item.id}',
        );
        ref
            .read(materialMovementsProvider.notifier)
            .fetchMovements(widget.item.id);
      } else {
        print(
          '🔍 [ViewAssignments] Loading tool assignments for: ${widget.item.id}',
        );
        ref
            .read(toolAssignmentsListProvider.notifier)
            .fetchAssignments(widget.item.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isMaterial = widget.item.category.toLowerCase() == 'material';

    return Scaffold(
      appBar: AppBar(
        title: Text('Asignaciones - ${widget.item.name}'),
        backgroundColor: isMaterial ? Colors.blue : Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (isMaterial) {
                ref
                    .read(materialMovementsProvider.notifier)
                    .fetchMovements(widget.item.id);
              } else {
                ref
                    .read(toolAssignmentsListProvider.notifier)
                    .fetchAssignments(widget.item.id);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con información del item
            Card(
              color: (isMaterial ? Colors.blue : Colors.orange).withOpacity(
                0.1,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: isMaterial ? Colors.blue : Colors.orange,
                      child: Icon(
                        isMaterial ? Icons.build_outlined : Icons.handyman,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.item.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.item.description,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      (isMaterial ? Colors.blue : Colors.orange)
                                          .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  widget.item.category,
                                  style: TextStyle(
                                    color: isMaterial
                                        ? Colors.blue
                                        : Colors.orange,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (isMaterial) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Stock: ${widget.item.quantity}',
                                    style: TextStyle(
                                      color: Colors.green[700],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Lista de asignaciones
            Text(
              isMaterial
                  ? 'Movimientos de Material'
                  : 'Asignaciones de Herramienta',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: isMaterial
                  ? _buildMaterialMovements()
                  : _buildToolAssignments(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialMovements() {
    final movementsState = ref.watch(materialMovementsProvider);

    return switch (movementsState) {
      MaterialMovementsLoading() => const Center(
        child: CircularProgressIndicator(),
      ),
      MaterialMovementsSuccess(movements: final movements) =>
        movements.isEmpty
            ? _buildEmptyState(
                'No hay movimientos registrados para este material',
                Icons.swap_horiz,
              )
            : RefreshIndicator(
                onRefresh: () async {
                  ref
                      .read(materialMovementsProvider.notifier)
                      .fetchMovements(widget.item.id);
                },
                child: ListView.builder(
                  itemCount: movements.length,
                  itemBuilder: (context, index) {
                    final movement = movements[index];
                    final isOut = movement['movementType'] == 'OUT';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isOut
                              ? Colors.red[100]
                              : Colors.green[100],
                          child: Icon(
                            isOut ? Icons.arrow_upward : Icons.arrow_downward,
                            color: isOut ? Colors.red : Colors.green,
                          ),
                        ),
                        title: Text(
                          isOut
                              ? 'Asignado a proyecto'
                              : 'Entrada al inventario',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Cantidad: ${movement['quantity']} unidades'),
                            if (movement['projectId'] != null)
                              Text('Proyecto: ${movement['projectId']}'),
                            Text(
                              'Fecha: ${_formatDateTime(movement['movementDate'])}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isOut
                                ? Colors.red.withOpacity(0.1)
                                : Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isOut ? 'SALIDA' : 'ENTRADA',
                            style: TextStyle(
                              color: isOut ? Colors.red : Colors.green,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      MaterialMovementsFailure(message: final message) => _buildErrorState(
        message,
        () {
          ref
              .read(materialMovementsProvider.notifier)
              .fetchMovements(widget.item.id);
        },
      ),
      _ => const SizedBox(),
    };
  }

  Widget _buildToolAssignments() {
    final assignmentsState = ref.watch(toolAssignmentsListProvider);

    return switch (assignmentsState) {
      ToolAssignmentsLoading() => const Center(
        child: CircularProgressIndicator(),
      ),
      ToolAssignmentsSuccess(assignments: final assignments) =>
        assignments.isEmpty
            ? _buildEmptyState(
                'Esta herramienta no ha sido asignada aún',
                Icons.handyman,
              )
            : RefreshIndicator(
                onRefresh: () async {
                  ref
                      .read(toolAssignmentsListProvider.notifier)
                      .fetchAssignments(widget.item.id);
                },
                child: ListView.builder(
                  itemCount: assignments.length,
                  itemBuilder: (context, index) {
                    final assignment = assignments[index];
                    final isReturned = assignment['returnedAt'] != null;
                    final isOverdue =
                        !isReturned &&
                        assignment['dueDate'] != null &&
                        DateTime.parse(
                          assignment['dueDate'],
                        ).isBefore(DateTime.now());

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isReturned
                              ? Colors.grey[300]
                              : isOverdue
                              ? Colors.red[100]
                              : Colors.orange[100],
                          child: Icon(
                            isReturned
                                ? Icons.check_circle
                                : isOverdue
                                ? Icons.warning
                                : Icons.person,
                            color: isReturned
                                ? Colors.grey
                                : isOverdue
                                ? Colors.red
                                : Colors.orange,
                          ),
                        ),
                        title: Text(
                          isReturned
                              ? 'Devuelta'
                              : isOverdue
                              ? 'Vencida'
                              : 'Asignada a trabajador',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Trabajador: ${assignment['workerId']}'),
                            Text(
                              'Asignada: ${_formatDateTime(assignment['assignedAt'])}',
                            ),
                            if (assignment['dueDate'] != null)
                              Text(
                                'Vence: ${_formatDateTime(assignment['dueDate'])}',
                                style: TextStyle(
                                  color: isOverdue ? Colors.red : null,
                                  fontWeight: isOverdue
                                      ? FontWeight.w500
                                      : null,
                                ),
                              ),
                            if (isReturned)
                              Text(
                                'Devuelta: ${_formatDateTime(assignment['returnedAt'])}',
                                style: TextStyle(color: Colors.green[700]),
                              ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isReturned
                                ? Colors.grey.withOpacity(0.2)
                                : isOverdue
                                ? Colors.red.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isReturned
                                ? 'DEVUELTA'
                                : isOverdue
                                ? 'VENCIDA'
                                : 'ACTIVA',
                            style: TextStyle(
                              color: isReturned
                                  ? Colors.grey
                                  : isOverdue
                                  ? Colors.red
                                  : Colors.orange,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ToolAssignmentsFailure(message: final message) => _buildErrorState(
        message,
        () {
          ref
              .read(toolAssignmentsListProvider.notifier)
              .fetchAssignments(widget.item.id);
        },
      ),
      _ => const SizedBox(),
    };
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Volver al inventario'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error al cargar asignaciones',
            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeStr;
    }
  }
}
