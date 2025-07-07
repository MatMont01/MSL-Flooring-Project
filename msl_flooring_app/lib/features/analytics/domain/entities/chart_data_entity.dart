// lib/features/analytics/domain/entities/chart_data_entity.dart

class ChartDataEntity {
  final String label;
  final double value;
  final String category;
  final DateTime? date;
  final Map<String, dynamic>? metadata;

  const ChartDataEntity({
    required this.label,
    required this.value,
    required this.category,
    this.date,
    this.metadata,
  });
}

class TimeSeriesDataEntity {
  final DateTime date;
  final double value;
  final String metric;

  const TimeSeriesDataEntity({
    required this.date,
    required this.value,
    required this.metric,
  });
}

class KpiEntity {
  final String id;
  final String title;
  final String value;
  final String subtitle;
  final double? percentageChange;
  final bool isPositive;
  final String icon;
  final String color;

  const KpiEntity({
    required this.id,
    required this.title,
    required this.value,
    required this.subtitle,
    this.percentageChange,
    required this.isPositive,
    required this.icon,
    required this.color,
  });
}
