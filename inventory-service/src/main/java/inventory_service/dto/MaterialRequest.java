package inventory_service.dto;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class MaterialRequest {
    private String name;
    private String description;
    private String imageUrl;
    private BigDecimal unitPrice;
}
