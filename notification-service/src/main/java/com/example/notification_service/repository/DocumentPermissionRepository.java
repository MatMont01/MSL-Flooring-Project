package com.example.notification_service.repository;

import com.example.notification_service.domain.DocumentPermission;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface DocumentPermissionRepository extends JpaRepository<DocumentPermission, UUID> {
    List<DocumentPermission> findByWorkerId(UUID workerId);

    List<DocumentPermission> findByDocumentId(UUID documentId);

    Optional<DocumentPermission> findByDocumentIdAndWorkerId(UUID documentId, UUID workerId);

    boolean existsByDocumentIdAndWorkerId(UUID documentId, UUID workerId);

    void deleteByDocumentId(UUID documentId);

    void deleteByWorkerId(UUID workerId);
}