// lib/features/worker/data/models/worker_model.dart

import '../../domain/entities/worker_entity.dart';

class WorkerModel extends WorkerEntity {
  const WorkerModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    super.phone,
    super.dateHired,
    required super.createdAt,
  });

  factory WorkerModel.fromJson(Map<String, dynamic> json) {
    return WorkerModel(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      // Hacemos una comprobación para los campos que pueden ser nulos
      phone: json['phone'],
      dateHired: json['dateHired'] != null
          ? DateTime.parse(json['dateHired'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
