package com.example.notification_service.domain;

import jakarta.persistence.*;
import lombok.*;

import java.time.ZonedDateTime;
import java.util.UUID;

@Entity
@Table(name = "documents")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Document {
    @Id
    @GeneratedValue
    private UUID id;

    @Column(nullable = false, length = 255)
    private String filename;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String fileUrl;

    @Column(nullable = false)
    private UUID uploadedBy; // user_id del auth-service

    @Column
    private UUID projectId; // opcional

    @Column(name = "uploaded_at", nullable = false)
    private ZonedDateTime uploadedAt;
}
