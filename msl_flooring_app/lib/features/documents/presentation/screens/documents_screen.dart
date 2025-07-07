// lib/features/documents/presentation/screens/documents_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/session_provider.dart';
import '../providers/document_providers.dart';
import '../widgets/document_card.dart';
import 'upload_document_screen.dart';
import 'document_permissions_screen.dart';

class DocumentsScreen extends ConsumerStatefulWidget {
  final String? projectId;

  const DocumentsScreen({this.projectId, super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _fabController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fabScaleAnimation;

  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // 🎭 Configurar animaciones
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fabController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutQuart),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDocuments();
      // Iniciar animaciones
      _fadeController.forward();
      _slideController.forward();
      Future.delayed(const Duration(milliseconds: 500), () {
        _fabController.forward();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _fabController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _loadDocuments() {
    if (widget.projectId != null) {
      ref
          .read(documentListProvider.notifier)
          .fetchDocumentsByProject(widget.projectId!);
    } else {
      ref.read(documentListProvider.notifier).fetchAllDocuments();
    }
  }

  @override
  Widget build(BuildContext context) {
    final documentState = ref.watch(documentListProvider);
    final session = ref.watch(sessionProvider);
    final isAdmin = session?.isAdmin ?? false;

    return Theme(
      data: _buildDarkTheme(),
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F14),
        body: Container(
          decoration: _buildBackgroundDecoration(),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildContent(documentState, isAdmin, session),
            ),
          ),
        ),
        floatingActionButton: _buildModernFAB(),
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

  Widget _buildContent(DocumentListState documentState, bool isAdmin, session) {
    if (widget.projectId != null) {
      // Vista para proyecto específico
      return CustomScrollView(
        slivers: [
          _buildProjectSliverAppBar(isAdmin),
          SliverToBoxAdapter(child: _buildSearchBar()),
          SliverToBoxAdapter(child: const SizedBox(height: 20)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: _buildDocumentsSliverList(documentState, isAdmin),
          ),
        ],
      );
    } else {
      // Vista general de documentos
      return CustomScrollView(
        slivers: [
          _buildGeneralSliverAppBar(isAdmin),
          SliverToBoxAdapter(child: _buildTabBar()),
          SliverToBoxAdapter(child: _buildSearchBar()),
          SliverFillRemaining(
            child: _buildTabBarView(documentState, isAdmin, session),
          ),
        ],
      );
    }
  }

  // 📱 SliverAppBar para proyecto específico
  Widget _buildProjectSliverAppBar(bool isAdmin) {
    return SliverAppBar(
      expandedHeight: 140,
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
            'Project Documents',
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
      actions: [
        _buildHeaderAction(Icons.refresh_outlined, _loadDocuments),
        if (isAdmin)
          _buildHeaderAction(
            Icons.admin_panel_settings_outlined,
            () => _navigateToPermissions(null),
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  // 📱 SliverAppBar general
  Widget _buildGeneralSliverAppBar(bool isAdmin) {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF2A2A2F).withOpacity(0.9),
              const Color(0xFF1A1A1F).withOpacity(0.8),
            ],
          ),
        ),
        child: FlexibleSpaceBar(
          background: Stack(
            children: [_buildAnimatedParticles(), _buildHeaderContent(isAdmin)],
          ),
        ),
      ),
    );
  }

  // ✨ Partículas animadas
  Widget _buildAnimatedParticles() {
    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        return Stack(
          children: List.generate(12, (index) {
            final angle = index * 30.0;
            final radius = 20 + (index * 15);
            return Positioned(
              left: 100 + radius * 0.5,
              top: 80 + radius * 0.3,
              child: Transform.rotate(
                angle: angle * 3.14159 / 180,
                child: Container(
                  width: 3,
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8E8E93).withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  // 📋 Contenido del header
  Widget _buildHeaderContent(bool isAdmin) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: const Color(0xFF3A3A3F).withOpacity(0.6),
                    border: Border.all(
                      color: const Color(0xFF4A4A4F).withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.folder_open_outlined,
                    color: Color(0xFFE5E5E7),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Documents',
                        style: TextStyle(
                          color: Color(0xFFE5E5E7),
                          fontSize: 28,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Manage files and permissions',
                        style: TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isAdmin)
                  _buildHeaderAction(
                    Icons.admin_panel_settings_outlined,
                    () => _navigateToPermissions(null),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🔘 Botones del header
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

  Widget _buildHeaderAction(IconData icon, VoidCallback onPressed) {
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
        icon: Icon(icon, color: const Color(0xFFE5E5E7), size: 20),
        onPressed: onPressed,
      ),
    );
  }

  // 📑 TabBar moderno
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(20),
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
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        tabs: const [
          Tab(text: 'All Documents'),
          Tab(text: 'My Documents'),
        ],
      ),
    );
  }

  // 🔍 Barra de búsqueda moderna
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
          focusNode: _searchFocus,
          style: const TextStyle(color: Color(0xFFE5E5E7), fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Search documents...',
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

  // 📋 TabBarView
  Widget _buildTabBarView(
    DocumentListState documentState,
    bool isAdmin,
    session,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildDocumentsList(documentState, isAdmin),
          _buildMyDocumentsList(documentState, isAdmin, session?.id ?? ''),
        ],
      ),
    );
  }

  // 📄 Lista de documentos
  Widget _buildDocumentsList(DocumentListState state, bool isAdmin) {
    return switch (state) {
      DocumentListLoading() => _buildModernLoader(),
      DocumentListSuccess(documents: final documents) =>
        documents.isEmpty
            ? _buildEmptyState()
            : RefreshIndicator(
                color: const Color(0xFF8E8E93),
                backgroundColor: const Color(0xFF1A1A1F),
                onRefresh: () async => _loadDocuments(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _getFilteredDocuments(documents).length,
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
                            child: DocumentCard(
                              document: _getFilteredDocuments(documents)[index],
                              isAdmin: isAdmin,
                              onDelete: isAdmin
                                  ? () => _deleteDocument(
                                      _getFilteredDocuments(
                                        documents,
                                      )[index].id,
                                    )
                                  : null,
                              onPermissions: isAdmin
                                  ? () => _managePermissions(
                                      _getFilteredDocuments(documents)[index],
                                    )
                                  : null,
                              onDownload: () => _downloadDocument(
                                _getFilteredDocuments(documents)[index],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
      DocumentListFailure(message: final message) => _buildErrorState(message),
      _ => const SizedBox(),
    };
  }

  // Sliver version para proyecto específico
  Widget _buildDocumentsSliverList(DocumentListState state, bool isAdmin) {
    return switch (state) {
      DocumentListLoading() => SliverToBoxAdapter(child: _buildModernLoader()),
      DocumentListSuccess(documents: final documents) =>
        documents.isEmpty
            ? SliverToBoxAdapter(child: _buildEmptyState())
            : SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
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
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: DocumentCard(
                              document: _getFilteredDocuments(documents)[index],
                              isAdmin: isAdmin,
                              onDelete: isAdmin
                                  ? () => _deleteDocument(
                                      _getFilteredDocuments(
                                        documents,
                                      )[index].id,
                                    )
                                  : null,
                              onPermissions: isAdmin
                                  ? () => _managePermissions(
                                      _getFilteredDocuments(documents)[index],
                                    )
                                  : null,
                              onDownload: () => _downloadDocument(
                                _getFilteredDocuments(documents)[index],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }, childCount: _getFilteredDocuments(documents).length),
              ),
      DocumentListFailure(message: final message) => SliverToBoxAdapter(
        child: _buildErrorState(message),
      ),
      _ => const SliverToBoxAdapter(child: SizedBox()),
    };
  }

  // 👤 Mis documentos
  Widget _buildMyDocumentsList(
    DocumentListState state,
    bool isAdmin,
    String userId,
  ) {
    return switch (state) {
      DocumentListLoading() => _buildModernLoader(),
      DocumentListSuccess(documents: final documents) => () {
        final myDocuments = documents
            .where((doc) => doc.uploadedBy == userId)
            .toList();
        final filteredDocuments = _getFilteredDocuments(myDocuments);

        return filteredDocuments.isEmpty
            ? _buildEmptyState(message: 'You haven\'t uploaded any documents')
            : RefreshIndicator(
                color: const Color(0xFF8E8E93),
                backgroundColor: const Color(0xFF1A1A1F),
                onRefresh: () async => _loadDocuments(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: filteredDocuments.length,
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
                            child: DocumentCard(
                              document: filteredDocuments[index],
                              isAdmin: isAdmin,
                              onDelete: () =>
                                  _deleteDocument(filteredDocuments[index].id),
                              onPermissions: isAdmin
                                  ? () => _managePermissions(
                                      filteredDocuments[index],
                                    )
                                  : null,
                              onDownload: () =>
                                  _downloadDocument(filteredDocuments[index]),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
      }(),
      DocumentListFailure(message: final message) => _buildErrorState(message),
      _ => const SizedBox(),
    };
  }

  // ⏳ Loader moderno
  Widget _buildModernLoader() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(60),
        child: Column(
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
              'Loading documents...',
              style: TextStyle(color: Color(0xFF8E8E93), fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // 📂 Estado vacío
  Widget _buildEmptyState({String? message}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
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
                Icons.folder_open_outlined,
                size: 50,
                color: Color(0xFF8E8E93),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message ?? 'No documents available',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Color(0xFFE5E5E7),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Use the upload button to add documents',
              style: TextStyle(fontSize: 16, color: Color(0xFF8E8E93)),
            ),
            const SizedBox(height: 32),
            _buildModernButton('Upload Document', () => _navigateToUpload()),
          ],
        ),
      ),
    );
  }

  // ❌ Estado de error
  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
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
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Color(0xFF8E8E93)),
            ),
            const SizedBox(height: 32),
            _buildModernButton('Try Again', _loadDocuments),
          ],
        ),
      ),
    );
  }

  // 🚀 FAB moderno
  Widget _buildModernFAB() {
    return ScaleTransition(
      scale: _fabScaleAnimation,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF3A3A3F).withOpacity(0.9),
              const Color(0xFF2A2A2F).withOpacity(0.8),
            ],
          ),
          border: Border.all(
            color: const Color(0xFF4A4A4F).withOpacity(0.6),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF000000).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          heroTag: "documents_fab",
          onPressed: _navigateToUpload,
          backgroundColor: Colors.transparent,
          foregroundColor: const Color(0xFFE5E5E7),
          elevation: 0,
          icon: const Icon(Icons.upload_file_outlined, size: 20),
          label: const Text(
            'Upload',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ),
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

  // 🔧 Métodos de utilidad
  List<dynamic> _getFilteredDocuments(List<dynamic> documents) {
    if (_searchQuery.isEmpty) return documents;

    return documents.where((doc) {
      return doc.filename.toLowerCase().contains(_searchQuery) ||
          (doc.fileExtension?.toLowerCase().contains(_searchQuery) ?? false);
    }).toList();
  }

  void _navigateToUpload() {
    Navigator.of(context)
        .push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                UploadDocumentScreen(projectId: widget.projectId),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0.0, 1.0),
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
        )
        .then((_) => _loadDocuments());
  }

  void _navigateToPermissions(String? documentId) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            DocumentPermissionsScreen(documentId: documentId),
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

  void _deleteDocument(String documentId) {
    showDialog(
      context: context,
      builder: (context) => _buildDeleteDialog(documentId),
    );
  }

  Widget _buildDeleteDialog(String documentId) {
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
                color: const Color(0xFFFF453A).withOpacity(0.1),
                border: Border.all(
                  color: const Color(0xFFFF453A).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Color(0xFFFF453A),
                size: 28,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Delete Document',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Color(0xFFE5E5E7),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Are you sure you want to delete this document? This action cannot be undone.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF8E8E93),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildDialogButton(
                    'Cancel',
                    () => Navigator.pop(context),
                    false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDialogButton('Delete', () {
                    Navigator.pop(context);
                    ref
                        .read(documentListProvider.notifier)
                        .deleteDocument(documentId);
                    _showModernSnackBar('Document deleted successfully');
                  }, true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogButton(
    String text,
    VoidCallback onPressed,
    bool isDestructive,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDestructive
            ? const Color(0xFFFF453A).withOpacity(0.1)
            : const Color(0xFF2A2A2F),
        border: Border.all(
          color: isDestructive
              ? const Color(0xFFFF453A).withOpacity(0.3)
              : const Color(0xFF3A3A3F).withOpacity(0.6),
          width: 1,
        ),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isDestructive
                ? const Color(0xFFFF453A)
                : const Color(0xFFE5E5E7),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _managePermissions(dynamic document) {
    _navigateToPermissions(document.id);
  }

  void _downloadDocument(dynamic document) {
    _showModernSnackBar('Downloading: ${document.filename}');
  }

  void _showModernSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: const Color(0xFF2A2A2F),
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
