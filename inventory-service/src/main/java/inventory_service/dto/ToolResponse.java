package inventory_service.dto;

import lombok.Builder;
import lombok.Data;

import java.time.ZonedDateTime;
import java.util.UUID;

@Data
@Builder
public class ToolResponse {
    private UUID id;
    private String name;
    private String description;
    private ZonedDateTime createdAt;
}
