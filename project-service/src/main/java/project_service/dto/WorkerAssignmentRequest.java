package project_service.dto;

import lombok.Data;

import java.util.UUID;

@Data
public class WorkerAssignmentRequest {
    private UUID workerId;
    private UUID projectId;
}