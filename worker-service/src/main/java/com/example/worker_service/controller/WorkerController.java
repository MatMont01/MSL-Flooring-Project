package com.example.worker_service.controller;

import com.example.worker_service.domain.Worker;
import com.example.worker_service.dto.AttendanceRecordRequest;
import com.example.worker_service.dto.AttendanceRecordResponse;
import com.example.worker_service.dto.WorkerRequest;
import com.example.worker_service.dto.WorkerResponse;
import com.example.worker_service.service.WorkerService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/workers")
@RequiredArgsConstructor
public class WorkerController {

    private final WorkerService workerService;

    @PostMapping
    @PreAuthorize("hasRole('ADMINISTRADOR')")
    public ResponseEntity<WorkerResponse> registerWorker(@RequestBody WorkerRequest request) {
        WorkerResponse worker = workerService.registerWorker(request);
        return ResponseEntity.ok(worker);
    }

    @GetMapping
    @PreAuthorize("hasRole('ADMINISTRADOR')")
    public ResponseEntity<List<WorkerResponse>> getAllWorkers() {
        return ResponseEntity.ok(workerService.getAllWorkers());
    }


    @PostMapping("/attendance/check-in")
    public ResponseEntity<AttendanceRecordResponse> checkIn(
            @RequestBody AttendanceRecordRequest request,
            Principal principal
    ) {
        String loggedEmail = principal.getName();
        Worker worker = workerService.getWorkerById(request.getWorkerId());
        if (!worker.getEmail().equalsIgnoreCase(loggedEmail)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }
        AttendanceRecordResponse response = workerService.checkIn(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/attendance/check-out/{attendanceId}")
    public ResponseEntity<AttendanceRecordResponse> checkOut(
            @PathVariable UUID attendanceId,
            @RequestBody AttendanceRecordRequest request
    ) {
        AttendanceRecordResponse response = workerService.checkOut(attendanceId, request);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{workerId}/attendance")
    public ResponseEntity<List<AttendanceRecordResponse>> getAttendanceByWorker(@PathVariable UUID workerId) {
        return ResponseEntity.ok(workerService.getAttendanceByWorker(workerId));
    }

    @GetMapping("/project/{projectId}/attendance")
    public ResponseEntity<List<AttendanceRecordResponse>> getAttendanceByProject(@PathVariable UUID projectId) {
        return ResponseEntity.ok(workerService.getAttendanceByProject(projectId));
    }
}