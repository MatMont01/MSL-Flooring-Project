// lib/features/notifications/presentation/providers/notification_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/notification_remote_data_source.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';

// --- Providers de infraestructura ---

final notificationRemoteDataSourceProvider =
    Provider<NotificationRemoteDataSource>((ref) {
      final apiClient = ref.watch(apiClientProvider);
      return NotificationRemoteDataSourceImpl(apiClient: apiClient);
    });

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final remoteDataSource = ref.watch(notificationRemoteDataSourceProvider);
  return NotificationRepositoryImpl(remoteDataSource: remoteDataSource);
});

// --- State Notifier ---

final notificationStateProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
      final notificationRepository = ref.watch(notificationRepositoryProvider);
      return NotificationNotifier(notificationRepository)..fetchData();
    });

// --- Estados ---

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

// --- Notifier ---

class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationRepository _notificationRepository;

  NotificationNotifier(this._notificationRepository)
    : super(NotificationInitial());

  Future<void> fetchData() async {
    try {
      state = NotificationLoading();

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
