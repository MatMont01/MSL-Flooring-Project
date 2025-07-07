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

class _AssignToolScreenState extends ConsumerState<AssignToolScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  WorkerEntity? _selectedWorker;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();

    // 🎭 Configurar animaciones
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutQuart),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Cargar trabajadores y iniciar animaciones
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(workerListProvider.notifier).fetchWorkers();
      _fadeController.forward();
      _slideController.forward();
      _scaleController.forward();
      _pulseController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workersState = ref.watch(workerListProvider);
    final assignmentState = ref.watch(toolAssignmentProvider);

    // Escuchar cambios de estado
    ref.listen<ToolAssignmentState>(toolAssignmentProvider, (previous, next) {
      if (next is ToolAssignmentSuccess) {
        _showModernSnackBar(
          'Tool assigned to ${_selectedWorker!.fullName} successfully',
          const Color(0xFF32D74B),
        );
        ref.invalidate(inventoryListProvider);
        context.pop();
      }
      if (next is ToolAssignmentFailure) {
        _showModernSnackBar('Error: ${next.message}', const Color(0xFFFF453A));
      }
    });

    return Theme(
      data: _buildDarkTheme(),
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F14),
        body: Container(
          decoration: _buildBackgroundDecoration(),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildContent(workersState, assignmentState),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🌙 Tema oscuro minimalista
  ThemeData _buildDarkTheme() {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color(0xFF0F0F14),
      cardTheme: CardThemeData(
        color: const Color(0xFF1A1A1F).withOpacity(0.9),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: const Color(0xFF2A2A2F).withOpacity(0.6),
            width: 1,
          ),
        ),
      ),
    );
  }

  // 🌌 Decoración de fondo
  BoxDecoration _buildBackgroundDecoration() {
    return const BoxDecoration(
      gradient: RadialGradient(
        center: Alignment.topRight,
        radius: 1.5,
        colors: [Color(0xFF1A1A1F), Color(0xFF0F0F14)],
        stops: [0.0, 1.0],
      ),
    );
  }

  Widget _buildContent(
    WorkerListState workersState,
    ToolAssignmentState assignmentState,
  ) {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(),
        SliverPadding(
          padding: const EdgeInsets.all(24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildToolCard(),
              const SizedBox(height: 32),
              _buildWorkerSelection(workersState),
              const SizedBox(height: 32),
              _buildDateSelection(),
              const SizedBox(height: 32),
              if (_selectedWorker != null && _dueDate != null) ...[
                _buildAssignmentSummary(),
                const SizedBox(height: 32),
              ],
              _buildActionButtons(assignmentState),
              const SizedBox(height: 32),
              _buildInfoCard(),
            ]),
          ),
        ),
      ],
    );
  }

  // 📱 SliverAppBar moderno
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: _buildBackButton(),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A1A1F).withOpacity(0.95),
              const Color(0xFF2A2A2F).withOpacity(0.90),
            ],
          ),
          border: Border(
            bottom: BorderSide(
              color: const Color(0xFF2A2A2F).withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        child: const FlexibleSpaceBar(
          title: Text(
            'Assign Tool',
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 20,
              color: Color(0xFFE5E5E7),
              letterSpacing: 0.5,
            ),
          ),
          centerTitle: true,
        ),
      ),
    );
  }

  // ← Botón de regreso
  Widget _buildBackButton() {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF2A2A2F).withOpacity(0.6),
        border: Border.all(
          color: const Color(0xFF3A3A3F).withOpacity(0.4),
          width: 1,
        ),
      ),
      child: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Color(0xFFE5E5E7),
          size: 18,
        ),
        onPressed: () => context.pop(),
      ),
    );
  }

  // 🔧 Card de herramienta
  Widget _buildToolCard() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFF9F0A).withOpacity(0.1),
              const Color(0xFFFF9F0A).withOpacity(0.05),
            ],
          ),
          border: Border.all(
            color: const Color(0xFFFF9F0A).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFFF9F0A).withOpacity(0.8),
                          const Color(0xFFFF9F0A).withOpacity(0.6),
                        ],
                      ),
                      border: Border.all(
                        color: const Color(0xFFFF9F0A).withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.handyman_outlined,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.tool.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFE5E5E7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.tool.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF32D74B).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF32D74B).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF32D74B),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Available',
                          style: TextStyle(
                            color: Color(0xFF32D74B),
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
    );
  }

  // 👤 Selección de trabajador
  Widget _buildWorkerSelection(WorkerListState workersState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Select Worker'),
        const SizedBox(height: 20),
        _buildWorkerDropdown(workersState),
      ],
    );
  }

  Widget _buildWorkerDropdown(WorkerListState workersState) {
    return switch (workersState) {
      WorkerListLoading() => _buildLoadingContainer(),
      WorkerListSuccess(workers: final workers) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF1A1A1F).withOpacity(0.8),
          border: Border.all(
            color: const Color(0xFF2A2A2F).withOpacity(0.6),
            width: 1,
          ),
        ),
        child: DropdownButtonFormField<WorkerEntity>(
          value: _selectedWorker,
          decoration: const InputDecoration(
            hintText: 'Select a worker',
            hintStyle: TextStyle(color: Color(0xFF8E8E93), fontSize: 14),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            prefixIcon: Icon(
              Icons.person_outline,
              color: Color(0xFF8E8E93),
              size: 20,
            ),
          ),
          style: const TextStyle(color: Color(0xFFE5E5E7), fontSize: 16),
          dropdownColor: const Color(0xFF1A1A1F),
          isExpanded: true,
          items: workers.map((worker) {
            return DropdownMenuItem<WorkerEntity>(
              value: worker,
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF007AFF).withOpacity(0.2),
                      border: Border.all(
                        color: const Color(0xFF007AFF).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        worker.firstName[0].toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF007AFF),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          worker.fullName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFE5E5E7),
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          worker.email,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF8E8E93),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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
          },
          validator: (value) {
            if (value == null) {
              return 'Please select a worker';
            }
            return null;
          },
        ),
      ),
      WorkerListFailure(message: final message) => _buildErrorContainer(
        message,
      ),
      _ => const SizedBox(),
    };
  }

  Widget _buildLoadingContainer() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF1A1A1F).withOpacity(0.8),
        border: Border.all(
          color: const Color(0xFF2A2A2F).withOpacity(0.6),
          width: 1,
        ),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8E8E93)),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorContainer(String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFFFF453A).withOpacity(0.1),
        border: Border.all(
          color: const Color(0xFFFF453A).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.error_outline,
                color: Color(0xFFFF453A),
                size: 20,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Error loading workers',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFE5E5E7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(fontSize: 14, color: Color(0xFF8E8E93)),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: _buildModernButton(
              'Retry',
              () => ref.read(workerListProvider.notifier).fetchWorkers(),
              isSecondary: true,
            ),
          ),
        ],
      ),
    );
  }

  // 📅 Selección de fecha
  Widget _buildDateSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Return Date'),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: _selectDueDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFF1A1A1F).withOpacity(0.8),
              border: Border.all(
                color: _dueDate != null
                    ? const Color(0xFF32D74B).withOpacity(0.3)
                    : const Color(0xFF2A2A2F).withOpacity(0.6),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  color: _dueDate != null
                      ? const Color(0xFF32D74B)
                      : const Color(0xFF8E8E93),
                  size: 20,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _dueDate == null
                        ? 'Select return date'
                        : 'Return on: ${_formatDate(_dueDate!)}',
                    style: TextStyle(
                      color: _dueDate != null
                          ? const Color(0xFFE5E5E7)
                          : const Color(0xFF8E8E93),
                      fontSize: 16,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: const Color(0xFF8E8E93),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 📋 Resumen de asignación
  Widget _buildAssignmentSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF007AFF).withOpacity(0.1),
        border: Border.all(
          color: const Color(0xFF007AFF).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFF007AFF).withOpacity(0.2),
                ),
                child: const Icon(
                  Icons.summarize_outlined,
                  color: Color(0xFF007AFF),
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Assignment Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFE5E5E7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Worker', _selectedWorker!.fullName),
          const SizedBox(height: 8),
          _buildSummaryRow('Email', _selectedWorker!.email),
          const SizedBox(height: 8),
          _buildSummaryRow('Return Date', _formatDate(_dueDate!)),
          const SizedBox(height: 8),
          _buildSummaryRow('Tool', widget.tool.name),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF007AFF),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 14),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFFE5E5E7),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // 🔘 Botones de acción
  Widget _buildActionButtons(ToolAssignmentState assignmentState) {
    return Row(
      children: [
        Expanded(
          child: _buildModernButton(
            'Cancel',
            assignmentState is ToolAssignmentLoading
                ? null
                : () => context.pop(),
            isSecondary: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: _buildModernButton(
            assignmentState is ToolAssignmentLoading
                ? 'Assigning...'
                : 'Assign Tool',
            assignmentState is ToolAssignmentLoading ? null : _submitAssignment,
            isLoading: assignmentState is ToolAssignmentLoading,
          ),
        ),
      ],
    );
  }

  Widget _buildModernButton(
    String text,
    VoidCallback? onPressed, {
    bool isSecondary = false,
    bool isLoading = false,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: !isSecondary && onPressed != null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFFF9F0A).withOpacity(0.8),
                  const Color(0xFFFF9F0A).withOpacity(0.6),
                ],
              )
            : null,
        color: isSecondary
            ? const Color(0xFF2A2A2F).withOpacity(0.6)
            : onPressed == null
            ? const Color(0xFF2A2A2F).withOpacity(0.4)
            : null,
        border: Border.all(
          color: isSecondary
              ? const Color(0xFF3A3A3F).withOpacity(0.6)
              : onPressed != null
              ? const Color(0xFFFF9F0A).withOpacity(0.4)
              : const Color(0xFF2A2A2F).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  color: isSecondary ? const Color(0xFF8E8E93) : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  // ℹ️ Card de información
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFFAF52DE).withOpacity(0.1),
        border: Border.all(
          color: const Color(0xFFAF52DE).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFFAF52DE).withOpacity(0.2),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Color(0xFFAF52DE),
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Assignment Guidelines',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Color(0xFFE5E5E7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoItem('• Worker will be responsible for the tool'),
          _buildInfoItem('• Tool must be returned by the specified date'),
          _buildInfoItem('• Assignment can be tracked in worker records'),
          _buildInfoItem('• Late returns may affect future assignments'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, color: Color(0xFF8E8E93)),
      ),
    );
  }

  // 🏷️ Título de sección
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: Color(0xFFE5E5E7),
        letterSpacing: 0.3,
      ),
    );
  }

  // 🔧 Métodos de utilidad
  void _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Select return date',
      cancelText: 'Cancel',
      confirmText: 'Confirm',
      builder: (context, child) {
        return Theme(
          data: _buildDarkTheme().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFF9F0A),
              onPrimary: Colors.white,
              surface: Color(0xFF1A1A1F),
              onSurface: Color(0xFFE5E5E7),
            ),
            dialogBackgroundColor: const Color(0xFF1A1A1F),
          ),
          child: child!,
        );
      },
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

      ref.read(toolAssignmentProvider.notifier).assignTool(assignmentData);
    } else {
      String message = '';
      if (_selectedWorker == null) {
        message = 'Please select a worker';
      } else if (_dueDate == null) {
        message = 'Please select a return date';
      }

      _showModernSnackBar(message, const Color(0xFFFF9F0A));
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _showModernSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                color == const Color(0xFF32D74B)
                    ? Icons.check_circle_outline
                    : color == const Color(0xFFFF453A)
                    ? Icons.error_outline
                    : Icons.warning_outlined,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
  }
}
