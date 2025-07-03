// lib/features/analytics/data/models/report_model.dart

import '../../domain/entities/report_entity.dart';

class ReportModel extends ReportEntity {
  const ReportModel({
    required super.id,
    required super.reportType,
    super.parameters,
    required super.generatedAt,
    super.data,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'],
      reportType: json['reportType'],
      parameters: json['parameters'],
      // Se mantiene como String
      generatedAt: DateTime.parse(json['generatedAt']),
      data: json['data'], // Se mantiene como String
    );
  }
}
