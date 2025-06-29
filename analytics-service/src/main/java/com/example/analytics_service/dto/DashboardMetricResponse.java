package com.example.analytics_service.dto;

import lombok.Builder;
import lombok.Data;

import java.time.ZonedDateTime;
import java.util.UUID;

@Data
@Builder
public class DashboardMetricResponse {
    private UUID id;
    private String name;
    private Double value;
    private ZonedDateTime capturedAt;
}
