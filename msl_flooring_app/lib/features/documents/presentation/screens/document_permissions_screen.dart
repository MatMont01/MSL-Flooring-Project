// lib/features/documents/presentation/screens/document_permissions_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../worker/presentation/providers/worker_providers.dart';
import '../../../worker/domain/entities/worker_entity.dart';
import '../../domain/entities/document_permission_entity.dart';
import '../providers/document_providers.dart';

class DocumentPermissionsScreen extends ConsumerStatefulWidget {
  final String? documentId;

  const DocumentPermissionsScreen({this.documentId, super.key});

  @override
  ConsumerState<DocumentPermissionsScreen> createState() =>
      _DocumentPermissionsScreenState();
}

class _DocumentPermissionsScreenState
    extends ConsumerState<DocumentPermissionsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: widget.documentId != null ? 2 : 3,
      vsync: this,
    );

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Cargar datos
      ref.read(workerListProvider.notifier).fetchWorkers();
      if (widget.documentId != null) {
        ref
            .read(documentPermissionProvider.notifier)
            .fetchPermissionsByDocument(widget.documentId!);
      }

      // Iniciar animaciones
      _fadeController.forward();
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workersState = ref.watch(workerListProvider);
    final permissionsState = ref.watch(documentPermissionProvider);

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
                child: _buildContent(workersState, permissionsState),
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
    WorkerListState workersState,
    DocumentPermissionState permissionsState,
  ) {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(),
        SliverToBoxAdapter(child: _buildSearchBar()),
        SliverToBoxAdapter(child: _buildTabBar()),
        SliverFillRemaining(
          child: _buildTabBarView(workersState, permissionsState),
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
        child: FlexibleSpaceBar(
          title: Text(
            widget.documentId != null
                ? 'Document Permissions'
                : 'Permission Management',
            style: const TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 18,
              color: Color(0xFFE5E5E7),
              letterSpacing: 0.5,
            ),
          ),
          centerTitle: true,
        ),
      ),
      actions: [_buildRefreshButton(), const SizedBox(width: 8)],
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

  // 🔄 Botón de actualizar
  Widget _buildRefreshButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
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
          Icons.refresh_outlined,
          color: Color(0xFFE5E5E7),
          size: 20,
        ),
        onPressed: () => _refreshData(),
      ),
    );
  }

  // 🔍 Barra de búsqueda moderna
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF1A1A1F).withOpacity(0.8),
          border: Border.all(
            color: const Color(0xFF2A2A2F).withOpacity(0.6),
            width: 1,
          ),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: Color(0xFFE5E5E7), fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Search workers or documents...',
            hintStyle: TextStyle(
              color: const Color(0xFF8E8E93).withOpacity(0.8),
              fontSize: 14,
            ),
            prefixIcon: const Icon(
              Icons.search_outlined,
              color: Color(0xFF8E8E93),
              size: 20,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.clear,
                      color: Color(0xFF8E8E93),
                      size: 20,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
            });
          },
        ),
      ),
    );
  }

  // 📑 TabBar personalizado
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF1A1A1F).withOpacity(0.8),
        border: Border.all(
          color: const Color(0xFF2A2A2F).withOpacity(0.6),
          width: 1,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFFE5E5E7),
        unselectedLabelColor: const Color(0xFF8E8E93),
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: const Color(0xFF2A2A2F).withOpacity(0.8),
        ),
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        tabs: widget.documentId != null
            ? [const Tab(text: 'Current'), const Tab(text: 'Grant')]
            : [
                const Tab(text: 'All'),
                const Tab(text: 'By Doc'),
                const Tab(text: 'By Worker'),
              ],
      ),
    );
  }

  // 📋 TabBarView
  Widget _buildTabBarView(
    WorkerListState workersState,
    DocumentPermissionState permissionsState,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: TabBarView(
        controller: _tabController,
        children: widget.documentId != null
            ? [
                _buildCurrentPermissions(permissionsState),
                _buildGrantPermissions(workersState),
              ]
            : [
                _buildAllPermissions(),
                _buildPermissionsByDocument(),
                _buildPermissionsByWorker(workersState),
              ],
      ),
    );
  }

  // 🔐 Permisos actuales
  Widget _buildCurrentPermissions(DocumentPermissionState state) {
    return switch (state) {
      DocumentPermissionLoading() => _buildModernLoader(),
      DocumentPermissionSuccess(permissions: final permissions) =>
        permissions.isEmpty
            ? _buildEmptyPermissions()
            : RefreshIndicator(
                color: const Color(0xFF8E8E93),
                backgroundColor: const Color(0xFF1A1A1F),
                onRefresh: () async => _refreshData(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: permissions.length,
                  itemBuilder: (context, index) {
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
                            child: _buildPermissionCard(permissions[index]),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
      DocumentPermissionFailure(message: final message) => _buildErrorState(
        message,
      ),
      _ => const SizedBox(),
    };
  }

  // 👥 Otorgar permisos
  Widget _buildGrantPermissions(WorkerListState workersState) {
    return switch (workersState) {
      WorkerListLoading() => _buildModernLoader(),
      WorkerListSuccess(workers: final workers) =>
        workers.isEmpty
            ? _buildEmptyWorkers()
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _getFilteredWorkers(workers).length,
                itemBuilder: (context, index) {
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
                          child: _buildWorkerPermissionCard(
                            _getFilteredWorkers(workers)[index],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      WorkerListFailure(message: final message) => _buildErrorState(message),
      _ => const SizedBox(),
    };
  }

  // 📊 Vistas placeholder
  Widget _buildAllPermissions() {
    return _buildPlaceholderView(
      Icons.security_outlined,
      'All Permissions',
      'Complete overview of all permissions',
      const Color(0xFF32D74B),
    );
  }

  Widget _buildPermissionsByDocument() {
    return _buildPlaceholderView(
      Icons.folder_special_outlined,
      'By Document',
      'Permissions organized by document',
      const Color(0xFF007AFF),
    );
  }

  Widget _buildPermissionsByWorker(WorkerListState workersState) {
    return switch (workersState) {
      WorkerListLoading() => _buildModernLoader(),
      WorkerListSuccess(workers: final workers) => ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _getFilteredWorkers(workers).length,
        itemBuilder: (context, index) {
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
                  child: _buildWorkerSummaryCard(
                    _getFilteredWorkers(workers)[index],
                  ),
                ),
              );
            },
          );
        },
      ),
      WorkerListFailure(message: final message) => _buildErrorState(message),
      _ => const SizedBox(),
    };
  }

  // 🎯 Card de permiso moderno
  Widget _buildPermissionCard(DocumentPermissionEntity permission) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF1A1A1F).withOpacity(0.9),
        border: Border.all(
          color: permission.canView
              ? const Color(0xFF32D74B).withOpacity(0.3)
              : const Color(0xFFFF453A).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: permission.canView
                    ? const Color(0xFF32D74B).withOpacity(0.1)
                    : const Color(0xFFFF453A).withOpacity(0.1),
              ),
              child: Icon(
                permission.canView
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: permission.canView
                    ? const Color(0xFF32D74B)
                    : const Color(0xFFFF453A),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Worker: ${permission.workerId.substring(0, 8)}...',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFE5E5E7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    permission.canView ? 'Can view document' : 'No access',
                    style: TextStyle(
                      fontSize: 14,
                      color: permission.canView
                          ? const Color(0xFF32D74B)
                          : const Color(0xFFFF453A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Granted: ${_formatDate(permission.grantedAt)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                ],
              ),
            ),
            _buildPermissionMenu(permission),
          ],
        ),
      ),
    );
  }

  // ⚙️ Menú de permisos
  Widget _buildPermissionMenu(DocumentPermissionEntity permission) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFF2A2A2F).withOpacity(0.6),
      ),
      child: PopupMenuButton<String>(
        onSelected: (value) => _handlePermissionAction(value, permission),
        icon: const Icon(Icons.more_vert, color: Color(0xFF8E8E93), size: 20),
        color: const Color(0xFF1A1A1F),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: const Color(0xFF2A2A2F).withOpacity(0.6),
            width: 1,
          ),
        ),
        itemBuilder: (context) => [
          if (permission.canView)
            PopupMenuItem(
              value: 'revoke',
              child: _buildMenuItem(
                Icons.block_outlined,
                'Revoke Access',
                const Color(0xFFFF453A),
              ),
            )
          else
            PopupMenuItem(
              value: 'grant',
              child: _buildMenuItem(
                Icons.check_circle_outline,
                'Grant Access',
                const Color(0xFF32D74B),
              ),
            ),
          PopupMenuItem(
            value: 'details',
            child: _buildMenuItem(
              Icons.info_outline,
              'View Details',
              const Color(0xFF8E8E93),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 12),
        Text(text, style: TextStyle(color: color, fontSize: 14)),
      ],
    );
  }

  // 👤 Card de trabajador para otorgar permisos
  Widget _buildWorkerPermissionCard(WorkerEntity worker) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF1A1A1F).withOpacity(0.9),
        border: Border.all(
          color: const Color(0xFF2A2A2F).withOpacity(0.6),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF007AFF).withOpacity(0.2),
                    const Color(0xFF007AFF).withOpacity(0.1),
                  ],
                ),
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
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    worker.fullName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFE5E5E7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    worker.email,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${worker.id.substring(0, 8)}...',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildActionButton(
                  Icons.visibility_outlined,
                  const Color(0xFF32D74B),
                  'Grant',
                  () => _grantPermission(worker.id, true),
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  Icons.visibility_off_outlined,
                  const Color(0xFFFF453A),
                  'Deny',
                  () => _grantPermission(worker.id, false),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🔘 Botón de acción
  Widget _buildActionButton(
    IconData icon,
    Color color,
    String tooltip,
    VoidCallback onPressed,
  ) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: color, size: 18),
        tooltip: tooltip,
        padding: EdgeInsets.zero,
      ),
    );
  }

  // 📝 Resumen de trabajador
  Widget _buildWorkerSummaryCard(WorkerEntity worker) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF1A1A1F).withOpacity(0.9),
        border: Border.all(
          color: const Color(0xFF2A2A2F).withOpacity(0.6),
          width: 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          expansionTileTheme: const ExpansionTileThemeData(
            iconColor: Color(0xFF8E8E93),
            collapsedIconColor: Color(0xFF8E8E93),
          ),
        ),
        child: ExpansionTile(
          leading: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFAF52DE).withOpacity(0.2),
                  const Color(0xFFAF52DE).withOpacity(0.1),
                ],
              ),
              border: Border.all(
                color: const Color(0xFFAF52DE).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                worker.firstName[0].toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFFAF52DE),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          title: Text(
            worker.fullName,
            style: const TextStyle(
              color: Color(0xFFE5E5E7),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            worker.email,
            style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 14),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Documents with access:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFE5E5E7),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2F).withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF3A3A3F).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const Text(
                      'Feature in development',
                      style: TextStyle(color: Color(0xFF8E8E93), fontSize: 14),
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

  // 🎯 Vista placeholder moderna
  Widget _buildPlaceholderView(
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.1),
              border: Border.all(color: color.withOpacity(0.3), width: 2),
            ),
            child: Icon(icon, size: 50, color: color),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Color(0xFFE5E5E7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 16, color: Color(0xFF8E8E93)),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: color.withOpacity(0.1),
              border: Border.all(color: color.withOpacity(0.3), width: 1),
            ),
            child: const Text(
              'Feature in development',
              style: TextStyle(color: Color(0xFF8E8E93), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // ⏳ Loader moderno
  Widget _buildModernLoader() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8E8E93)),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Loading permissions...',
            style: TextStyle(color: Color(0xFF8E8E93), fontSize: 16),
          ),
        ],
      ),
    );
  }

  // 🚫 Estados vacíos
  Widget _buildEmptyPermissions() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF2A2A2F).withOpacity(0.6),
              border: Border.all(
                color: const Color(0xFF3A3A3F).withOpacity(0.4),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.security_outlined,
              size: 50,
              color: Color(0xFF8E8E93),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No permissions configured',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Color(0xFFE5E5E7),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This document is private by default',
            style: TextStyle(fontSize: 16, color: Color(0xFF8E8E93)),
          ),
          const SizedBox(height: 32),
          _buildActionButton(
            Icons.add,
            const Color(0xFF007AFF),
            'Grant Permissions',
            () => _tabController.animateTo(1),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWorkers() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF2A2A2F).withOpacity(0.6),
              border: Border.all(
                color: const Color(0xFF3A3A3F).withOpacity(0.4),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.people_outline,
              size: 50,
              color: Color(0xFF8E8E93),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No workers registered',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Color(0xFFE5E5E7),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Cannot grant permissions without workers',
            style: TextStyle(fontSize: 16, color: Color(0xFF8E8E93)),
          ),
        ],
      ),
    );
  }

  // ❌ Estado de error
  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFF453A).withOpacity(0.1),
              border: Border.all(
                color: const Color(0xFFFF453A).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 50,
              color: Color(0xFFFF453A),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Color(0xFFE5E5E7),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Color(0xFF8E8E93)),
            ),
          ),
          const SizedBox(height: 32),
          _buildModernButton('Try Again', () => _refreshData()),
        ],
      ),
    );
  }

  // 🔘 Botón moderno
  Widget _buildModernButton(String text, VoidCallback onPressed) {
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

  // 🔄 Métodos de utilidad
  void _refreshData() {
    ref.read(workerListProvider.notifier).fetchWorkers();
    if (widget.documentId != null) {
      ref
          .read(documentPermissionProvider.notifier)
          .fetchPermissionsByDocument(widget.documentId!);
    }
  }

  List<WorkerEntity> _getFilteredWorkers(List<WorkerEntity> workers) {
    if (_searchQuery.isEmpty) return workers;

    return workers.where((worker) {
      return worker.fullName.toLowerCase().contains(_searchQuery) ||
          worker.email.toLowerCase().contains(_searchQuery) ||
          worker.id.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  void _handlePermissionAction(
    String action,
    DocumentPermissionEntity permission,
  ) {
    switch (action) {
      case 'grant':
        _grantPermission(permission.workerId, true);
        break;
      case 'revoke':
        _grantPermission(permission.workerId, false);
        break;
      case 'details':
        _showPermissionDetails(permission);
        break;
    }
  }

  void _grantPermission(String workerId, bool canView) {
    if (widget.documentId == null) return;

    ref
        .read(documentPermissionProvider.notifier)
        .grantPermission(
          documentId: widget.documentId!,
          workerId: workerId,
          canView: canView,
        );

    _showModernSnackBar(
      canView
          ? 'Permission granted successfully'
          : 'Permission revoked successfully',
      canView ? const Color(0xFF32D74B) : const Color(0xFFFF9F0A),
    );
  }

  void _showPermissionDetails(DocumentPermissionEntity permission) {
    showDialog(
      context: context,
      builder: (context) => _buildModernDialog(permission),
    );
  }

  // 💬 Diálogo moderno
  Widget _buildModernDialog(DocumentPermissionEntity permission) {
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
                color: const Color(0xFF007AFF).withOpacity(0.1),
                border: Border.all(
                  color: const Color(0xFF007AFF).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.info_outline,
                color: Color(0xFF007AFF),
                size: 28,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Permission Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Color(0xFFE5E5E7),
              ),
            ),
            const SizedBox(height: 20),
            ...[
              _buildDetailRow('Permission ID', permission.id),
              _buildDetailRow('Worker ID', permission.workerId),
              _buildDetailRow('Document ID', permission.documentId),
              _buildDetailRow('Can View', permission.canView ? 'Yes' : 'No'),
              _buildDetailRow('Granted On', _formatDate(permission.grantedAt)),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: _buildModernButton('Close', () => Navigator.pop(context)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF8E8E93),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFFE5E5E7), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // 📱 SnackBar moderno
  void _showModernSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
