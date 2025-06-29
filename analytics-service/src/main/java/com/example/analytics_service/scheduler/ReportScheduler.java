package com.example.analytics_service.scheduler;

import com.example.analytics_service.dto.ReportRequest;
import com.example.analytics_service.service.ReportService;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.util.Map;

@Component
@RequiredArgsConstructor
public class ReportScheduler {

    private final ReportService reportService;

    // Ejecuta el job todos los días a la 1:00 AM
    @Scheduled(cron = "0 0 1 * * ?")
    public void generateDailyCostReport() {
        ReportRequest request = new ReportRequest();
        request.setReportType("COSTOS");
        request.setParameters(Map.of("periodo", "hoy"));
        reportService.generateReport(request);
    }
}
