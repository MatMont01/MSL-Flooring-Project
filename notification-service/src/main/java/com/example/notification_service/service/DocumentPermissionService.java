package com.example.notification_service.service;

import com.example.notification_service.dto.DocumentPermissionRequest;
import com.example.notification_service.dto.DocumentPermissionResponse;

import java.util.List;
import java.util.UUID;

public interface DocumentPermissionService {
    DocumentPermissionResponse grantPermission(DocumentPermissionRequest request);

    List<DocumentPermissionResponse> getPermissionsByWorker(UUID workerId);

    List<DocumentPermissionResponse> getPermissionsByDocument(UUID documentId);

    boolean canWorkerViewDocument(UUID documentId, UUID workerId);

    void revokeAllByDocument(UUID documentId);

    void revokeAllByWorker(UUID workerId);
}
