package inventory_service.controller;

import inventory_service.dto.InventoryMovementRequest;
import inventory_service.dto.InventoryMovementResponse;
import inventory_service.service.InventoryMovementService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/inventory-movements")
@RequiredArgsConstructor
public class InventoryMovementController {

    private final InventoryMovementService inventoryService;

    @PostMapping
    public ResponseEntity<InventoryMovementResponse> recordMovement(@RequestBody InventoryMovementRequest request) {
        return ResponseEntity.ok(inventoryService.recordMovement(request));
    }

    @GetMapping("/material/{materialId}")
    public ResponseEntity<List<InventoryMovementResponse>> getMovementsByMaterial(@PathVariable UUID materialId) {
        return ResponseEntity.ok(inventoryService.getMovementsByMaterial(materialId));
    }

    @GetMapping("/project/{projectId}")
    public ResponseEntity<List<InventoryMovementResponse>> getMovementsByProject(@PathVariable UUID projectId) {
        return ResponseEntity.ok(inventoryService.getMovementsByProject(projectId));
    }

    @GetMapping("/material/{materialId}/available-stock")
    public ResponseEntity<Integer> getAvailableStock(@PathVariable UUID materialId) {
        int stock = inventoryService.getAvailableStock(materialId);
        return ResponseEntity.ok(stock);
    }

}
