package inventory_service.repository;

import inventory_service.domain.Tool;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;
import java.util.Optional;

public interface ToolRepository extends JpaRepository<Tool, UUID> {
    Optional<Tool> findByNameIgnoreCase(String name);
}
