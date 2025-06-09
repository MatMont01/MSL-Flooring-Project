package project_service.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import project_service.domain.Project;

import java.util.UUID;

public interface ProjectRepository extends JpaRepository<Project, UUID> {

}