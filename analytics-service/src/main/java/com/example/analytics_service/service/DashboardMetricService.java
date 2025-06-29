package com.example.analytics_service.service;

import com.example.analytics_service.dto.DashboardMetricRequest;
import com.example.analytics_service.dto.DashboardMetricResponse;

import java.util.List;
import java.util.UUID;

public interface DashboardMetricService {
    DashboardMetricResponse saveMetric(DashboardMetricRequest request);

    List<DashboardMetricResponse> getLatestMetrics(int limit);

    List<DashboardMetricResponse> getMetricsByName(String name);
}
