// lib/features/documents/domain/services/document_download_service.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DocumentDownloadService {
  final Dio _dio;
  final SharedPreferences _sharedPreferences;

  DocumentDownloadService({
    required SharedPreferences sharedPreferences,
    Dio? dio,
  }) : _sharedPreferences = sharedPreferences,
       _dio = dio ?? Dio();

  /// Descargar documento y guardarlo en la carpeta de descargas
  Future<DownloadResult> downloadDocument({
    required String documentId,
    required String filename,
    required String downloadUrl,
    Function(double)? onProgress,
  }) async {
    try {
      print('📥 [DownloadService] Starting download: $filename');
      print('📥 [DownloadService] URL: $downloadUrl');

      // 1. Verificar y solicitar permisos
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        return DownloadResult.failure(
          'Permisos de almacenamiento denegados. Ve a Configuración > Permisos para habilitarlos.',
        );
      }

      // 2. Obtener la carpeta de descargas
      final downloadPath = await _getDownloadPath();
      if (downloadPath == null) {
        return DownloadResult.failure(
          'No se pudo acceder a la carpeta de descargas',
        );
      }

      // 3. Crear nombre único si el archivo ya existe
      final filePath = await _getUniqueFilePath(downloadPath, filename);
      print('📥 [DownloadService] Download path: $filePath');

      // 4. Configurar headers de autenticación
      final token = _sharedPreferences.getString('AUTH_TOKEN');
      final headers = <String, String>{
        if (token != null) 'Authorization': 'Bearer $token',
        'Accept': '*/*',
      };

      print('📥 [DownloadService] Headers configured');

      // 5. Descargar el archivo
      await _dio.download(
        downloadUrl,
        filePath,
        options: Options(
          headers: headers,
          receiveTimeout: const Duration(minutes: 5), // 5 minutos timeout
          sendTimeout: const Duration(minutes: 1),
        ),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            print(
              '📥 [DownloadService] Progress: ${(progress * 100).toStringAsFixed(1)}% ($received/$total bytes)',
            );
            onProgress?.call(progress);
          } else {
            print(
              '📥 [DownloadService] Progress: $received bytes (size unknown)',
            );
            // Para archivos sin Content-Length, mostrar progreso indeterminado
            onProgress?.call(0.5);
          }
        },
      );

      print('📥 [DownloadService] Download completed: $filePath');

      // 6. Verificar que el archivo se descargó correctamente
      final file = File(filePath);
      if (!file.existsSync()) {
        return DownloadResult.failure(
          'El archivo no se descargó correctamente',
        );
      }

      final fileSize = file.lengthSync();
      print('📥 [DownloadService] File size: ${_formatFileSize(fileSize)}');

      // 7. Verificar que el archivo no está vacío
      if (fileSize == 0) {
        file.deleteSync(); // Eliminar archivo vacío
        return DownloadResult.failure('El archivo descargado está vacío');
      }

      return DownloadResult.success(
        filePath: filePath,
        filename: _getFilenameFromPath(filePath),
        fileSize: fileSize,
      );
    } on DioException catch (e) {
      print('🔴 [DownloadService] Dio error: ${e.type} - ${e.message}');
      print('🔴 [DownloadService] Response: ${e.response?.data}');
      return DownloadResult.failure(_handleDioError(e));
    } catch (e, stackTrace) {
      print('🔴 [DownloadService] Unknown error: $e');
      print('🔴 [DownloadService] StackTrace: $stackTrace');
      return DownloadResult.failure('Error inesperado: $e');
    }
  }

  /// Abrir el archivo descargado con la aplicación predeterminada
  Future<bool> openDownloadedFile(String filePath) async {
    try {
      print('📱 [DownloadService] Opening file: $filePath');

      // Verificar que el archivo existe
      final file = File(filePath);
      if (!file.existsSync()) {
        print('🔴 [DownloadService] File does not exist: $filePath');
        return false;
      }

      final result = await OpenFile.open(filePath);

      if (result.type == ResultType.done) {
        print('📱 [DownloadService] File opened successfully');
        return true;
      } else {
        print('🔴 [DownloadService] Failed to open file: ${result.message}');
        return false;
      }
    } catch (e) {
      print('🔴 [DownloadService] Error opening file: $e');
      return false;
    }
  }

  /// Verificar y solicitar permisos de almacenamiento
  Future<bool> _requestStoragePermission() async {
    try {
      if (Platform.isAndroid) {
        print('📱 [DownloadService] Checking Android permissions');

        // Para Android, intentamos diferentes estrategias según la versión
        var status = await Permission.storage.status;
        print('📱 [DownloadService] Storage permission status: $status');

        if (status.isDenied) {
          status = await Permission.storage.request();
          print(
            '📱 [DownloadService] Storage permission after request: $status',
          );
        }

        if (status.isGranted) {
          return true;
        }

        // Si storage falló, intentar con manageExternalStorage para Android 11+
        var manageStatus = await Permission.manageExternalStorage.status;
        print(
          '📱 [DownloadService] Manage external storage status: $manageStatus',
        );

        if (manageStatus.isDenied) {
          manageStatus = await Permission.manageExternalStorage.request();
          print(
            '📱 [DownloadService] Manage external storage after request: $manageStatus',
          );
        }

        return manageStatus.isGranted || status.isGranted;
      } else {
        // iOS - Los archivos se guardan en el directorio de documentos de la app
        print(
          '📱 [DownloadService] iOS detected, using app documents directory',
        );
        return true;
      }
    } catch (e) {
      print('🔴 [DownloadService] Error checking permissions: $e');
      // En caso de error, intentamos continuar
      return true;
    }
  }

  /// Obtener la ruta de la carpeta de descargas
  Future<String?> _getDownloadPath() async {
    try {
      if (Platform.isAndroid) {
        // Intentar diferentes rutas de descarga para Android
        final possiblePaths = [
          '/storage/emulated/0/Download',
          '/storage/emulated/0/Downloads',
          '/sdcard/Download',
          '/sdcard/Downloads',
        ];

        for (final path in possiblePaths) {
          final directory = Directory(path);
          if (directory.existsSync()) {
            try {
              // Intentar escribir un archivo de prueba
              final testFile = File('$path/.test_write_access');
              await testFile.writeAsString('test');
              await testFile.delete();
              print('📁 [DownloadService] Using download path: $path');
              return path;
            } catch (e) {
              print('📁 [DownloadService] No write access to: $path');
              continue;
            }
          }
        }

        // Fallback a la carpeta de documentos externos
        try {
          final extDir = await getExternalStorageDirectory();
          if (extDir != null) {
            final downloadDir = Directory('${extDir.path}/Downloads');
            if (!downloadDir.existsSync()) {
              downloadDir.createSync(recursive: true);
            }
            print(
              '📁 [DownloadService] Using external storage: ${downloadDir.path}',
            );
            return downloadDir.path;
          }
        } catch (e) {
          print('📁 [DownloadService] External storage not available: $e');
        }

        // Último fallback - directorio de la aplicación
        final appDir = await getApplicationDocumentsDirectory();
        final downloadDir = Directory('${appDir.path}/Downloads');
        if (!downloadDir.existsSync()) {
          downloadDir.createSync(recursive: true);
        }
        print('📁 [DownloadService] Using app directory: ${downloadDir.path}');
        return downloadDir.path;
      } else {
        // iOS - usar carpeta de documentos de la app
        final directory = await getApplicationDocumentsDirectory();
        final downloadDir = Directory('${directory.path}/Downloads');
        if (!downloadDir.existsSync()) {
          downloadDir.createSync(recursive: true);
        }
        print(
          '📁 [DownloadService] Using iOS app directory: ${downloadDir.path}',
        );
        return downloadDir.path;
      }
    } catch (e) {
      print('🔴 [DownloadService] Error getting download path: $e');
      return null;
    }
  }

  /// Crear un nombre de archivo único si ya existe
  Future<String> _getUniqueFilePath(
    String downloadPath,
    String filename,
  ) async {
    final originalPath = '$downloadPath/$filename';
    final file = File(originalPath);

    if (!file.existsSync()) {
      return originalPath;
    }

    print('📁 [DownloadService] File already exists, creating unique name');

    // El archivo ya existe, crear un nombre único
    final nameWithoutExtension = filename.contains('.')
        ? filename.substring(0, filename.lastIndexOf('.'))
        : filename;
    final extension = filename.contains('.')
        ? filename.substring(filename.lastIndexOf('.'))
        : '';

    int counter = 1;
    while (true) {
      final newFilename = '${nameWithoutExtension}_($counter)$extension';
      final newPath = '$downloadPath/$newFilename';

      if (!File(newPath).existsSync()) {
        print('📁 [DownloadService] Using unique filename: $newFilename');
        return newPath;
      }
      counter++;

      // Prevenir bucle infinito
      if (counter > 999) {
        throw Exception('No se pudo crear un nombre de archivo único');
      }
    }
  }

  /// Obtener el nombre del archivo desde la ruta completa
  String _getFilenameFromPath(String filePath) {
    return filePath.split('/').last;
  }

  /// Manejar errores de Dio
  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Tiempo de conexión agotado. Verifica tu conexión a internet.';
      case DioExceptionType.sendTimeout:
        return 'Tiempo de envío agotado. El archivo puede ser muy grande.';
      case DioExceptionType.receiveTimeout:
        return 'Tiempo de descarga agotado. Intenta nuevamente.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 404) {
          return 'Documento no encontrado en el servidor';
        } else if (statusCode == 403) {
          return 'No tienes permisos para descargar este documento';
        } else if (statusCode == 401) {
          return 'Sesión expirada. Inicia sesión nuevamente';
        } else if (statusCode == 500) {
          return 'Error interno del servidor';
        } else if (statusCode == 503) {
          return 'Servicio no disponible temporalmente';
        }
        return 'Error del servidor (${statusCode ?? 'desconocido'})';
      case DioExceptionType.cancel:
        return 'Descarga cancelada por el usuario';
      case DioExceptionType.connectionError:
        return 'Error de conexión. Verifica tu conexión a internet';
      case DioExceptionType.unknown:
        return 'Error desconocido: ${e.message ?? 'Sin detalles'}';
      default:
        return 'Error de descarga: ${e.message ?? 'Error desconocido'}';
    }
  }

  /// Formatear tamaño de archivo
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

/// Resultado de la descarga
class DownloadResult {
  final bool isSuccess;
  final String? filePath;
  final String? filename;
  final int? fileSize;
  final String? errorMessage;

  DownloadResult._({
    required this.isSuccess,
    this.filePath,
    this.filename,
    this.fileSize,
    this.errorMessage,
  });

  factory DownloadResult.success({
    required String filePath,
    required String filename,
    required int fileSize,
  }) {
    return DownloadResult._(
      isSuccess: true,
      filePath: filePath,
      filename: filename,
      fileSize: fileSize,
    );
  }

  factory DownloadResult.failure(String errorMessage) {
    return DownloadResult._(isSuccess: false, errorMessage: errorMessage);
  }

  String get formattedFileSize {
    if (fileSize == null) return 'Tamaño desconocido';

    final bytes = fileSize!;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  String toString() {
    if (isSuccess) {
      return 'DownloadResult.success(filename: $filename, size: $formattedFileSize)';
    } else {
      return 'DownloadResult.failure(error: $errorMessage)';
    }
  }
}
