package com.example.notification_service.dto;

import lombok.Builder;
import lombok.Data;

import java.time.ZonedDateTime;
import java.util.UUID;

@Data
@Builder
public class DocumentResponse {
    private UUID id;
    private String filename;
    private String fileUrl;
    private UUID uploadedBy;
    private UUID projectId;
    private ZonedDateTime uploadedAt;
}
