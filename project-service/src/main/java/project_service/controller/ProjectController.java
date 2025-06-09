package project_service.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
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
    public ResponseEntity<List<ProjectResponse>> getAllProjects() {
        List<ProjectResponse> projects = projectService.getAllProjects();
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