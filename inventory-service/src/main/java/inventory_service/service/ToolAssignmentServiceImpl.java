package inventory_service.service;

import inventory_service.domain.ToolAssignment;
import inventory_service.dto.ToolAssignmentRequest;
import inventory_service.dto.ToolAssignmentResponse;
import inventory_service.repository.ToolAssignmentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.ZonedDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ToolAssignmentServiceImpl implements ToolAssignmentService {

    private final ToolAssignmentRepository repo;

    @Override
    public ToolAssignmentResponse assignTool(ToolAssignmentRequest req) {
        ToolAssignment ta = ToolAssignment.builder()
                .toolId(req.getToolId())
                .workerId(req.getWorkerId())
                .projectId(req.getProjectId())
                .assignedAt(ZonedDateTime.now())
                .dueDate(req.getDueDate())
                .build();
        return toResponse(repo.save(ta));
    }

    @Override
    public List<ToolAssignmentResponse> getAssignmentsByWorker(UUID workerId) {
        return repo.findByWorkerId(workerId).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<ToolAssignmentResponse> getAssignmentsByProject(UUID projectId) {
        return repo.findByProjectId(projectId).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<ToolAssignmentResponse> getAssignmentsByTool(UUID toolId) {
        return repo.findByToolId(toolId).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    private ToolAssignmentResponse toResponse(ToolAssignment ta) {
        return ToolAssignmentResponse.builder()
                .id(ta.getId())
                .toolId(ta.getToolId())
                .workerId(ta.getWorkerId())
                .projectId(ta.getProjectId())
                .assignedAt(ta.getAssignedAt())
                .dueDate(ta.getDueDate())
                .returnedAt(ta.getReturnedAt())
                .build();
    }
}
