// lib/features/documents/presentation/screens/document_permissions_management_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/document_providers.dart';
import 'document_permissions_screen.dart';

class DocumentPermissionsManagementScreen extends ConsumerStatefulWidget {
  const DocumentPermissionsManagementScreen({super.key});

  @override
  ConsumerState<DocumentPermissionsManagementScreen> createState() =>
      _DocumentPermissionsManagementScreenState();
}

class _DocumentPermissionsManagementScreenState
    extends ConsumerState<DocumentPermissionsManagementScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutQuart),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    // Iniciar animaciones
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fadeController.forward();
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                child: _buildContent(),
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

  Widget _buildContent() {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(),
        SliverPadding(
          padding: const EdgeInsets.all(24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildAdminHeader(),
              const SizedBox(height: 32),
              _buildSectionTitle('Management Options'),
              const SizedBox(height: 20),
              _buildManagementOptions(),
              const SizedBox(height: 32),
              _buildQuickStats(),
            ]),
          ),
        ),
      ],
    );
  }

  // 📱 SliverAppBar minimalista
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
            'Permission Management',
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
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  // 👑 Header de administración
  Widget _buildAdminHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2A2A2F).withOpacity(0.8),
            const Color(0xFF1A1A1F).withOpacity(0.6),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF3A3A3F).withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF4A4A4F).withOpacity(0.8),
                  const Color(0xFF3A3A3F).withOpacity(0.6),
                ],
              ),
              border: Border.all(
                color: const Color(0xFF5A5A5F).withOpacity(0.4),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.admin_panel_settings_outlined,
              color: Color(0xFFE5E5E7),
              size: 28,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Admin Panel',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFE5E5E7),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Manage document permissions for all workers',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF8E8E93).withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
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

  // 📋 Opciones de gestión
  Widget _buildManagementOptions() {
    final options = [
      {
        'icon': Icons.security_outlined,
        'title': 'General Permissions',
        'subtitle': 'View and manage all system permissions',
        'color': const Color(0xFF32D74B),
        'action': () => _navigateToGeneralPermissions(),
      },
      {
        'icon': Icons.folder_special_outlined,
        'title': 'Document-Specific',
        'subtitle': 'Manage permissions for specific documents',
        'color': const Color(0xFF007AFF),
        'action': () => _showDocumentSelector(context),
      },
      {
        'icon': Icons.group_add_outlined,
        'title': 'Mass Assignment',
        'subtitle': 'Grant permissions to multiple workers',
        'color': const Color(0xFFAF52DE),
        'action': () => _showMassiveAssignmentDialog(context),
      },
      {
        'icon': Icons.history_outlined,
        'title': 'Permission Audit',
        'subtitle': 'View permission change history',
        'color': const Color(0xFFFF9F0A),
        'action': () => _showAuditDialog(context),
      },
    ];

    return Column(
      children: options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;

        return AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            final delay = index * 0.1;
            final animValue = Curves.easeOutQuart.transform(
              ((_fadeAnimation.value - delay).clamp(0.0, 1.0)),
            );

            return Transform.translate(
              offset: Offset(0, 30 * (1 - animValue)),
              child: Opacity(
                opacity: animValue,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: _buildManagementOption(
                    icon: option['icon'] as IconData,
                    title: option['title'] as String,
                    subtitle: option['subtitle'] as String,
                    color: option['color'] as Color,
                    onTap: option['action'] as VoidCallback,
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  // 🎯 Opción individual de gestión
  Widget _buildManagementOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF1A1A1F).withOpacity(0.9),
        border: Border.all(
          color: const Color(0xFF2A2A2F).withOpacity(0.6),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: color.withOpacity(0.1),
                    border: Border.all(color: color.withOpacity(0.3), width: 1),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFE5E5E7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF8E8E93).withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFF2A2A2F).withOpacity(0.5),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFF8E8E93),
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 📊 Estadísticas rápidas
  Widget _buildQuickStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Quick Stats'),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Users',
                '24',
                Icons.people_outline,
                const Color(0xFF32D74B),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Active Docs',
                '156',
                Icons.description_outlined,
                const Color(0xFF007AFF),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Permissions',
                '89',
                Icons.lock_outline,
                const Color(0xFFAF52DE),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Recent Changes',
                '12',
                Icons.update_outlined,
                const Color(0xFFFF9F0A),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 📈 Card de estadística
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF1A1A1F).withOpacity(0.9),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Color(0xFF8E8E93)),
          ),
        ],
      ),
    );
  }

  // 🚀 Navegación a permisos generales
  void _navigateToGeneralPermissions() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const DocumentPermissionsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  // 📁 Selector de documentos
  void _showDocumentSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _buildModernDialog(
        'Select Document',
        'Feature in development.\nSoon you\'ll be able to select a specific document to manage its permissions.',
        Icons.folder_special_outlined,
        const Color(0xFF007AFF),
      ),
    );
  }

  // 👥 Diálogo de asignación masiva
  void _showMassiveAssignmentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _buildModernDialog(
        'Mass Assignment',
        'Feature in development.\nSoon you\'ll be able to assign permissions to multiple workers at once.',
        Icons.group_add_outlined,
        const Color(0xFFAF52DE),
      ),
    );
  }

  // 📋 Diálogo de auditoría
  void _showAuditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _buildModernDialog(
        'Permission Audit',
        'Feature in development.\nSoon you\'ll be able to view the complete history of permission changes.',
        Icons.history_outlined,
        const Color(0xFFFF9F0A),
      ),
    );
  }

  // 💬 Diálogo moderno
  Widget _buildModernDialog(
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFF1A1A1F),
          border: Border.all(
            color: const Color(0xFF2A2A2F).withOpacity(0.6),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.1),
                border: Border.all(color: color.withOpacity(0.3), width: 1),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Color(0xFFE5E5E7),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              content,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF8E8E93).withOpacity(0.8),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: _buildDialogButton('Got it', () => Navigator.pop(context)),
            ),
          ],
        ),
      ),
    );
  }

  // 🔘 Botón de diálogo
  Widget _buildDialogButton(String text, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF2A2A2F),
        border: Border.all(
          color: const Color(0xFF3A3A3F).withOpacity(0.6),
          width: 1,
        ),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFFE5E5E7),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
