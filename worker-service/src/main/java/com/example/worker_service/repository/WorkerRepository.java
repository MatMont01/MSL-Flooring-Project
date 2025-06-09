package com.example.worker_service.repository;

import com.example.worker_service.domain.Worker;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface WorkerRepository extends JpaRepository<Worker, UUID> {
    Optional<Worker> findByEmail(String email);
}
