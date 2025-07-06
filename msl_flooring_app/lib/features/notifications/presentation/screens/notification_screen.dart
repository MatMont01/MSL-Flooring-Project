// lib/features/notifications/presentation/screens/notification_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/notification_providers.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsState = ref.watch(notificationStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones y Documentos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(notificationStateProvider.notifier).fetchData();
            },
          ),
        ],
      ),
      body: switch (notificationsState) {
        NotificationInitial() || NotificationLoading() => const Center(
          child: CircularProgressIndicator(),
        ),
        NotificationSuccess(
          notifications: final notifications,
          documents: final documents,
        ) =>
          DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'Notificaciones'),
                    Tab(text: 'Documentos'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildNotificationsList(notifications),
                      _buildDocumentsList(documents),
                    ],
                  ),
                ),
              ],
            ),
          ),
        NotificationFailure(message: final message) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $message'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(notificationStateProvider.notifier).fetchData();
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        // TODO: Handle this case.
        NotificationState() => throw UnimplementedError(),
      },
    );
  }

  Widget _buildNotificationsList(notifications) {
    if (notifications.isEmpty) {
      return const Center(child: Text('No hay notificaciones'));
    }

    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: const Icon(Icons.notifications),
            title: Text(notification.title ?? 'Sin título'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification.message ?? 'Sin mensaje'),
                const SizedBox(height: 4),
                Text(
                  DateFormat('yyyy-MM-dd HH:mm').format(notification.createdAt),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            trailing: notification.type != null
                ? Chip(label: Text(notification.type!))
                : null,
          ),
        );
      },
    );
  }

  Widget _buildDocumentsList(documents) {
    if (documents.isEmpty) {
      return const Center(child: Text('No hay documentos'));
    }

    return ListView.builder(
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final document = documents[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: const Icon(Icons.description),
            title: Text(document.filename),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Subido por: ${document.uploadedBy}'),
                if (document.projectId != null)
                  Text('Proyecto: ${document.projectId}'),
                Text(
                  DateFormat('yyyy-MM-dd HH:mm').format(document.uploadedAt),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.download),
              onPressed: () {
                // Aquí puedes implementar la lógica para descargar el archivo
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Descargando ${document.filename}...'),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
