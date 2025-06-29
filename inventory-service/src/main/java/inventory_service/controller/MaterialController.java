package inventory_service.controller;

import inventory_service.dto.MaterialRequest;
import inventory_service.dto.MaterialResponse;
import inventory_service.service.MaterialService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/materials")
@RequiredArgsConstructor
public class MaterialController {

    private final MaterialService materialService;

    @PostMapping
    public ResponseEntity<MaterialResponse> createMaterial(@RequestBody MaterialRequest request) {
        return ResponseEntity.ok(materialService.createMaterial(request));
    }

    @GetMapping
    public ResponseEntity<List<MaterialResponse>> getAllMaterials() {
        return ResponseEntity.ok(materialService.getAllMaterials());
    }

    @GetMapping("/{id}")
    public ResponseEntity<MaterialResponse> getMaterialById(@PathVariable UUID id) {
        return ResponseEntity.ok(materialService.getMaterialById(id));
    }
}
