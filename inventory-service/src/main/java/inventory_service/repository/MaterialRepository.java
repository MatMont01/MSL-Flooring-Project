package inventory_service.repository;

import inventory_service.domain.Material;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface MaterialRepository extends JpaRepository<Material, UUID> {
    Optional<Material> findByNameIgnoreCase(String name);
}