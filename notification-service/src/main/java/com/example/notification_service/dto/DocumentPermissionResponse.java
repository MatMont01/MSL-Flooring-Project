package com.example.notification_service.dto;

import lombok.Builder;
import lombok.Data;

import java.time.ZonedDateTime;
import java.util.UUID;

@Data
@Builder
public class DocumentPermissionResponse {
    private UUID id;
    private UUID documentId;
    private UUID workerId;
    private boolean canView;
    private ZonedDateTime grantedAt;
}
