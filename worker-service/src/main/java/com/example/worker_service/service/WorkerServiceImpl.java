package com.example.worker_service.service;

import com.example.worker_service.domain.AttendanceRecord;
import com.example.worker_service.domain.Worker;
import com.example.worker_service.dto.AttendanceRecordRequest;
import com.example.worker_service.dto.AttendanceRecordResponse;
import com.example.worker_service.dto.WorkerRequest;
import com.example.worker_service.dto.WorkerResponse;
import com.example.worker_service.repository.AttendanceRecordRepository;
import com.example.worker_service.repository.WorkerRepository;
import com.example.worker_service.config.AuthClient;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.ZonedDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class WorkerServiceImpl implements WorkerService {

    private final WorkerRepository workerRepository;
    private final AttendanceRecordRepository attendanceRecordRepository;
    private final AuthClient authClient;

    @Override
    public WorkerResponse registerWorker(WorkerRequest request) {
        boolean created = authClient.registerWorkerInAuthService(request);
        if (!created) {
            throw new RuntimeException("No se pudo crear el usuario en auth-service");
        }

        Worker worker = Worker.builder()
                .firstName(request.getFirstName())
                .lastName(request.getLastName())
                .email(request.getEmail())
                .phone(request.getPhone())
                .dateHired(request.getDateHired())
                .createdAt(ZonedDateTime.now())
                .build();

        Worker saved = workerRepository.save(worker);

        return toResponse(saved);
    }

    @Override
    public List<WorkerResponse> getAllWorkers() {
        return workerRepository.findAll().stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public AttendanceRecordResponse checkIn(AttendanceRecordRequest request) {
        AttendanceRecord record = AttendanceRecord.builder()
                .workerId(request.getWorkerId())
                .projectId(request.getProjectId())
                .checkInTime(ZonedDateTime.now())
                .latitude(request.getLatitude())
                .longitude(request.getLongitude())
                .build();

        AttendanceRecord saved = attendanceRecordRepository.save(record);
        return toAttendanceResponse(saved);
    }

    @Override
    public AttendanceRecordResponse checkOut(UUID attendanceId, AttendanceRecordRequest request) {
        AttendanceRecord record = attendanceRecordRepository.findById(attendanceId)
                .orElseThrow(() -> new RuntimeException("Registro de asistencia no encontrado"));

        record.setCheckOutTime(ZonedDateTime.now());
        record.setLatitude(request.getLatitude());
        record.setLongitude(request.getLongitude());

        AttendanceRecord saved = attendanceRecordRepository.save(record);
        return toAttendanceResponse(saved);
    }

    @Override
    public List<AttendanceRecordResponse> getAttendanceByWorker(UUID workerId) {
        return attendanceRecordRepository.findByWorkerId(workerId).stream()
                .map(this::toAttendanceResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<AttendanceRecordResponse> getAttendanceByProject(UUID projectId) {
        return attendanceRecordRepository.findByProjectId(projectId).stream()
                .map(this::toAttendanceResponse)
                .collect(Collectors.toList());
    }

    private WorkerResponse toResponse(Worker worker) {
        return WorkerResponse.builder()
                .id(worker.getId())
                .firstName(worker.getFirstName())
                .lastName(worker.getLastName())
                .email(worker.getEmail())
                .phone(worker.getPhone())
                .dateHired(worker.getDateHired())
                .createdAt(worker.getCreatedAt())
                .build();
    }

    private AttendanceRecordResponse toAttendanceResponse(AttendanceRecord record) {
        return AttendanceRecordResponse.builder()
                .id(record.getId())
                .workerId(record.getWorkerId())
                .projectId(record.getProjectId())
                .checkInTime(record.getCheckInTime())
                .checkOutTime(record.getCheckOutTime())
                .latitude(record.getLatitude())
                .longitude(record.getLongitude())
                .build();
    }
    @Override
    public Worker getWorkerById(UUID workerId) {
        return workerRepository.findById(workerId)
                .orElseThrow(() -> new RuntimeException("Worker no encontrado con ID: " + workerId));
    }
}