package inventory_service.dto;

import lombok.Data;

import java.util.UUID;
import java.time.ZonedDateTime;

@Data
public class ToolAssignmentRequest {
    private UUID toolId;
    private UUID workerId;   // Puede ser null
    private UUID projectId;  // Puede ser null
    private ZonedDateTime dueDate;
}
