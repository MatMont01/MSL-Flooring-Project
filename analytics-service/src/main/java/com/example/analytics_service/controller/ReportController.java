package com.example.analytics_service.controller;

import com.example.analytics_service.dto.ReportRequest;
import com.example.analytics_service.dto.ReportResponse;
import com.example.analytics_service.service.ReportService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.ZonedDateTime;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/reports")
@RequiredArgsConstructor
public class ReportController {

    private final ReportService reportService;

    // Solo ADMINISTRADOR puede generar un reporte
    @PreAuthorize("hasRole('ADMINISTRADOR')")
    @PostMapping("/generate")
    public ResponseEntity<ReportResponse> generateReport(@RequestBody ReportRequest request) {
        return ResponseEntity.ok(reportService.generateReport(request));
    }

    // Los siguientes endpoints están disponibles para cualquier usuario autenticado
    @GetMapping("/{id}")
    public ResponseEntity<ReportResponse> getReportById(@PathVariable UUID id) {
        return ResponseEntity.ok(reportService.getReportById(id));
    }

    @GetMapping("/type/{reportType}")
    public ResponseEntity<List<ReportResponse>> getReportsByType(@PathVariable String reportType) {
        return ResponseEntity.ok(reportService.getReportsByType(reportType));
    }

    @GetMapping("/date-range")
    public ResponseEntity<List<ReportResponse>> getReportsByDateRange(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) ZonedDateTime start,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) ZonedDateTime end
    ) {
        return ResponseEntity.ok(reportService.getReportsByDateRange(start, end));
    }

    @GetMapping("/latest")
    public ResponseEntity<List<ReportResponse>> getLatestReports(@RequestParam(defaultValue = "10") int limit) {
        return ResponseEntity.ok(reportService.getLatestReports(limit));
    }
}
