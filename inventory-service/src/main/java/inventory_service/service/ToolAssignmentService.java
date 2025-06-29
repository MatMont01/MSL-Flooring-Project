package inventory_service.service;

import inventory_service.dto.ToolAssignmentRequest;
import inventory_service.dto.ToolAssignmentResponse;

import java.util.List;
import java.util.UUID;

public interface ToolAssignmentService {
    ToolAssignmentResponse assignTool(ToolAssignmentRequest request);

    List<ToolAssignmentResponse> getAssignmentsByWorker(UUID workerId);

    List<ToolAssignmentResponse> getAssignmentsByProject(UUID projectId);

    List<ToolAssignmentResponse> getAssignmentsByTool(UUID toolId);
}
