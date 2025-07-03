// lib/features/analytics/presentation/screens/analytics_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../providers/analytics_providers.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observamos el estado del provider
    final analyticsState = ref.watch(analyticsStateProvider);

    return DefaultTabController(
      length: 2, // Dos pestañas: Métricas y Reportes
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Analíticas'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Métricas'),
              Tab(text: 'Reportes'),
            ],
          ),
        ),
        body: Center(
          // Usamos un switch para construir la UI según el estado
          child: switch (analyticsState) {
            AnalyticsInitial() ||
            AnalyticsLoading() => const CircularProgressIndicator(),
            AnalyticsSuccess(metrics: final metrics, reports: final reports) =>
              TabBarView(
                children: [
                  // --- Pestaña de Métricas ---
                  ListView.builder(
                    itemCount: metrics.length,
                    itemBuilder: (context, index) {
                      final metric = metrics[index];
                      return ListTile(
                        leading: const Icon(Icons.show_chart),
                        title: Text(metric.name),
                        trailing: Text(
                          metric.value?.toStringAsFixed(2) ?? 'N/A',
                        ),
                      );
                    },
                  ),
                  // --- Pestaña de Reportes ---
                  ListView.builder(
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final report = reports[index];
                      return ListTile(
                        leading: const Icon(Icons.assessment),
                        title: Text(report.reportType),
                        subtitle: Text(
                          'Generado: ${report.generatedAt.toLocal().toString().substring(0, 10)}',
                        ),
                        onTap: () {
                          // Mostrar el contenido del reporte en un diálogo
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(report.reportType),
                              content: SingleChildScrollView(
                                child: Text(
                                  _formatJsonString(report.data ?? '{}'),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  child: const Text('Cerrar'),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            AnalyticsFailure(message: final message) => Text('Error: $message'),
            // TODO: Handle this case.
            AnalyticsState() => throw UnimplementedError(),
          },
        ),
      ),
    );
  }

  // Helper para formatear el JSON y que se vea bonito
  String _formatJsonString(String jsonString) {
    try {
      final jsonObject = jsonDecode(jsonString);
      const encoder = JsonEncoder.withIndent('  '); // 2 espacios de indentación
      return encoder.convert(jsonObject);
    } catch (e) {
      return jsonString; // Si no es un JSON válido, lo devuelve como está
    }
  }
}
