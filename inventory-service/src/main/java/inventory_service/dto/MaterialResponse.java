package inventory_service.dto;

import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.ZonedDateTime;
import java.util.UUID;

@Data
@Builder
public class MaterialResponse {
    private UUID id;
    private String name;
    private String description;
    private String imageUrl;
    private BigDecimal unitPrice;
    private ZonedDateTime createdAt;
}
