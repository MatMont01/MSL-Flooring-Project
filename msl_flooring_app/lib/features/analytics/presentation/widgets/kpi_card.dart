// lib/features/analytics/presentation/widgets/kpi_card.dart

import 'package:flutter/material.dart';
import '../../domain/entities/chart_data_entity.dart';

class KpiCard extends StatelessWidget {
  final KpiEntity kpi;

  const KpiCard({required this.kpi, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(10), // 🔧 REDUCED from 12 to 10
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Row - más compacto
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4), // 🔧 REDUCED from 6 to 4
                  decoration: BoxDecoration(
                    color: _getColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6), // 🔧 REDUCED
                  ),
                  child: Icon(
                    _getIconData(),
                    color: _getColor(),
                    size: 16, // 🔧 REDUCED from 18 to 16
                  ),
                ),
                const Spacer(),
                if (kpi.percentageChange != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ), // 🔧 REDUCED
                    decoration: BoxDecoration(
                      color: kpi.isPositive
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${kpi.isPositive ? '+' : ''}${kpi.percentageChange!.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: kpi.isPositive ? Colors.green : Colors.red,
                        fontSize: 9, // 🔧 REDUCED from 10 to 9
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 6), // 🔧 REDUCED from 8 to 6
            // Value - más compacto
            Flexible(
              child: FittedBox(
                // 🔧 ADDED FittedBox para ajuste automático
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  kpi.value,
                  style: const TextStyle(
                    fontSize: 18, // 🔧 REDUCED from 20 to 18
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                ),
              ),
            ),

            const SizedBox(height: 3), // 🔧 REDUCED from 4 to 3
            // Title
            Flexible(
              child: Text(
                kpi.title,
                style: const TextStyle(
                  fontSize: 11, // 🔧 REDUCED from 12 to 11
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 1), // 🔧 REDUCED from 2 to 1
            // Subtitle
            Flexible(
              child: Text(
                kpi.subtitle,
                style: TextStyle(
                  fontSize: 9, // 🔧 REDUCED from 10 to 9
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData() {
    switch (kpi.icon) {
      case 'business_center':
        return Icons.business_center;
      case 'attach_money':
        return Icons.attach_money;
      case 'trending_up':
        return Icons.trending_up;
      case 'people':
        return Icons.people;
      default:
        return Icons.analytics;
    }
  }

  Color _getColor() {
    switch (kpi.color) {
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
