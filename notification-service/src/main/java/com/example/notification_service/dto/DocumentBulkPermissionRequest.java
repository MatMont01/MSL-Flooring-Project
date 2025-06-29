package com.example.notification_service.dto;

import lombok.Data;

import java.util.List;
import java.util.UUID;

@Data
public class DocumentBulkPermissionRequest {
    private UUID documentId;
    private List<UUID> workerIds;
}
