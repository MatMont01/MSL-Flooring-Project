package com.example.worker_service.repository;

import com.example.worker_service.domain.AttendanceRecord;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface AttendanceRecordRepository extends JpaRepository<AttendanceRecord, UUID> {
    List<AttendanceRecord> findByWorkerId(UUID workerId);

    List<AttendanceRecord> findByProjectId(UUID projectId);

    // --- AÑADE ESTE NUEVO MÉTODO ---
    // Busca un registro de asistencia para un trabajador en un proyecto específico
    // donde la hora de check-out sea nula, y lo ordena por la hora de check-in
    // de forma descendente para obtener el más reciente.
    Optional<AttendanceRecord> findFirstByWorkerIdAndProjectIdAndCheckOutTimeIsNullOrderByCheckInTimeDesc(UUID workerId, UUID projectId);
}