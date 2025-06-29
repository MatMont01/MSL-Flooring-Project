package inventory_service.dto;

import lombok.Data;

import java.util.UUID;

@Data
public class InventoryMovementRequest {
    private UUID materialId;
    private UUID projectId; // Puede ser null para movimientos generales
    private Integer quantity;
    private String movementType; // "IN" o "OUT"
}
