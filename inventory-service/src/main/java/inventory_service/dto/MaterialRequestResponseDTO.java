package inventory_service.dto;

import lombok.Builder;
import lombok.Data;

import java.time.ZonedDateTime;
import java.util.UUID;

@Data
@Builder
public class MaterialRequestResponseDTO {
    private UUID id;
    private UUID projectId;
    private UUID materialId;
    private int quantity;
    private String status;
    private ZonedDateTime requestedAt;
    private ZonedDateTime approvedAt;
}
