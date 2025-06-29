package inventory_service.service;

import inventory_service.dto.MaterialRequestCreateDTO;
import inventory_service.dto.MaterialRequestResponseDTO;

import java.util.List;
import java.util.UUID;

public interface MaterialRequestService {
    MaterialRequestResponseDTO createRequest(MaterialRequestCreateDTO request);

    List<MaterialRequestResponseDTO> getPendingRequests();

    MaterialRequestResponseDTO approveRequest(UUID requestId);

    List<MaterialRequestResponseDTO> getRequestsByProject(UUID projectId);
}
