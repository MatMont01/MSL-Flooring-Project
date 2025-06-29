package inventory_service.service;

import inventory_service.dto.MaterialRequest;
import inventory_service.dto.MaterialResponse;

import java.util.List;
import java.util.UUID;

public interface MaterialService {
    MaterialResponse createMaterial(MaterialRequest request);

    List<MaterialResponse> getAllMaterials();

    MaterialResponse getMaterialById(UUID id);
}
