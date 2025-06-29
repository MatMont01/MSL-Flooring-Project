package com.example.analytics_service.repository;

import com.example.analytics_service.domain.Report;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface ReportRepository extends JpaRepository<Report, UUID> {
    List<Report> findByReportType(String reportType);

    List<Report> findByGeneratedAtBetween(java.time.ZonedDateTime start, java.time.ZonedDateTime end);

    List<Report> findTop10ByOrderByGeneratedAtDesc();
}
