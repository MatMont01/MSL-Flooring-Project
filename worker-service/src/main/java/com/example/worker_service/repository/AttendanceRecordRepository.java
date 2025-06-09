package com.example.worker_service.repository;

import com.example.worker_service.domain.AttendanceRecord;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface AttendanceRecordRepository extends JpaRepository<AttendanceRecord, UUID> {
    List<AttendanceRecord> findByWorkerId(UUID workerId);
    List<AttendanceRecord> findByProjectId(UUID projectId);
}
