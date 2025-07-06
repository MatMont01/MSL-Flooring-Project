package inventory_service.controller;

import inventory_service.dto.ToolRequest;
import inventory_service.dto.ToolResponse;
import inventory_service.service.ToolService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/tools")
@RequiredArgsConstructor
public class ToolController {

    private final ToolService toolService;

    @PostMapping
    @PreAuthorize("hasRole('ADMINISTRADOR')")
    public ResponseEntity<ToolResponse> createTool(@RequestBody ToolRequest request) {
        return ResponseEntity.ok(toolService.createTool(request));
    }

    @GetMapping
    public ResponseEntity<List<ToolResponse>> getAllTools() {
        return ResponseEntity.ok(toolService.getAllTools());
    }

    @GetMapping("/{id}")
    public ResponseEntity<ToolResponse> getToolById(@PathVariable UUID id) {
        return ResponseEntity.ok(toolService.getToolById(id));
    }

    // 🔧 NUEVO: Actualizar herramienta
    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMINISTRADOR')")
    public ResponseEntity<ToolResponse> updateTool(
            @PathVariable UUID id,
            @RequestBody ToolRequest request) {
        return ResponseEntity.ok(toolService.updateTool(id, request));
    }

    // 🔧 NUEVO: Eliminar herramienta
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMINISTRADOR')")
    public ResponseEntity<Void> deleteTool(@PathVariable UUID id) {
        toolService.deleteTool(id);
        return ResponseEntity.noContent().build();
    }
}