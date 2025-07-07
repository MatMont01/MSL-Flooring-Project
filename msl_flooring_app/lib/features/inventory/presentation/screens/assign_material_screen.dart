// lib/features/inventory/presentation/screens/assign_material_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/inventory_item_entity.dart';
import '../../../projects/domain/entities/project_entity.dart';
import '../../../projects/presentation/providers/project_providers.dart';
import '../providers/material_assignment_providers.dart';
import '../providers/inventory_providers.dart';

class AssignMaterialScreen extends ConsumerStatefulWidget {
  final InventoryItemEntity material;

  const AssignMaterialScreen({required this.material, super.key});

  @override
  ConsumerState<AssignMaterialScreen> createState() =>
      _AssignMaterialScreenState();
}

class _AssignMaterialScreenState extends ConsumerState<AssignMaterialScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _quantityFocus = FocusNode();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  ProjectEntity? _selectedProject;

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

    // Cargar proyectos y iniciar animaciones
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(projectListProvider.notifier).fetchProjects();
      _fadeController.forward();
      _slideController.forward();
      _scaleController.forward();
    });

    // Listener para calcular costo en tiempo real
    _quantityController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _quantityController.dispose();
    _quantityFocus.dispose();
    super.dispose();
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
        _showModernSnackBar(
          'Material assigned to project successfully',
          const Color(0xFF32D74B),
        );
        ref.invalidate(inventoryListProvider);
        context.pop();
      }
      if (next is MaterialAssignmentFailure) {
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
                child: _buildContent(projectsState, assignmentState),
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
        center: Alignment.topLeft,
        radius: 1.5,
        colors: [Color(0xFF1A1A1F), Color(0xFF0F0F14)],
        stops: [0.0, 1.0],
      ),
    );
  }

  Widget _buildContent(
    ProjectListState projectsState,
    MaterialAssignmentState assignmentState,
  ) {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(),
        SliverPadding(
          padding: const EdgeInsets.all(24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildMaterialCard(),
              const SizedBox(height: 32),
              _buildProjectSelection(projectsState),
              const SizedBox(height: 32),
              _buildQuantityInput(),
              const SizedBox(height: 32),
              _buildCostCalculator(),
              const SizedBox(height: 32),
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
            'Assign Material',
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

  // 📦 Card de material
  Widget _buildMaterialCard() {
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
              const Color(0xFF007AFF).withOpacity(0.1),
              const Color(0xFF007AFF).withOpacity(0.05),
            ],
          ),
          border: Border.all(
            color: const Color(0xFF007AFF).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF007AFF).withOpacity(0.8),
                    const Color(0xFF007AFF).withOpacity(0.6),
                  ],
                ),
                border: Border.all(
                  color: const Color(0xFF007AFF).withOpacity(0.4),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.build_outlined,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.material.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFE5E5E7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildMaterialInfo(
                    'Available',
                    '${widget.material.quantity} units',
                    const Color(0xFF32D74B),
                  ),
                  const SizedBox(height: 4),
                  _buildMaterialInfo(
                    'Unit Price',
                    '\$${widget.material.unitPrice.toStringAsFixed(2)}',
                    const Color(0xFF8E8E93),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialInfo(String label, String value, Color color) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 14, color: Color(0xFF8E8E93)),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  // 🏗️ Selección de proyecto
  Widget _buildProjectSelection(ProjectListState projectsState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Select Project'),
        const SizedBox(height: 20),
        _buildProjectDropdown(projectsState),
      ],
    );
  }

  Widget _buildProjectDropdown(ProjectListState projectsState) {
    return switch (projectsState) {
      ProjectListLoading() => _buildLoadingContainer(),
      ProjectListSuccess(projects: final projects) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF1A1A1F).withOpacity(0.8),
          border: Border.all(
            color: const Color(0xFF2A2A2F).withOpacity(0.6),
            width: 1,
          ),
        ),
        child: DropdownButtonFormField<ProjectEntity>(
          value: _selectedProject,
          decoration: const InputDecoration(
            hintText: 'Select a project',
            hintStyle: TextStyle(color: Color(0xFF8E8E93), fontSize: 14),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            prefixIcon: Icon(
              Icons.business_center_outlined,
              color: Color(0xFF8E8E93),
              size: 20,
            ),
          ),
          style: const TextStyle(color: Color(0xFFE5E5E7), fontSize: 16),
          dropdownColor: const Color(0xFF1A1A1F),
          isExpanded: true,
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
                      color: Color(0xFFE5E5E7),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    project.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8E8E93),
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
              return 'Please select a project';
            }
            return null;
          },
        ),
      ),
      ProjectListFailure(message: final message) => _buildErrorContainer(
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
                  'Error loading projects',
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
              () => ref.read(projectListProvider.notifier).fetchProjects(),
              isSecondary: true,
            ),
          ),
        ],
      ),
    );
  }

  // 🔢 Input de cantidad
  Widget _buildQuantityInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Quantity to Assign'),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: const Color(0xFF1A1A1F).withOpacity(0.8),
            border: Border.all(
              color: const Color(0xFF2A2A2F).withOpacity(0.6),
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: _quantityController,
            focusNode: _quantityFocus,
            style: const TextStyle(color: Color(0xFFE5E5E7), fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Enter quantity',
              hintStyle: TextStyle(
                color: const Color(0xFF8E8E93).withOpacity(0.8),
                fontSize: 14,
              ),
              prefixIcon: const Icon(
                Icons.numbers_outlined,
                color: Color(0xFF8E8E93),
                size: 20,
              ),
              suffixText: 'units',
              suffixStyle: const TextStyle(
                color: Color(0xFF8E8E93),
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter quantity';
              }
              final quantity = int.tryParse(value);
              if (quantity == null || quantity <= 0) {
                return 'Please enter a valid quantity';
              }
              if (quantity > widget.material.quantity) {
                return 'Quantity cannot exceed ${widget.material.quantity}';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  // 💰 Calculadora de costos
  Widget _buildCostCalculator() {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final totalCost = quantity * widget.material.unitPrice;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: quantity > 0
            ? const Color(0xFF32D74B).withOpacity(0.1)
            : const Color(0xFF2A2A2F).withOpacity(0.4),
        border: Border.all(
          color: quantity > 0
              ? const Color(0xFF32D74B).withOpacity(0.3)
              : const Color(0xFF3A3A3F).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: quantity > 0
                      ? const Color(0xFF32D74B).withOpacity(0.2)
                      : const Color(0xFF8E8E93).withOpacity(0.2),
                ),
                child: Icon(
                  Icons.calculate_outlined,
                  color: quantity > 0
                      ? const Color(0xFF32D74B)
                      : const Color(0xFF8E8E93),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Cost Calculation',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFE5E5E7),
                  ),
                ),
              ),
            ],
          ),
          if (quantity > 0) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Unit Price:',
                  style: TextStyle(color: Color(0xFF8E8E93), fontSize: 14),
                ),
                Text(
                  '\$${widget.material.unitPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color(0xFFE5E5E7),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Quantity:',
                  style: TextStyle(color: Color(0xFF8E8E93), fontSize: 14),
                ),
                Text(
                  '$quantity units',
                  style: const TextStyle(
                    color: Color(0xFFE5E5E7),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 1,
              color: const Color(0xFF32D74B).withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Cost:',
                  style: TextStyle(
                    color: Color(0xFFE5E5E7),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '\$${totalCost.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color(0xFF32D74B),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // 🔘 Botones de acción
  Widget _buildActionButtons(MaterialAssignmentState assignmentState) {
    return Row(
      children: [
        Expanded(
          child: _buildModernButton(
            'Cancel',
            assignmentState is MaterialAssignmentLoading
                ? null
                : () => context.pop(),
            isSecondary: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: _buildModernButton(
            assignmentState is MaterialAssignmentLoading
                ? 'Assigning...'
                : 'Assign Material',
            assignmentState is MaterialAssignmentLoading
                ? null
                : _submitAssignment,
            isLoading: assignmentState is MaterialAssignmentLoading,
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
                  const Color(0xFF007AFF).withOpacity(0.8),
                  const Color(0xFF007AFF).withOpacity(0.6),
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
              ? const Color(0xFF007AFF).withOpacity(0.4)
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
        color: const Color(0xFFFF9F0A).withOpacity(0.1),
        border: Border.all(
          color: const Color(0xFFFF9F0A).withOpacity(0.3),
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
                  color: const Color(0xFFFF9F0A).withOpacity(0.2),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Color(0xFFFF9F0A),
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Important information:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Color(0xFFE5E5E7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoItem('• This assignment will reduce available stock'),
          _buildInfoItem('• Material will be sent to selected project'),
          _buildInfoItem('• Assignment cannot be undone automatically'),
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
  void _submitAssignment() {
    if (_formKey.currentState!.validate() && _selectedProject != null) {
      final assignmentData = {
        'materialId': widget.material.id,
        'projectId': _selectedProject!.id,
        'quantity': int.parse(_quantityController.text),
        'movementType': 'OUT',
      };

      ref
          .read(materialAssignmentProvider.notifier)
          .assignMaterial(assignmentData);
    } else {
      _showModernSnackBar('Please select a project', const Color(0xFFFF9F0A));
    }
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
