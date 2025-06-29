package inventory_service.service;

import inventory_service.domain.InventoryMovement;
import inventory_service.dto.InventoryMovementRequest;
import inventory_service.dto.InventoryMovementResponse;
import inventory_service.repository.InventoryMovementRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.ZonedDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class InventoryMovementServiceImpl implements InventoryMovementService {

    private final InventoryMovementRepository repo;

    @Override
    public InventoryMovementResponse recordMovement(InventoryMovementRequest req) {
        InventoryMovement movement = InventoryMovement.builder()
                .materialId(req.getMaterialId())
                .projectId(req.getProjectId())
                .quantity(req.getQuantity())
                .movementType(req.getMovementType())
                .movementDate(ZonedDateTime.now())
                .build();
        return toResponse(repo.save(movement));
    }

    @Override
    public List<InventoryMovementResponse> getMovementsByMaterial(UUID materialId) {
        return repo.findByMaterialId(materialId).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<InventoryMovementResponse> getMovementsByProject(UUID projectId) {
        return repo.findByProjectId(projectId).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    private InventoryMovementResponse toResponse(InventoryMovement im) {
        return InventoryMovementResponse.builder()
                .id(im.getId())
                .materialId(im.getMaterialId())
                .projectId(im.getProjectId())
                .quantity(im.getQuantity())
                .movementType(im.getMovementType())
                .movementDate(im.getMovementDate())
                .build();
    }

    @Override
    public int getAvailableStock(UUID materialId) {
        List<InventoryMovement> movements = repo.findByMaterialId(materialId);
        int stock = 0;
        for (InventoryMovement m : movements) {
            if ("IN".equalsIgnoreCase(m.getMovementType())) {
                stock += m.getQuantity();
            } else if ("OUT".equalsIgnoreCase(m.getMovementType())) {
                stock -= m.getQuantity();
            }
        }
        return stock;
    }

}
