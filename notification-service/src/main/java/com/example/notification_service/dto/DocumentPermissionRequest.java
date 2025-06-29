package com.example.notification_service.dto;

import lombok.Data;

import java.util.UUID;

@Data
public class DocumentPermissionRequest {
    private UUID documentId;
    private UUID workerId;
    private boolean canView;
}
