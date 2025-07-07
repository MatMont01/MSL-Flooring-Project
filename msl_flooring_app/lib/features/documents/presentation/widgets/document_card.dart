// lib/features/documents/presentation/widgets/document_card.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/document_entity.dart';
import '../providers/document_download_provider.dart';

class DocumentCard extends ConsumerStatefulWidget {
  final DocumentEntity document;
  final bool isAdmin;
  final VoidCallback? onDelete;
  final VoidCallback? onPermissions;
  final VoidCallback? onDownload;
  final bool showProject;

  const DocumentCard({
    required this.document,
    required this.isAdmin,
    this.onDelete,
    this.onPermissions,
    this.onDownload,
    this.showProject = true,
    super.key,
  });

  @override
  ConsumerState<DocumentCard> createState() => _DocumentCardState();
}

class _DocumentCardState extends ConsumerState<DocumentCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _progressController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _fadeAnimation;

  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    // 🎭 Configurar animaciones
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutQuart),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutQuart),
    );

    // Iniciar animación de aparición
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fadeController.forward();
    });

    // Escuchar cambios en descarga
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listen<DocumentDownloadState>(documentDownloadProvider, (
        previous,
        next,
      ) {
        if (!mounted) return;

        if (next is DocumentDownloadSuccess &&
            next.documentId == widget.document.id) {
          _showModernSnackBar(
            '${next.filename} downloaded successfully',
            const Color(0xFF32D74B),
            actionLabel: 'Open',
            action: () => ref
                .read(documentDownloadProvider.notifier)
                .openDownloadedFile(next.filePath),
          );
        }

        if (next is DocumentDownloadFailure &&
            next.documentId == widget.document.id) {
          _showModernSnackBar(
            'Error: ${next.errorMessage}',
            const Color(0xFFFF453A),
            actionLabel: 'Retry',
            action: _downloadDocument,
          );
        }

        if (next is DocumentDownloadProgress &&
            next.documentId == widget.document.id) {
          if (!_progressController.isAnimating) {
            _progressController.forward();
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _progressController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final downloadState = ref.watch(documentDownloadProvider);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: _buildCard(downloadState),
          );
        },
      ),
    );
  }

  Widget _buildCard(DocumentDownloadState downloadState) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF1A1A1F).withOpacity(0.9),
        border: Border.all(
          color: const Color(0xFF2A2A2F).withOpacity(0.6),
          width: 1,
        ),
        boxShadow: _isHovered
            ? [
                BoxShadow(
                  color: _getFileTypeColor().withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showDocumentDetails(context),
          onHover: (hover) {
            setState(() {
              _isHovered = hover;
            });
            if (hover) {
              _scaleController.forward();
            } else {
              _scaleController.reverse();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildFileInfo(),
                const SizedBox(height: 16),
                _buildMetadata(),
                if (widget.showProject &&
                    widget.document.projectId != null) ...[
                  const SizedBox(height: 12),
                  _buildProjectInfo(),
                ],
                if (downloadState is DocumentDownloadProgress &&
                    downloadState.documentId == widget.document.id) ...[
                  const SizedBox(height: 20),
                  _buildProgressIndicator(downloadState),
                ],
                const SizedBox(height: 20),
                _buildActionButtons(downloadState),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🎯 Header con icono y menú
  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: _getFileTypeColor().withOpacity(0.1),
            border: Border.all(
              color: _getFileTypeColor().withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Icon(_getFileTypeIcon(), color: _getFileTypeColor(), size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.document.filename,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFE5E5E7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              _buildFileTypeChip(),
            ],
          ),
        ),
        _buildMenuButton(),
      ],
    );
  }

  // 🏷️ Chip de tipo de archivo
  Widget _buildFileTypeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getFileTypeColor().withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getFileTypeColor().withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        widget.document.fileExtension.toUpperCase(),
        style: TextStyle(
          color: _getFileTypeColor(),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ⚙️ Botón de menú
  Widget _buildMenuButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF2A2A2F).withOpacity(0.6),
      ),
      child: PopupMenuButton<String>(
        onSelected: _handleMenuAction,
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
          _buildMenuItem(Icons.visibility_outlined, 'View Details', 'view'),
          _buildMenuItem(
            Icons.download_outlined,
            'Download',
            'download',
            color: const Color(0xFF32D74B),
          ),
          _buildMenuItem(Icons.share_outlined, 'Copy Link', 'share'),
          if (widget.isAdmin && widget.onPermissions != null)
            _buildMenuItem(
              Icons.security_outlined,
              'Permissions',
              'permissions',
              color: const Color(0xFF007AFF),
            ),
          if (widget.onDelete != null) ...[
            const PopupMenuDivider(),
            _buildMenuItem(
              Icons.delete_outline,
              'Delete',
              'delete',
              color: const Color(0xFFFF453A),
            ),
          ],
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(
    IconData icon,
    String text,
    String value, {
    Color? color,
  }) {
    final itemColor = color ?? const Color(0xFF8E8E93);
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: itemColor),
          const SizedBox(width: 12),
          Text(text, style: TextStyle(color: itemColor, fontSize: 14)),
        ],
      ),
    );
  }

  // 📊 Información del archivo
  Widget _buildFileInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF2A2A2F).withOpacity(0.4),
        border: Border.all(
          color: const Color(0xFF3A3A3F).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _buildInfoItem(
            Icons.data_usage_outlined,
            'Size',
            widget.document.fileSizeFormatted,
          ),
          const SizedBox(width: 20),
          _buildInfoItem(
            Icons.access_time_outlined,
            'Uploaded',
            _formatUploadDate(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF8E8E93)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93)),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFE5E5E7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 👤 Metadata del documento
  Widget _buildMetadata() {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF007AFF).withOpacity(0.2),
          ),
          child: const Icon(
            Icons.person_outline,
            size: 14,
            color: Color(0xFF007AFF),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Uploaded by: ${_formatUploadedBy()}',
          style: const TextStyle(fontSize: 13, color: Color(0xFF8E8E93)),
        ),
      ],
    );
  }

  // 🏗️ Información del proyecto
  Widget _buildProjectInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFFAF52DE).withOpacity(0.1),
        border: Border.all(
          color: const Color(0xFFAF52DE).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.business_center_outlined,
            size: 16,
            color: const Color(0xFFAF52DE),
          ),
          const SizedBox(width: 8),
          Text(
            'Project: ${widget.document.projectId}',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFFAF52DE),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // 📊 Indicador de progreso
  Widget _buildProgressIndicator(DocumentDownloadProgress downloadState) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _progressAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
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
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        value: downloadState.progress,
                        backgroundColor: const Color(0xFF2A2A2F),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF007AFF),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Downloading...',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFE5E5E7),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${(downloadState.progress * 100).toInt()}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF007AFF),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: downloadState.progress,
                    backgroundColor: const Color(0xFF2A2A2F),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF007AFF),
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 🔘 Botones de acción
  Widget _buildActionButtons(DocumentDownloadState downloadState) {
    final isDownloading =
        downloadState is DocumentDownloadProgress &&
        downloadState.documentId == widget.document.id;

    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.visibility_outlined,
            label: 'View',
            onPressed: () => _showDocumentDetails(context),
            isPrimary: false,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.download_outlined,
            label: isDownloading ? 'Downloading' : 'Download',
            onPressed: isDownloading ? null : _downloadDocument,
            isPrimary: true,
            color: _getFileTypeColor(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required bool isPrimary,
    Color? color,
  }) {
    final buttonColor = color ?? _getFileTypeColor();

    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isPrimary
            ? buttonColor.withOpacity(0.1)
            : const Color(0xFF2A2A2F).withOpacity(0.6),
        border: Border.all(
          color: isPrimary
              ? buttonColor.withOpacity(0.3)
              : const Color(0xFF3A3A3F).withOpacity(0.6),
          width: 1,
        ),
      ),
      child: TextButton.icon(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Icon(
          icon,
          size: 18,
          color: isPrimary ? buttonColor : const Color(0xFF8E8E93),
        ),
        label: Text(
          label,
          style: TextStyle(
            color: isPrimary ? buttonColor : const Color(0xFF8E8E93),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // 🔧 Métodos de utilidad
  void _handleMenuAction(String action) {
    switch (action) {
      case 'view':
        _showDocumentDetails(context);
        break;
      case 'download':
        _downloadDocument();
        break;
      case 'share':
        _shareDocument();
        break;
      case 'permissions':
        widget.onPermissions?.call();
        break;
      case 'delete':
        _confirmDelete();
        break;
    }
  }

  void _downloadDocument() {
    final downloadUrl =
        'http://10.0.2.2:8085/api/documents/${widget.document.id}/download';

    ref
        .read(documentDownloadProvider.notifier)
        .downloadDocument(
          documentId: widget.document.id,
          filename: widget.document.filename,
          downloadUrl: downloadUrl,
        );
  }

  void _showDocumentDetails(BuildContext context) {
    showDialog(context: context, builder: (context) => _buildModernDialog());
  }

  // 💬 Diálogo moderno
  Widget _buildModernDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
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
            // Header del diálogo
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: _getFileTypeColor().withOpacity(0.1),
                    border: Border.all(
                      color: _getFileTypeColor().withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    _getFileTypeIcon(),
                    color: _getFileTypeColor(),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.document.filename,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFE5E5E7),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Detalles
            ...[
              _buildDialogDetailRow('File Type', widget.document.fileExtension),
              _buildDialogDetailRow('Size', widget.document.fileSizeFormatted),
              _buildDialogDetailRow('Uploaded By', _formatUploadedBy()),
              _buildDialogDetailRow('Upload Date', _formatUploadDate()),
              if (widget.document.projectId != null)
                _buildDialogDetailRow('Project', widget.document.projectId!),
              _buildDialogDetailRow('Document ID', widget.document.id),
            ],
            const SizedBox(height: 24),
            // Botones
            Row(
              children: [
                Expanded(
                  child: _buildDialogButton(
                    'Close',
                    () => Navigator.pop(context),
                    false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDialogButton('Download', () {
                    Navigator.pop(context);
                    _downloadDocument();
                  }, true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogDetailRow(String label, String value) {
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
            child: SelectableText(
              value,
              style: const TextStyle(color: Color(0xFFE5E5E7), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogButton(
    String text,
    VoidCallback onPressed,
    bool isPrimary,
  ) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isPrimary
            ? _getFileTypeColor().withOpacity(0.1)
            : const Color(0xFF2A2A2F),
        border: Border.all(
          color: isPrimary
              ? _getFileTypeColor().withOpacity(0.3)
              : const Color(0xFF3A3A3F).withOpacity(0.6),
          width: 1,
        ),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isPrimary ? _getFileTypeColor() : const Color(0xFFE5E5E7),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _shareDocument() {
    Clipboard.setData(ClipboardData(text: widget.document.fileUrl));
    _showModernSnackBar(
      'Document link copied to clipboard',
      const Color(0xFF32D74B),
    );
  }

  void _confirmDelete() {
    showDialog(context: context, builder: (context) => _buildDeleteDialog());
  }

  Widget _buildDeleteDialog() {
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
            Text(
              'Are you sure you want to delete "${widget.document.filename}"?',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF8E8E93)),
            ),
            const SizedBox(height: 6),
            const Text(
              'This action cannot be undone.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFFFF453A),
                fontWeight: FontWeight.w500,
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
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFFFF453A).withOpacity(0.1),
                      border: Border.all(
                        color: const Color(0xFFFF453A).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onDelete?.call();
                      },
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          color: Color(0xFFFF453A),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showModernSnackBar(
    String message,
    Color color, {
    String? actionLabel,
    VoidCallback? action,
  }) {
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
          action: actionLabel != null
              ? SnackBarAction(
                  label: actionLabel,
                  textColor: Colors.white,
                  onPressed: action ?? () {},
                )
              : null,
        ),
      );
  }

  // 🎨 Métodos de estilo
  IconData _getFileTypeIcon() {
    if (widget.document.isImage) return Icons.image_outlined;
    if (widget.document.isPdf) return Icons.picture_as_pdf_outlined;

    final extension = widget.document.fileExtension.toLowerCase();
    switch (extension) {
      case 'doc':
      case 'docx':
        return Icons.description_outlined;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart_outlined;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow_outlined;
      case 'txt':
        return Icons.text_snippet_outlined;
      case 'zip':
      case 'rar':
        return Icons.archive_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  Color _getFileTypeColor() {
    if (widget.document.isImage) return const Color(0xFF32D74B);
    if (widget.document.isPdf) return const Color(0xFFFF453A);

    final extension = widget.document.fileExtension.toLowerCase();
    switch (extension) {
      case 'doc':
      case 'docx':
        return const Color(0xFF007AFF);
      case 'xls':
      case 'xlsx':
        return const Color(0xFF32D74B);
      case 'ppt':
      case 'pptx':
        return const Color(0xFFFF9F0A);
      case 'txt':
        return const Color(0xFF8E8E93);
      case 'zip':
      case 'rar':
        return const Color(0xFFAF52DE);
      default:
        return const Color(0xFF8E8E93);
    }
  }

  String _formatUploadedBy() {
    return widget.document.uploadedBy.substring(0, 8);
  }

  String _formatUploadDate() {
    final now = DateTime.now();
    final difference = now.difference(widget.document.uploadedAt);

    if (difference.inDays > 7) {
      return '${widget.document.uploadedAt.day}/${widget.document.uploadedAt.month}/${widget.document.uploadedAt.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} min${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
