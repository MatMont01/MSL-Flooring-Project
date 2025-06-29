package com.example.notification_service.domain;

import jakarta.persistence.*;
import lombok.*;

import java.time.ZonedDateTime;
import java.util.UUID;

@Entity
@Table(name = "document_permissions")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DocumentPermission {
    @Id
    @GeneratedValue
    private UUID id;

    @Column(nullable = false)
    private UUID documentId;

    @Column(nullable = false)
    private UUID workerId;

    @Column(nullable = false)
    private boolean canView = true;

    @Column(name = "granted_at", nullable = false)
    private ZonedDateTime grantedAt;
}
