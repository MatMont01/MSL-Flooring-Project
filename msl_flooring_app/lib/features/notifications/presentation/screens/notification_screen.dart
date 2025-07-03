// lib/features/notification/presentation/screens/notification_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notification_providers.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observamos el estado del provider
    final notificationState = ref.watch(notificationStateProvider);

    return DefaultTabController(
      length: 2, // Dos pestañas: Notificaciones y Documentos
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Comunicaciones'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Notificaciones'),
              Tab(text: 'Documentos'),
            ],
          ),
        ),
        body: Center(
          // Usamos un switch para construir la UI según el estado
          child: switch (notificationState) {
            NotificationInitial() ||
            NotificationLoading() => const CircularProgressIndicator(),
            NotificationSuccess(
              notifications: final notifications,
              documents: final documents,
            ) =>
              TabBarView(
                children: [
                  // --- Pestaña de Notificaciones ---
                  ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return ListTile(
                        leading: const Icon(Icons.notifications),
                        title: Text(notification.title ?? 'Sin Título'),
                        subtitle: Text(notification.message ?? 'Sin Mensaje'),
                      );
                    },
                  ),
                  // --- Pestaña de Documentos ---
                  ListView.builder(
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      final document = documents[index];
                      return ListTile(
                        leading: const Icon(Icons.article),
                        title: Text(document.filename),
                        subtitle: Text(
                          'Subido el: ${document.uploadedAt.toLocal().toString().substring(0, 10)}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: () {
                            // TODO: Implementar lógica de descarga
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            NotificationFailure(message: final message) => Text(
              'Error: $message',
            ),
            // TODO: Handle this case.
            NotificationState() => throw UnimplementedError(),
          },
        ),
      ),
    );
  }
}
