package com.example.notification_service.repository;

import com.example.notification_service.domain.Document;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface DocumentRepository extends JpaRepository<Document, UUID> {
    List<Document> findByProjectId(UUID projectId);

    List<Document> findByUploadedBy(UUID userId);

    Optional<Document> findByFileUrl(String fileUrl);

    List<Document> findByFilenameContainingIgnoreCase(String filename);
}