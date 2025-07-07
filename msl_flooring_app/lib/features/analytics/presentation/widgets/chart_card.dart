// lib/features/analytics/presentation/widgets/chart_card.dart

import 'package:flutter/material.dart';
import '../../domain/entities/chart_data_entity.dart';

enum ChartType { pie, donut, bar, line }

class ChartCard extends StatelessWidget {
  final String title;
  final List<ChartDataEntity> data;
  final ChartType chartType;

  const ChartCard({
    required this.title,
    required this.data,
    required this.chartType,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // 🔧 ADDED
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              maxLines: 1, // 🔧 ADDED
              overflow: TextOverflow.ellipsis, // 🔧 ADDED
            ),
            const SizedBox(height: 16),
            Expanded(
              // 🔧 CHANGED from SizedBox to Expanded
              child: _buildChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    if (data.isEmpty) {
      return const Center(
        child: Text(
          'No hay datos disponibles',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    // Por ahora, mostrar una lista simple
    // En el futuro, aquí iría fl_chart o charts_flutter
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        final percentage = _calculatePercentage(item.value);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: _getColor(index),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.label,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  maxLines: 1, // 🔧 ADDED
                  overflow: TextOverflow.ellipsis, // 🔧 ADDED
                ),
              ),
              const SizedBox(width: 8), // 🔧 ADDED spacing
              Text(
                '${_formatValue(item.value)} (${percentage.toStringAsFixed(1)}%)',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatValue(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    } else {
      return value.toStringAsFixed(0);
    }
  }

  double _calculatePercentage(double value) {
    final total = data.fold(0.0, (sum, item) => sum + item.value);
    return total > 0 ? (value / total) * 100 : 0;
  }

  Color _getColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    return colors[index % colors.length];
  }
}
