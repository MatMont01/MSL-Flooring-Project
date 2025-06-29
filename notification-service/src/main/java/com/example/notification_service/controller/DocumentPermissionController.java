package com.example.notification_service.controller;

import com.example.notification_service.dto.DocumentPermissionRequest;
import com.example.notification_service.dto.DocumentPermissionResponse;
import com.example.notification_service.service.DocumentPermissionService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/document-permissions")
@RequiredArgsConstructor
public class DocumentPermissionController {

    private final DocumentPermissionService service;

    @PostMapping
    public ResponseEntity<DocumentPermissionResponse> grantPermission(@RequestBody DocumentPermissionRequest request) {
        return ResponseEntity.ok(service.grantPermission(request));
    }

    @GetMapping("/worker/{workerId}")
    public ResponseEntity<List<DocumentPermissionResponse>> getPermissionsByWorker(@PathVariable UUID workerId) {
        return ResponseEntity.ok(service.getPermissionsByWorker(workerId));
    }

    @GetMapping("/document/{documentId}")
    public ResponseEntity<List<DocumentPermissionResponse>> getPermissionsByDocument(@PathVariable UUID documentId) {
        return ResponseEntity.ok(service.getPermissionsByDocument(documentId));
    }

    @GetMapping("/check")
    public ResponseEntity<Boolean> canWorkerViewDocument(
            @RequestParam UUID documentId,
            @RequestParam UUID workerId) {
        return ResponseEntity.ok(service.canWorkerViewDocument(documentId, workerId));
    }

    @DeleteMapping("/document/{documentId}")
    public ResponseEntity<Void> revokeAllByDocument(@PathVariable UUID documentId) {
        service.revokeAllByDocument(documentId);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/worker/{workerId}")
    public ResponseEntity<Void> revokeAllByWorker(@PathVariable UUID workerId) {
        service.revokeAllByWorker(workerId);
        return ResponseEntity.noContent().build();
    }
}
