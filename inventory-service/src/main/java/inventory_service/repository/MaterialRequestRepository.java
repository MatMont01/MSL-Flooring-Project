package inventory_service.repository;

import inventory_service.domain.MaterialRequest;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface MaterialRequestRepository extends JpaRepository<MaterialRequest, UUID> {
    List<MaterialRequest> findByStatus(String status);

    List<MaterialRequest> findByProjectId(UUID projectId);
}
