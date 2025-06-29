package inventory_service.controller;

import inventory_service.dto.ToolAssignmentRequest;
import inventory_service.dto.ToolAssignmentResponse;
import inventory_service.service.ToolAssignmentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/tool-assignments")
@RequiredArgsConstructor
public class ToolAssignmentController {

    private final ToolAssignmentService assignmentService;

    @PostMapping
    public ResponseEntity<ToolAssignmentResponse> assignTool(@RequestBody ToolAssignmentRequest request) {
        return ResponseEntity.ok(assignmentService.assignTool(request));
    }

    @GetMapping("/worker/{workerId}")
    public ResponseEntity<List<ToolAssignmentResponse>> getAssignmentsByWorker(@PathVariable UUID workerId) {
        return ResponseEntity.ok(assignmentService.getAssignmentsByWorker(workerId));
    }

    @GetMapping("/project/{projectId}")
    public ResponseEntity<List<ToolAssignmentResponse>> getAssignmentsByProject(@PathVariable UUID projectId) {
        return ResponseEntity.ok(assignmentService.getAssignmentsByProject(projectId));
    }

    @GetMapping("/tool/{toolId}")
    public ResponseEntity<List<ToolAssignmentResponse>> getAssignmentsByTool(@PathVariable UUID toolId) {
        return ResponseEntity.ok(assignmentService.getAssignmentsByTool(toolId));
    }
}
