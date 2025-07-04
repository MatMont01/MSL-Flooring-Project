package project_service.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import project_service.domain.Project;
import project_service.domain.ProjectWorker;
import project_service.dto.ProjectRequest;
import project_service.dto.ProjectResponse;
import project_service.dto.WorkerAssignmentRequest;
import project_service.repository.ProjectRepository;
import project_service.repository.ProjectWorkerRepository;

import java.time.ZonedDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ProjectServiceImpl implements ProjectService {

    private final ProjectRepository projectRepository;
    private final ProjectWorkerRepository projectWorkerRepository;

    @Override
    public ProjectResponse createProject(ProjectRequest request) {
        Project project = Project.builder()
                .name(request.getName())
                .description(request.getDescription())
                .budget(request.getBudget())
                .startDate(request.getStartDate())
                .endDate(request.getEndDate())
                .percentCompleted(java.math.BigDecimal.ZERO)
                .latitude(request.getLatitude())
                .longitude(request.getLongitude())
                .createdAt(ZonedDateTime.now())
                .updatedAt(ZonedDateTime.now())
                .build();

        Project saved = projectRepository.save(project);

        return toResponse(saved);
    }

    @Override
    public List<ProjectResponse> getAllProjects() {
        return projectRepository.findAll()
                .stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public void assignWorkerToProject(WorkerAssignmentRequest request) {
        ProjectWorker assignment = ProjectWorker.builder()
                .projectId(request.getProjectId())
                .workerId(request.getWorkerId())
                .assignedAt(ZonedDateTime.now())
                .build();

        projectWorkerRepository.save(assignment);
    }

    private ProjectResponse toResponse(Project project) {
        return ProjectResponse.builder()
                .id(project.getId())
                .name(project.getName())
                .description(project.getDescription())
                .budget(project.getBudget())
                .startDate(project.getStartDate())
                .endDate(project.getEndDate())
                .percentCompleted(project.getPercentCompleted())
                .latitude(project.getLatitude())
                .longitude(project.getLongitude())
                .createdAt(project.getCreatedAt())
                .updatedAt(project.getUpdatedAt())
                .build();
    }

    @Override
    public List<UUID> getWorkerIdsByProject(UUID projectId) {
        return projectWorkerRepository.findByProjectId(projectId).stream()
                .map(ProjectWorker::getWorkerId)
                .collect(Collectors.toList());
    }

    @Override
    public void removeWorkerFromProject(UUID projectId, UUID workerId) {
        projectWorkerRepository.deleteByProjectIdAndWorkerId(projectId, workerId);
    }

}