package com.example.analytics_service.dto;

import lombok.Data;

import java.util.Map;

@Data
public class ReportRequest {
    private String reportType;                // Ej: "COSTOS", "RENDIMIENTO", "AVANCE"
    private Map<String, Object> parameters;   // Parámetros para filtrar o personalizar el reporte
}
