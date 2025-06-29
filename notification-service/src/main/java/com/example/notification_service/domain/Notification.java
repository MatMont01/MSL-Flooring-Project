package com.example.notification_service.domain;

import jakarta.persistence.*;
import lombok.*;

import java.time.ZonedDateTime;
import java.util.UUID;

@Entity
@Table(name = "notifications")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Notification {
    @Id
    @GeneratedValue
    private UUID id;

    @Column
    private UUID targetWorkerId;

    @Column
    private String targetRole;

    @Column(length = 150)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String message;

    @Column(length = 50)
    private String type; // ej: 'ALERT', 'INFO'

    @Column(name = "created_at", nullable = false)
    private ZonedDateTime createdAt;
}
