// lib/features/inventory/data/models/material_request_model.dart

import '../../domain/entities/material_request_entity.dart';

// Este modelo extiende la entidad del dominio para mantener la consistencia
// y añade la lógica para convertir el objeto a JSON.
class MaterialRequestModel extends MaterialRequestEntity {
  const MaterialRequestModel({
    required super.name,
    required super.description,
    super.imageUrl,
    required super.unitPrice,
  });

  // Método que convierte el objeto a un mapa, listo para ser enviado como
  // el cuerpo de la petición POST.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'unitPrice': unitPrice,
    };
  }
}
