package com.example.analytics_service.service;

import com.example.analytics_service.dto.ReportRequest;
import com.example.analytics_service.dto.ReportResponse;

import java.time.ZonedDateTime;
import java.util.List;
import java.util.UUID;

public interface ReportService {
    ReportResponse generateReport(ReportRequest request);

    ReportResponse getReportById(UUID id);

    List<ReportResponse> getReportsByType(String reportType);

    List<ReportResponse> getReportsByDateRange(ZonedDateTime start, ZonedDateTime end);

    List<ReportResponse> getLatestReports(int limit);
}
