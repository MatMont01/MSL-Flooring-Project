package com.example.worker_service.dto;

import lombok.Data;

import java.time.LocalDate;

@Data
public class WorkerRequest {
    private String firstName;
    private String lastName;
    private String email;
    private String phone;
    private LocalDate dateHired;
    private String password;
}