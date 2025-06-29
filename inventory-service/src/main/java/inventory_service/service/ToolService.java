package inventory_service.service;

import inventory_service.dto.ToolRequest;
import inventory_service.dto.ToolResponse;

import java.util.List;
import java.util.UUID;

public interface ToolService {
    ToolResponse createTool(ToolRequest request);

    List<ToolResponse> getAllTools();

    ToolResponse getToolById(UUID id);
}
