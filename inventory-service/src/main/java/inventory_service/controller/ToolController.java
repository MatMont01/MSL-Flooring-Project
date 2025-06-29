package inventory_service.controller;

import inventory_service.dto.ToolRequest;
import inventory_service.dto.ToolResponse;
import inventory_service.service.ToolService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/tools")
@RequiredArgsConstructor
public class ToolController {

    private final ToolService toolService;

    @PostMapping
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
}
