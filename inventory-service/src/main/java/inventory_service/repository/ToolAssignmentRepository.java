package inventory_service.repository;

import inventory_service.domain.ToolAssignment;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface ToolAssignmentRepository extends JpaRepository<ToolAssignment, UUID> {
    List<ToolAssignment> findByWorkerId(UUID workerId);

    List<ToolAssignment> findByProjectId(UUID projectId);

    List<ToolAssignment> findByToolId(UUID toolId);
}
