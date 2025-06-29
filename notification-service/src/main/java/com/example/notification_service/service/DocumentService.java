package com.example.notification_service.service;

import com.example.notification_service.dto.DocumentResponse;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.UUID;

public interface DocumentService {
    DocumentResponse uploadDocument(String filename, MultipartFile file, UUID uploadedBy, UUID projectId);

    List<DocumentResponse> getAllDocuments();

    List<DocumentResponse> getDocumentsByProject(UUID projectId);

    DocumentResponse getDocumentById(UUID id);

    void deleteDocument(UUID id);
}
