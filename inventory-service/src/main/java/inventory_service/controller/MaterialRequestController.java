package inventory_service.controller;

import inventory_service.dto.MaterialRequestCreateDTO;
import inventory_service.dto.MaterialRequestResponseDTO;
import inventory_service.service.MaterialRequestService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/material-requests")
@RequiredArgsConstructor
public class MaterialRequestController {

    private final MaterialRequestService service;

    @PostMapping
    public ResponseEntity<MaterialRequestResponseDTO> createRequest(@RequestBody MaterialRequestCreateDTO request) {
        return ResponseEntity.ok(service.createRequest(request));
    }

    @GetMapping("/pending")
    public ResponseEntity<List<MaterialRequestResponseDTO>> getPendingRequests() {
        return ResponseEntity.ok(service.getPendingRequests());
    }

    @PutMapping("/{requestId}/approve")
    public ResponseEntity<MaterialRequestResponseDTO> approveRequest(@PathVariable UUID requestId) {
        return ResponseEntity.ok(service.approveRequest(requestId));
    }

    @GetMapping("/project/{projectId}")
    public ResponseEntity<List<MaterialRequestResponseDTO>> getRequestsByProject(@PathVariable UUID projectId) {
        return ResponseEntity.ok(service.getRequestsByProject(projectId));
    }
}
