package inventory_service.repository;

import inventory_service.domain.InventoryMovement;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface InventoryMovementRepository extends JpaRepository<InventoryMovement, UUID> {
    List<InventoryMovement> findByMaterialId(UUID materialId);

    List<InventoryMovement> findByProjectId(UUID projectId);
}
