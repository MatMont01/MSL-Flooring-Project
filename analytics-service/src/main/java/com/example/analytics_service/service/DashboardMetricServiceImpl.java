package com.example.analytics_service.service;

import com.example.analytics_service.domain.DashboardMetric;
import com.example.analytics_service.dto.DashboardMetricRequest;
import com.example.analytics_service.dto.DashboardMetricResponse;
import com.example.analytics_service.repository.DashboardMetricRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.ZonedDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DashboardMetricServiceImpl implements DashboardMetricService {

    private final DashboardMetricRepository metricRepository;

    @Override
    public DashboardMetricResponse saveMetric(DashboardMetricRequest request) {
         DashboardMetric metric = DashboardMetric.builder()
                .name(request.getName())
                .value(request.getValue())
                .capturedAt(ZonedDateTime.now())
                .build();

        return toResponse(metricRepository.save(metric));
    }

    @Override
    public List<DashboardMetricResponse> getLatestMetrics(int limit) {
        return metricRepository.findTop10ByOrderByCapturedAtDesc()
                .stream().limit(limit).map(this::toResponse).collect(Collectors.toList());
    }

    @Override
    public List<DashboardMetricResponse> getMetricsByName(String name) {
        return metricRepository.findByName(name)
                .stream().map(this::toResponse).collect(Collectors.toList());
    }

    private DashboardMetricResponse toResponse(DashboardMetric m) {
        return DashboardMetricResponse.builder()
                .id(m.getId())
                .name(m.getName())
                .value(m.getValue())
                .capturedAt(m.getCapturedAt())
                .build();
    }
}
