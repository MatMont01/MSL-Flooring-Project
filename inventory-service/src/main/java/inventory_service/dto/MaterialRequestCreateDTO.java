package inventory_service.dto;

import lombok.Data;

import java.util.UUID;

@Data
public class MaterialRequestCreateDTO {
    private UUID projectId;
    private UUID materialId;
    private int quantity;
}
