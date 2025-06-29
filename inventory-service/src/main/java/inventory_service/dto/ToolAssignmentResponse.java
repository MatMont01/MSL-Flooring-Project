package inventory_service.dto;

import lombok.Builder;
import lombok.Data;

import java.time.ZonedDateTime;
import java.util.UUID;

@Data
@Builder
public class ToolAssignmentResponse {
    private UUID id;
    private UUID toolId;
    private UUID workerId;
    private UUID projectId;
    private ZonedDateTime assignedAt;
    private ZonedDateTime dueDate;
    private ZonedDateTime returnedAt;
}
