package project_service.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import project_service.dto.ProjectRequest;
import project_service.dto.ProjectResponse;
import project_service.dto.WorkerAssignmentRequest;
import project_service.service.ProjectService;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/projects")
@RequiredArgsConstructor
public class ProjectController {

    private final ProjectService projectService;

    @PostMapping
    public ResponseEntity<ProjectResponse> createProject(@RequestBody ProjectRequest request) {
        ProjectResponse response = projectService.createProject(request);
        return ResponseEntity.ok(response);
    }

    @GetMapping
    @PreAuthorize("hasRole('ADMINISTRADOR')")
    public ResponseEntity<List<ProjectResponse>> getAllProjects() {
        List<ProjectResponse> projects = projectService.getAllProjects();
        return ResponseEntity.ok(projects);
    }

    @GetMapping("/my-assigned")
    @PreAuthorize("hasRole('TRABAJADOR')")
    public ResponseEntity<List<ProjectResponse>> getMyAssignedProjects(Authentication authentication) {
        // 1. Obtenemos el userId que guardamos en el JwtAuthFilter
        UUID workerId = (UUID) authentication.getDetails();

        // 2. Llamamos al servicio con el ID del trabajador autenticado
        List<ProjectResponse> projects = projectService.getProjectsForWorker(workerId);

        return ResponseEntity.ok(projects);
    }

    @PostMapping("/assign-worker")
    public ResponseEntity<Void> assignWorkerToProject(@RequestBody WorkerAssignmentRequest request) {
        projectService.assignWorkerToProject(request);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/{projectId}/workers")
    public ResponseEntity<List<UUID>> getWorkersByProject(@PathVariable UUID projectId) {
        List<UUID> workers = projectService.getWorkerIdsByProject(projectId);
        return ResponseEntity.ok(workers);
    }

    @DeleteMapping("/{projectId}/workers/{workerId}")
    public ResponseEntity<Void> removeWorker(
            @PathVariable UUID projectId,
            @PathVariable UUID workerId
    ) {
        projectService.removeWorkerFromProject(projectId, workerId);
        return ResponseEntity.noContent().build();
    }
}