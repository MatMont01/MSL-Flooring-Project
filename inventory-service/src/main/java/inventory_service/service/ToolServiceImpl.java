package inventory_service.service;

import inventory_service.domain.Tool;
import inventory_service.dto.ToolRequest;
import inventory_service.dto.ToolResponse;
import inventory_service.repository.ToolRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
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

    // 🔧 NUEVO: Actualizar herramienta
    @Override
    @PreAuthorize("hasRole('ADMINISTRADOR')")
    public ToolResponse updateTool(UUID id, ToolRequest request) {
        Tool existingTool = repo.findById(id)
                .orElseThrow(() -> new RuntimeException("Herramienta no encontrada"));

        // Actualizar los campos
        existingTool.setName(request.getName());
        existingTool.setDescription(request.getDescription());
        // createdAt se mantiene igual

        return toResponse(repo.save(existingTool));
    }

    // 🔧 NUEVO: Eliminar herramienta
    @Override
    @PreAuthorize("hasRole('ADMINISTRADOR')")
    public void deleteTool(UUID id) {
        if (!repo.existsById(id)) {
            throw new RuntimeException("Herramienta no encontrada");
        }
        repo.deleteById(id);
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