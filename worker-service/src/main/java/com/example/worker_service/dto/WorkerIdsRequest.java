package com.example.worker_service.dto;

import lombok.Data;

import java.util.List;
import java.util.UUID;

// Usamos @Data de Lombok para generar getters y setters.
@Data
public class WorkerIdsRequest {
    // La clase tiene un solo campo: la lista de IDs.
    private List<UUID> workerIds;
}