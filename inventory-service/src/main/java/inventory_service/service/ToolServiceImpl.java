package inventory_service.service;

import inventory_service.domain.Tool;
import inventory_service.dto.ToolRequest;
import inventory_service.dto.ToolResponse;
import inventory_service.repository.ToolRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.ZonedDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ToolServiceImpl implements ToolService {

    private final ToolRepository repo;

    @Override
    public ToolResponse createTool(ToolRequest request) {
        Tool tool = Tool.builder()
                .name(request.getName())
                .description(request.getDescription())
                .createdAt(ZonedDateTime.now())
                .build();
        return toResponse(repo.save(tool));
    }

    @Override
    public List<ToolResponse> getAllTools() {
        return repo.findAll().stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public ToolResponse getToolById(UUID id) {
        return repo.findById(id)
                .map(this::toResponse)
                .orElseThrow(() -> new RuntimeException("Herramienta no encontrada"));
    }

    private ToolResponse toResponse(Tool t) {
        return ToolResponse.builder()
                .id(t.getId())
                .name(t.getName())
                .description(t.getDescription())
                .createdAt(t.getCreatedAt())
                .build();
    }
}
