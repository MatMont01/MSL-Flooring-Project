package com.example.analytics_service.dto;

import lombok.Builder;
import lombok.Data;

import java.time.ZonedDateTime;
import java.util.UUID;

@Data
@Builder
public class ReportResponse {
    private UUID id;
    private String reportType;
    private String parameters;     // JSON serializado
    private ZonedDateTime generatedAt;
    private String data;           // JSON serializado con los resultados del reporte
}
