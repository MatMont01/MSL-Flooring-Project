package com.example.worker_service.dto;

import lombok.Data;

@Data
public class WorkerRegisterRequest {
    private String username;
    private String email;
    private String password;
}