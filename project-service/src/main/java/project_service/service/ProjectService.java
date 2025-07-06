package project_service.service;

import project_service.dto.ProjectRequest;
import project_service.dto.ProjectResponse;
import project_service.dto.WorkerAssignmentRequest;

import java.util.List;
import java.util.UUID;

public interface ProjectService {
    ProjectResponse createProject(ProjectRequest request);

    List<ProjectResponse> getAllProjects();

    void assignWorkerToProject(WorkerAssignmentRequest request);

    List<UUID> getWorkerIdsByProject(UUID projectId);

    void removeWorkerFromProject(UUID projectId, UUID workerId);

    List<ProjectResponse> getProjectsForWorker(UUID workerId);

    // --- AÑADE ESTE NUEVO MÉTODO ---
    ProjectResponse getProjectById(UUID projectId);

}