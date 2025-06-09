package com.example.worker_service.dto;

import lombok.Builder;
import lombok.Data;

import java.time.ZonedDateTime;
import java.util.UUID;

@Data
@Builder
public class AttendanceRecordResponse {
    private UUID id;
    private UUID workerId;
    private UUID projectId;
    private ZonedDateTime checkInTime;
    private ZonedDateTime checkOutTime;
    private Double latitude;
    private Double longitude;
}