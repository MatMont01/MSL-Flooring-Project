package com.example.analytics_service.repository;

import com.example.analytics_service.domain.DashboardMetric;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface DashboardMetricRepository extends JpaRepository<DashboardMetric, UUID> {
    List<DashboardMetric> findByName(String name);

    List<DashboardMetric> findTop10ByOrderByCapturedAtDesc();
}
