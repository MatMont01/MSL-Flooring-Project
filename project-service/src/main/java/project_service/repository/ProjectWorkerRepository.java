package project_service.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import project_service.domain.ProjectWorker;

import java.util.List;
import java.util.UUID;

public interface ProjectWorkerRepository extends JpaRepository<ProjectWorker, UUID> {
    List<ProjectWorker> findByProjectId(UUID projectId);

    List<ProjectWorker> findByWorkerId(UUID workerId);

    void deleteByProjectIdAndWorkerId(UUID projectId, UUID workerId);

}