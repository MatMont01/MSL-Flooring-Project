package com.example.worker_service.dto;

import lombok.Data;
import java.util.UUID;

// DTO para mapear la respuesta del auth-service
@Data
public class UserResponse {
    private UUID id;
    private String username;
    private String email;
}