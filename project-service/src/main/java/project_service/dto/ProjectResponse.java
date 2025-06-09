package project_service.dto;

import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.ZonedDateTime;
import java.util.UUID;

@Data
@Builder
public class ProjectResponse {
    private UUID id;
    private String name;
    private String description;
    private BigDecimal budget;
    private LocalDate startDate;
    private LocalDate endDate;
    private BigDecimal percentCompleted;
    private BigDecimal latitude;
    private BigDecimal longitude;
    private ZonedDateTime createdAt;
    private ZonedDateTime updatedAt;
}