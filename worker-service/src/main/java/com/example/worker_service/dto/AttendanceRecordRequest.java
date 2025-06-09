package com.example.worker_service.dto;

import lombok.Data;

import java.util.UUID;

@Data
public class AttendanceRecordRequest {
    private UUID workerId;
    private UUID projectId;
    private Double latitude;
    private Double longitude;
}