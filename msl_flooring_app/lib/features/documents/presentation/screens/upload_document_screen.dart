// lib/features/documents/presentation/screens/upload_document_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import '../../../../core/providers/session_provider.dart';
import '../../../projects/presentation/providers/project_providers.dart';
import '../../../projects/domain/entities/project_entity.dart';
import '../providers/document_providers.dart';

class UploadDocumentScreen extends ConsumerStatefulWidget {
  final String? projectId;

  const UploadDocumentScreen({this.projectId, super.key});

  @override
  ConsumerState<UploadDocumentScreen> createState() =>
      _UploadDocumentScreenState();
}

class _UploadDocumentScreenState extends ConsumerState<UploadDocumentScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _descriptionFocus = FocusNode();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _progressController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _progressAnimation;

  File? _selectedFile;
  String? _selectedFileName;
  ProjectEntity? _selectedProject;
  String _uploadMethod = 'file';

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

    _progressController = AnimationController(
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

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutQuart),
    );

    if (widget.projectId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(projectListProvider.notifier).fetchProjects();
      });
    }

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
    _progressController.dispose();
    _descriptionController.dispose();
    _descriptionFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(documentUploadProvider);
    final projectsState = ref.watch(projectListProvider);
    final session = ref.watch(sessionProvider);

    // Escuchar cambios en el estado de subida
    ref.listen<DocumentUploadState>(documentUploadProvider, (previous, next) {
      if (next is DocumentUploadSuccess) {
        _showModernSnackBar(next.message, const Color(0xFF32D74B));
        Navigator.of(context).pop();
      }
      if (next is DocumentUploadFailure) {
        _showModernSnackBar('Error: ${next.message}', const Color(0xFFFF453A));
      }
      if (next is DocumentUploadProgress) {
        if (!_progressController.isAnimating) {
          _progressController.forward();
        }
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
                child: _buildContent(uploadState, projectsState, session),
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
        colors: [Color(0xFF1A1A1F), Color(0xFF0F0F14)],
        stops: [0.0, 1.0],
      ),
    );
  }

  Widget _buildContent(
    DocumentUploadState uploadState,
    ProjectListState projectsState,
    session,
  ) {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(),
        SliverPadding(
          padding: const EdgeInsets.all(24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildHeaderCard(),
              const SizedBox(height: 32),
              _buildUploadMethodSection(),
              const SizedBox(height: 32),
              if (_selectedFile != null) ...[
                _buildSelectedFileSection(),
                const SizedBox(height: 32),
              ],
              if (widget.projectId == null) ...[
                _buildProjectSection(projectsState),
                const SizedBox(height: 32),
              ],
              _buildDescriptionSection(),
              const SizedBox(height: 32),
              if (uploadState is DocumentUploadProgress) ...[
                _buildProgressSection(uploadState),
                const SizedBox(height: 32),
              ],
              _buildActionButtons(uploadState),
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
            'Upload Document',
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

  // 📋 Header card
  Widget _buildHeaderCard() {
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
              Icons.upload_file_outlined,
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
                  'New Document',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFE5E5E7),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.projectId != null
                      ? 'Upload document to project'
                      : 'Upload general document',
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

  // 📤 Sección de método de subida
  Widget _buildUploadMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Upload Method'),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildUploadMethodCard(
                'file',
                Icons.folder_open_outlined,
                'File',
                'From device storage',
                const Color(0xFF007AFF),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildUploadMethodCard(
                'camera',
                Icons.camera_alt_outlined,
                'Camera',
                'Take a photo',
                const Color(0xFF32D74B),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildUploadMethodCard(
                'gallery',
                Icons.photo_library_outlined,
                'Gallery',
                'From gallery',
                const Color(0xFFAF52DE),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 🎯 Card de método de subida
  Widget _buildUploadMethodCard(
    String method,
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    final isSelected = _uploadMethod == method;

    return GestureDetector(
      onTap: () {
        setState(() {
          _uploadMethod = method;
        });
        _selectFile();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected
              ? color.withOpacity(0.1)
              : const Color(0xFF1A1A1F).withOpacity(0.9),
          border: Border.all(
            color: isSelected
                ? color.withOpacity(0.5)
                : const Color(0xFF2A2A2F).withOpacity(0.6),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: isSelected
                    ? color.withOpacity(0.2)
                    : const Color(0xFF2A2A2F).withOpacity(0.6),
              ),
              child: Icon(
                icon,
                size: 24,
                color: isSelected ? color : const Color(0xFF8E8E93),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: isSelected ? color : const Color(0xFFE5E5E7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? color.withOpacity(0.8)
                    : const Color(0xFF8E8E93),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // 📁 Sección de archivo seleccionado
  Widget _buildSelectedFileSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Selected File'),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: const Color(0xFF32D74B).withOpacity(0.1),
            border: Border.all(
              color: const Color(0xFF32D74B).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: const Color(0xFF32D74B).withOpacity(0.2),
                ),
                child: Icon(
                  _getFileIcon(_selectedFileName ?? ''),
                  color: const Color(0xFF32D74B),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedFileName ?? 'Selected file',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFE5E5E7),
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Size: ${_getFileSize()}',
                      style: const TextStyle(
                        color: Color(0xFF8E8E93),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xFFFF453A).withOpacity(0.1),
                ),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedFile = null;
                      _selectedFileName = null;
                    });
                  },
                  icon: const Icon(
                    Icons.close,
                    color: Color(0xFFFF453A),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 🏗️ Sección de proyecto
  Widget _buildProjectSection(ProjectListState projectsState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Project (Optional)'),
        const SizedBox(height: 20),
        _buildProjectSelector(projectsState),
      ],
    );
  }

  // 📝 Sección de descripción
  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Description (Optional)'),
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
            controller: _descriptionController,
            focusNode: _descriptionFocus,
            style: const TextStyle(color: Color(0xFFE5E5E7), fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Add a description for the document...',
              hintStyle: TextStyle(
                color: const Color(0xFF8E8E93).withOpacity(0.8),
                fontSize: 14,
              ),
              prefixIcon: const Icon(
                Icons.description_outlined,
                color: Color(0xFF8E8E93),
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
            maxLines: 3,
            maxLength: 500,
          ),
        ),
      ],
    );
  }

  // 📊 Sección de progreso
  Widget _buildProgressSection(DocumentUploadProgress progressState) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _progressAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(24),
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
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color(0xFF007AFF).withOpacity(0.2),
                      ),
                      child: const Icon(
                        Icons.upload_outlined,
                        color: Color(0xFF007AFF),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Uploading document...',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFE5E5E7),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progressState.progress,
                    backgroundColor: const Color(0xFF2A2A2F),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF007AFF),
                    ),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      progressState.message,
                      style: const TextStyle(
                        color: Color(0xFF8E8E93),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${(progressState.progress * 100).toInt()}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF007AFF),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 🔘 Botones de acción
  Widget _buildActionButtons(DocumentUploadState state) {
    return Row(
      children: [
        Expanded(
          child: _buildSecondaryButton(
            'Cancel',
            state is DocumentUploadLoading
                ? null
                : () => Navigator.pop(context),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(flex: 2, child: _buildPrimaryButton(state)),
      ],
    );
  }

  Widget _buildSecondaryButton(String text, VoidCallback? onPressed) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF2A2A2F).withOpacity(0.6),
        border: Border.all(
          color: const Color(0xFF3A3A3F).withOpacity(0.6),
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

  Widget _buildPrimaryButton(DocumentUploadState state) {
    final isEnabled =
        state is! DocumentUploadLoading &&
        state is! DocumentUploadProgress &&
        _selectedFile != null;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isEnabled
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF3A3A3F).withOpacity(0.9),
                  const Color(0xFF2A2A2F).withOpacity(0.8),
                ],
              )
            : null,
        color: !isEnabled ? const Color(0xFF2A2A2F).withOpacity(0.4) : null,
        border: Border.all(
          color: isEnabled
              ? const Color(0xFF4A4A4F).withOpacity(0.6)
              : const Color(0xFF2A2A2F).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ElevatedButton(
        onPressed: isEnabled ? _uploadDocument : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _buildButtonContent(state),
      ),
    );
  }

  Widget _buildButtonContent(DocumentUploadState state) {
    return switch (state) {
      DocumentUploadLoading() => const SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE5E5E7)),
        ),
      ),
      DocumentUploadProgress() => const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE5E5E7)),
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Uploading...',
            style: TextStyle(
              color: Color(0xFFE5E5E7),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      _ => const Text(
        'Upload Document',
        style: TextStyle(
          color: Color(0xFFE5E5E7),
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    };
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
          _buildInfoItem('• Maximum file size: 10 MB per file'),
          _buildInfoItem('• Supported formats: PDF, DOC, DOCX, JPG, PNG, etc.'),
          _buildInfoItem('• Documents are private by default'),
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

  // 🏗️ Selector de proyecto
  Widget _buildProjectSelector(ProjectListState projectsState) {
    return switch (projectsState) {
      ProjectListLoading() => Container(
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
      ),
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
            hintText: 'Select project (optional)',
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
          items: [
            const DropdownMenuItem<ProjectEntity>(
              value: null,
              child: Text(
                'No specific project',
                style: TextStyle(color: Color(0xFF8E8E93)),
              ),
            ),
            ...projects.map((project) {
              return DropdownMenuItem<ProjectEntity>(
                value: project,
                child: Text(
                  project.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFFE5E5E7)),
                ),
              );
            }).toList(),
          ],
          onChanged: (ProjectEntity? project) {
            setState(() {
              _selectedProject = project;
            });
          },
        ),
      ),
      ProjectListFailure(message: final message) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFFFF453A).withOpacity(0.1),
          border: Border.all(
            color: const Color(0xFFFF453A).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFFF453A), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Error loading projects: $message',
                style: const TextStyle(color: Color(0xFFFF453A), fontSize: 14),
              ),
            ),
          ],
        ),
      ),
      _ => const SizedBox(),
    };
  }

  // 🔧 Métodos de utilidad
  void _selectFile() async {
    try {
      switch (_uploadMethod) {
        case 'file':
          final result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: [
              'pdf',
              'doc',
              'docx',
              'xls',
              'xlsx',
              'jpg',
              'jpeg',
              'png',
              'gif',
            ],
            allowMultiple: false,
          );

          if (result != null && result.files.isNotEmpty) {
            final file = File(result.files.first.path!);
            setState(() {
              _selectedFile = file;
              _selectedFileName = result.files.first.name;
            });
          }
          break;

        case 'camera':
          final ImagePicker picker = ImagePicker();
          final XFile? image = await picker.pickImage(
            source: ImageSource.camera,
            maxWidth: 1920,
            maxHeight: 1080,
            imageQuality: 85,
          );

          if (image != null) {
            final file = File(image.path);
            setState(() {
              _selectedFile = file;
              _selectedFileName =
                  'camera_${DateTime.now().millisecondsSinceEpoch}.jpg';
            });
          }
          break;

        case 'gallery':
          final ImagePicker picker = ImagePicker();
          final XFile? image = await picker.pickImage(
            source: ImageSource.gallery,
            maxWidth: 1920,
            maxHeight: 1080,
            imageQuality: 85,
          );

          if (image != null) {
            final file = File(image.path);
            setState(() {
              _selectedFile = file;
              _selectedFileName = path.basename(image.path);
            });
          }
          break;
      }
    } catch (e) {
      _showModernSnackBar('Error selecting file: $e', const Color(0xFFFF453A));
    }
  }

  void _uploadDocument() {
    if (_selectedFile == null) return;

    final session = ref.read(sessionProvider);
    if (session == null) {
      _showModernSnackBar('Error: No active session', const Color(0xFFFF453A));
      return;
    }

    final projectId = widget.projectId ?? _selectedProject?.id;

    ref
        .read(documentUploadProvider.notifier)
        .uploadDocument(
          filename: _selectedFileName!,
          file: _selectedFile!,
          uploadedBy: session.id,
          projectId: projectId,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
        );
  }

  IconData _getFileIcon(String filename) {
    final extension = filename.split('.').last.toLowerCase();

    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'doc':
      case 'docx':
        return Icons.description_outlined;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart_outlined;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  String _getFileSize() {
    if (_selectedFile == null) return '0 B';

    final bytes = _selectedFile!.lengthSync();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
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
          duration: const Duration(seconds: 4),
        ),
      );
  }
}
