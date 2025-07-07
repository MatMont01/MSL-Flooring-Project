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

class _CreateMaterialScreenState extends ConsumerState<CreateMaterialScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  final _nameFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  final _priceFocus = FocusNode();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _successController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _successAnimation;

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

    _successController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutQuart,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _successAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successController,
      curve: Curves.easeOutBack,
    ));

    // Iniciar animaciones
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fadeController.forward();
      _slideController.forward();
      _scaleController.forward();
    });

    // Listener para calcular precio en tiempo real
    _priceController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _successController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _nameFocus.dispose();
    _descriptionFocus.dispose();
    _priceFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final createState = ref.watch(createMaterialProvider);

    // Escuchar cambios de estado
    ref.listen<CreateMaterialState>(createMaterialProvider, (previous, next) {
      if (next is CreateMaterialSuccess) {
        _successController.forward().then((_) {
          _showModernSnackBar(
            'Material "${next.materialName}" created successfully',
            const Color(0xFF32D74B),
          );
          ref.invalidate(inventoryListProvider);
          context.pop();
        });
      }
      if (next is CreateMaterialFailure) {
        _showModernSnackBar(
          'Error: ${next.message}',
          const Color(0xFFFF453A),
        );
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
                child: _buildContent(createState),
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
        center: Alignment.topCenter,
        radius: 1.5,
        colors: [
          Color(0xFF1A1A1F),
          Color(0xFF0F0F14),
        ],
        stops: [0.0, 1.0],
      ),
    );
  }

  Widget _buildContent(CreateMaterialState createState) {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(),
        SliverPadding(
          padding: const EdgeInsets.all(24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildHeaderCard(),
              const SizedBox(height: 32),
              _buildForm(),
              const SizedBox(height: 32),
              _buildPricePreview(),
              const SizedBox(height: 32),
              _buildActionButtons(createState),
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
            'Create Material',
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

  // 📋 Header card
  Widget _buildHeaderCard() {
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
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'New Material',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFE5E5E7),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add a new material to your inventory',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8E8E93),
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

  // 📝 Formulario
  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Material Information'),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _nameController,
            focus: _nameFocus,
            nextFocus: _descriptionFocus,
            label: 'Material Name',
            hint: 'Enter material name',
            icon: Icons.label_outline,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter material name';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _descriptionController,
            focus: _descriptionFocus,
            nextFocus: _priceFocus,
            label: 'Description',
            hint: 'Enter material description',
            icon: Icons.description_outlined,
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter description';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _priceController,
            focus: _priceFocus,
            label: 'Unit Price',
            hint: 'Enter price per unit',
            icon: Icons.attach_money_outlined,
            keyboardType: TextInputType.number,
            prefixText: '\$ ',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter price';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid price';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focus,
    FocusNode? nextFocus,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? prefixText,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFFE5E5E7),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 12),
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
            controller: controller,
            focusNode: focus,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: const TextStyle(
              color: Color(0xFFE5E5E7),
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: const Color(0xFF8E8E93).withOpacity(0.8),
                fontSize: 14,
              ),
              prefixIcon: Icon(
                icon,
                color: const Color(0xFF8E8E93),
                size: 20,
              ),
              prefixText: prefixText,
              prefixStyle: const TextStyle(
                color: Color(0xFF8E8E93),
                fontSize: 16,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
            validator: validator,
            onFieldSubmitted: (_) {
              if (nextFocus != null) {
                FocusScope.of(context).requestFocus(nextFocus);
              }
            },
          ),
        ),
      ],
    );
  }

  // 💰 Vista previa del precio
  Widget _buildPricePreview() {
    final price = double.tryParse(_priceController.text) ?? 0.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: price > 0
            ? const Color(0xFF32D74B).withOpacity(0.1)
            : const Color(0xFF2A2A2F).withOpacity(0.4),
        border: Border.all(
          color: price > 0
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
                  color: price > 0
                      ? const Color(0xFF32D74B).withOpacity(0.2)
                      : const Color(0xFF8E8E93).withOpacity(0.2),
                ),
                child: Icon(
                  Icons.monetization_on_outlined,
                  color: price > 0
                      ? const Color(0xFF32D74B)
                      : const Color(0xFF8E8E93),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Price Preview',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFE5E5E7),
                  ),
                ),
              ),
            ],
          ),
          if (price > 0) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Unit Price:',
                  style: TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 14,
                  ),
                ),
                Text(
                  '\$${price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color(0xFF32D74B),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 1,
              color: const Color(0xFF32D74B).withOpacity(0.3),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF32D74B),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Price per unit in inventory',
                  style: TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 12,
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
  Widget _buildActionButtons(CreateMaterialState createState) {
    return Row(
      children: [
        Expanded(
          child: _buildModernButton(
            'Cancel',
            createState is CreateMaterialLoading
                ? null
                : () => context.pop(),
            isSecondary: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: _buildModernButton(
            createState is CreateMaterialLoading
                ? 'Creating...'
                : 'Create Material',
            createState is CreateMaterialLoading
                ? null
                : _submitForm,
            isLoading: createState is CreateMaterialLoading,
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
            color: isSecondary
                ? const Color(0xFF8E8E93)
                : Colors.white,
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
                'Material Guidelines',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Color(0xFFE5E5E7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoItem('• Use descriptive names for easy identification'),
          _buildInfoItem('• Include specifications in the description'),
          _buildInfoItem('• Set accurate pricing for cost calculations'),
          _buildInfoItem('• Materials will be available for project assignments'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF8E8E93),
        ),
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
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final materialData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'unitPrice': double.parse(_priceController.text),
      };

      ref.read(createMaterialProvider.notifier).createMaterial(materialData);
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
                    : Icons.error_outline,
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