package com.example.analytics_service.controller;

import com.example.analytics_service.dto.DashboardMetricRequest;
import com.example.analytics_service.dto.DashboardMetricResponse;
import com.example.analytics_service.service.DashboardMetricService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/dashboard-metrics")
@RequiredArgsConstructor
public class DashboardMetricController {

    private final DashboardMetricService dashboardMetricService;

    // Solo ADMINISTRADOR puede crear una métrica
    @PreAuthorize("hasRole('ADMINISTRADOR')")
    @PostMapping
    public ResponseEntity<DashboardMetricResponse> saveMetric(@RequestBody DashboardMetricRequest request) {
        return ResponseEntity.ok(dashboardMetricService.saveMetric(request));
    }

    // Los siguientes endpoints pueden ser usados por cualquier autenticado
    @GetMapping("/latest")
    public ResponseEntity<List<DashboardMetricResponse>> getLatestMetrics(@RequestParam(defaultValue = "10") int limit) {
        return ResponseEntity.ok(dashboardMetricService.getLatestMetrics(limit));
    }

    @GetMapping("/name/{name}")
    public ResponseEntity<List<DashboardMetricResponse>> getMetricsByName(@PathVariable String name) {
        return ResponseEntity.ok(dashboardMetricService.getMetricsByName(name));
    }
}
