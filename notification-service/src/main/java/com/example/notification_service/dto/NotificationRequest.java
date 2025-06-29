package com.example.notification_service.dto;

import lombok.Data;

import java.util.UUID;

@Data
public class NotificationRequest {
    private String title;
    private String message;
    private String type; // Ej: ALERT, INFO
    private UUID targetWorkerId;
    private String targetRole;

}