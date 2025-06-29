package com.example.notification_service.service;

import com.example.notification_service.domain.DocumentPermission;
import com.example.notification_service.dto.DocumentPermissionRequest;
import com.example.notification_service.dto.DocumentPermissionResponse;
import com.example.notification_service.repository.DocumentPermissionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.ZonedDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DocumentPermissionServiceImpl implements DocumentPermissionService {

    private final DocumentPermissionRepository permissionRepository;

    @Override
    public DocumentPermissionResponse grantPermission(DocumentPermissionRequest req) {
        DocumentPermission permission = DocumentPermission.builder()
                .documentId(req.getDocumentId())
                .workerId(req.getWorkerId())
                .canView(req.isCanView())
                .grantedAt(ZonedDateTime.now())
                .build();
        return toResponse(permissionRepository.save(permission));
    }

    @Override
    public List<DocumentPermissionResponse> getPermissionsByWorker(UUID workerId) {
        return permissionRepository.findByWorkerId(workerId)
                .stream().map(this::toResponse).collect(Collectors.toList());
    }

    @Override
    public List<DocumentPermissionResponse> getPermissionsByDocument(UUID documentId) {
        return permissionRepository.findByDocumentId(documentId)
                .stream().map(this::toResponse).collect(Collectors.toList());
    }

    @Override
    public boolean canWorkerViewDocument(UUID documentId, UUID workerId) {
        return permissionRepository.existsByDocumentIdAndWorkerId(documentId, workerId);
    }

    @Override
    public void revokeAllByDocument(UUID documentId) {
        permissionRepository.deleteByDocumentId(documentId);
    }

    @Override
    public void revokeAllByWorker(UUID workerId) {
        permissionRepository.deleteByWorkerId(workerId);
    }

    private DocumentPermissionResponse toResponse(DocumentPermission dp) {
        return DocumentPermissionResponse.builder()
                .id(dp.getId())
                .documentId(dp.getDocumentId())
                .workerId(dp.getWorkerId())
                .canView(dp.isCanView())
                .grantedAt(dp.getGrantedAt())
                .build();
    }
}
