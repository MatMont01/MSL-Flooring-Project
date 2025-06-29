package inventory_service.dto;

import lombok.Builder;
import lombok.Data;

import java.time.ZonedDateTime;
import java.util.UUID;

@Data
@Builder
public class InventoryMovementResponse {
    private UUID id;
    private UUID materialId;
    private UUID projectId;
    private Integer quantity;
    private String movementType;
    private ZonedDateTime movementDate;
}
