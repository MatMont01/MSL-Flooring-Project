// lib/features/analytics/presentation/widgets/financial_summary_card.dart

import 'package:flutter/material.dart';

class FinancialSummaryCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const FinancialSummaryCard({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildFinancialRow(
              'Ingresos Totales',
              '\$${_formatNumber(data['totalRevenue'] ?? 0)}',
              Icons.trending_up,
              Colors.green,
            ),
            const Divider(),
            _buildFinancialRow(
              'Gastos Totales',
              '\$${_formatNumber(data['totalExpenses'] ?? 0)}',
              Icons.trending_down,
              Colors.red,
            ),
            const Divider(),
            _buildFinancialRow(
              'Ganancia Neta',
              '\$${_formatNumber(data['profit'] ?? 0)}',
              Icons.account_balance,
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(dynamic number) {
    if (number is int) {
      return number.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
    }
    if (number is double) {
      return number
          .toStringAsFixed(0)
          .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
    }
    return '0';
  }
}
