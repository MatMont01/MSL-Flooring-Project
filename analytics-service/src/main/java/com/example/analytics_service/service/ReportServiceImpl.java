package com.example.analytics_service.service;

import com.example.analytics_service.domain.Report;
import com.example.analytics_service.dto.ReportRequest;
import com.example.analytics_service.dto.ReportResponse;
import com.example.analytics_service.repository.ReportRepository;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import java.time.ZonedDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ReportServiceImpl implements ReportService {

    private final ReportRepository reportRepository;
    private final WebClient.Builder webClientBuilder;

    @Override
    public ReportResponse generateReport(ReportRequest request) {
        String data;
        if ("COSTOS".equalsIgnoreCase(request.getReportType())) {
            // Llama al project-service para traer costos reales
            data = webClientBuilder.build()
                    .get()
                    .uri("http://localhost:8082/api/projects/costs")
                    .retrieve()
                    .bodyToMono(String.class)
                    .block();
        } else if ("RENDIMIENTO".equalsIgnoreCase(request.getReportType())) {
            // Llama a worker-service para KPIs de trabajadores
            data = webClientBuilder.build()
                    .get()
                    .uri("http://localhost:8084/api/workers/kpis")
                    .retrieve()
                    .bodyToMono(String.class)
                    .block();
        } else {
            data = "{\"detalle\": \"Tipo de reporte no implementado\"}";
        }

        Report report = Report.builder()
                .reportType(request.getReportType())
                .parameters("{}") // Serializa los parámetros si es necesario
                .generatedAt(ZonedDateTime.now())
                .data(data)
                .build();

        return toResponse(reportRepository.save(report));
    }

    @Override
    public ReportResponse getReportById(UUID id) {
        return reportRepository.findById(id)
                .map(this::toResponse)
                .orElseThrow(() -> new RuntimeException("Reporte no encontrado"));
    }

    @Override
    public List<ReportResponse> getReportsByType(String reportType) {
        return reportRepository.findByReportType(reportType)
                .stream().map(this::toResponse).collect(Collectors.toList());
    }

    @Override
    public List<ReportResponse> getReportsByDateRange(ZonedDateTime start, ZonedDateTime end) {
        return reportRepository.findByGeneratedAtBetween(start, end)
                .stream().map(this::toResponse).collect(Collectors.toList());
    }

    @Override
    public List<ReportResponse> getLatestReports(int limit) {
        return reportRepository.findTop10ByOrderByGeneratedAtDesc()
                .stream().limit(limit).map(this::toResponse).collect(Collectors.toList());
    }

    private ReportResponse toResponse(Report r) {
        return ReportResponse.builder()
                .id(r.getId())
                .reportType(r.getReportType())
                .parameters(r.getParameters())
                .generatedAt(r.getGeneratedAt())
                .data(r.getData())
                .build();
    }


}
