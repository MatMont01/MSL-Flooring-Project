package com.example.worker_service.domain;

import jakarta.persistence.*;
import lombok.*;

import java.time.ZonedDateTime;
import java.util.UUID;

@Entity
@Table(name = "attendance_records")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AttendanceRecord {

    @Id
    @GeneratedValue
    private UUID id;

    @Column(name = "worker_id", nullable = false)
    private UUID workerId;

    @Column(name = "project_id", nullable = false)
    private UUID projectId;

    @Column(name = "check_in_time")
    private ZonedDateTime checkInTime;

    @Column(name = "check_out_time")
    private ZonedDateTime checkOutTime;

    @Column
    private Double latitude;

    @Column
    private Double longitude;
}
