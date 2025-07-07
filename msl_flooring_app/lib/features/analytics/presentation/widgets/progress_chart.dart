// lib/features/analytics/presentation/widgets/progress_chart.dart

import 'package:flutter/material.dart';
import '../../domain/entities/chart_data_entity.dart';

class ProgressChart extends StatelessWidget {
  final List<TimeSeriesDataEntity> data;

  const ProgressChart({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Progreso en el Tiempo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(height: 200, child: _buildProgressChart()),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressChart() {
    if (data.isEmpty) {
      return const Center(child: Text('No hay datos disponibles'));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Inicio: ${data.first.value.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                'Actual: ${data.last.value.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: data.last.value / 100,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          const SizedBox(height: 16),
          Text(
            'Tendencia: ${data.last.value > data.first.value ? 'Creciente' : 'Decreciente'}',
            style: TextStyle(
              color: data.last.value > data.first.value
                  ? Colors.green
                  : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
