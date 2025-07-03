// lib/features/notification/presentation/providers/notification_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/notification_remote_data_source.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';

// --- Providers para la infraestructura de datos de Notificaciones ---

// 1. Provider para el NotificationRemoteDataSource
final notificationRemoteDataSourceProvider =
    Provider<NotificationRemoteDataSource>((ref) {
      // Reutilizamos el apiClientProvider que ya maneja el token
      final apiClient = ref.watch(apiClientProvider);
      return NotificationRemoteDataSourceImpl(apiClient: apiClient);
    });

// 2. Provider para el NotificationRepository
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final remoteDataSource = ref.watch(notificationRemoteDataSourceProvider);
  return NotificationRepositoryImpl(remoteDataSource: remoteDataSource);
});

// --- State Notifier para la lista de Notificaciones y Documentos ---

// 3. Provider del Notifier que nuestra UI observará
final notificationStateProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
      final notificationRepository = ref.watch(notificationRepositoryProvider);
      // Creamos la instancia y llamamos al método para cargar los datos
      return NotificationNotifier(notificationRepository)..fetchData();
    });

// --- Clases de Estado para la UI ---

// 4. Definimos los posibles estados de nuestra pantalla
abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationSuccess extends NotificationState {
  final List<NotificationEntity> notifications;
  final List<DocumentEntity> documents;

  NotificationSuccess({required this.notifications, required this.documents});
}

class NotificationFailure extends NotificationState {
  final String message;

  NotificationFailure(this.message);
}

// --- El Notifier ---

// 5. La clase que contiene la lógica para obtener los datos y manejar el estado
class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationRepository _notificationRepository;

  NotificationNotifier(this._notificationRepository)
    : super(NotificationInitial());

  Future<void> fetchData() async {
    try {
      state = NotificationLoading();

      // Hacemos las dos llamadas a la API en paralelo para mayor eficiencia
      final results = await Future.wait([
        _notificationRepository.getAllNotifications(),
        _notificationRepository.getAllDocuments(),
      ]);

      final notifications = results[0] as List<NotificationEntity>;
      final documents = results[1] as List<DocumentEntity>;

      state = NotificationSuccess(
        notifications: notifications,
        documents: documents,
      );
    } catch (e) {
      state = NotificationFailure(e.toString());
    }
  }
}
