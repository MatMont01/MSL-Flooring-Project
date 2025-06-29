package com.example.analytics_service.domain;

import jakarta.persistence.*;
import lombok.*;

import java.time.ZonedDateTime;
import java.util.UUID;

@Entity
@Table(name = "reports")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Report {
    @Id
    @GeneratedValue
    private UUID id;

    @Column(nullable = false)
    private String reportType; // Ej: "COSTOS", "RENDIMIENTO", "AVANCE"

    @Column(columnDefinition = "JSONB")
    private String parameters; // JSON serializado de los parámetros de generación

    @Column(name = "generated_at", nullable = false)
    private ZonedDateTime generatedAt;

    @Column(columnDefinition = "JSONB")
    private String data; // JSON serializado del contenido del reporte
}