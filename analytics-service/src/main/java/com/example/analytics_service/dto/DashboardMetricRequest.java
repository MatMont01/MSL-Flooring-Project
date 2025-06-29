package com.example.analytics_service.dto;

import lombok.Data;

@Data
public class DashboardMetricRequest {
    private String name;   // Ej: "proyectos_activos"
    private Double value;
}
