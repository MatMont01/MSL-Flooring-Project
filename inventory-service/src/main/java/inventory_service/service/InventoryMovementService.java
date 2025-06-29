package inventory_service.service;

import inventory_service.dto.InventoryMovementRequest;
import inventory_service.dto.InventoryMovementResponse;

import java.util.List;
import java.util.UUID;

public interface InventoryMovementService {
    InventoryMovementResponse recordMovement(InventoryMovementRequest request);

    List<InventoryMovementResponse> getMovementsByMaterial(UUID materialId);

    List<InventoryMovementResponse> getMovementsByProject(UUID projectId);

    int getAvailableStock(UUID materialId);

}
