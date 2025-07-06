package com.example.worker_service.controller;

import com.example.worker_service.domain.Worker;
import com.example.worker_service.dto.*;
import com.example.worker_service.service.WorkerService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
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

    // --- ENDPOINT MODIFICADO ---
    @PostMapping("/batch")
    @PreAuthorize("isAuthenticated()")
    // Cambiamos el @RequestBody para que espere nuestro nuevo DTO
    public ResponseEntity<List<WorkerResponse>> getWorkersByIds(@RequestBody WorkerIdsRequest request) {
        // Accedemos a la lista a través del getter del DTO
        List<WorkerResponse> workers = workerService.getWorkersByIds(request.getWorkerIds());
        return ResponseEntity.ok(workers);
    }

    @GetMapping("/attendance/status")
    @PreAuthorize("hasRole('TRABAJADOR')")
    public ResponseEntity<AttendanceRecordResponse> getAttendanceStatus(
            @RequestParam UUID projectId,
            Authentication authentication) {

        // Obtenemos el ID del trabajador autenticado
        UUID workerId = (UUID) authentication.getDetails();

        // Buscamos el registro activo y lo devolvemos
        return workerService.getActiveAttendanceRecord(workerId, projectId)
                .map(ResponseEntity::ok) // Si se encuentra, devuelve 200 OK con el registro
                .orElseGet(() -> ResponseEntity.notFound().build()); // Si no, devuelve 404 Not Found
    }
}