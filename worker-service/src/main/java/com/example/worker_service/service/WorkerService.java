package com.example.worker_service.service;

import com.example.worker_service.domain.Worker;
import com.example.worker_service.dto.AttendanceRecordRequest;
import com.example.worker_service.dto.AttendanceRecordResponse;
import com.example.worker_service.dto.WorkerRequest;
import com.example.worker_service.dto.WorkerResponse;

import java.util.List;
import java.util.UUID;

public interface WorkerService {
    WorkerResponse registerWorker(WorkerRequest request);

    List<WorkerResponse> getAllWorkers();

    Worker getWorkerById(UUID workerId);

    AttendanceRecordResponse checkIn(AttendanceRecordRequest request);

    AttendanceRecordResponse checkOut(UUID attendanceId, AttendanceRecordRequest request);

    List<AttendanceRecordResponse> getAttendanceByWorker(UUID workerId);

    List<AttendanceRecordResponse> getAttendanceByProject(UUID projectId);

    List<WorkerResponse> getWorkersByIds(List<UUID> workerIds);
}