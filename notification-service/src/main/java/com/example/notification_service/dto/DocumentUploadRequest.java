package com.example.notification_service.dto;

import lombok.Data;
import org.springframework.web.multipart.MultipartFile;

import java.util.UUID;

@Data
public class DocumentUploadRequest {
    private String filename;
    private MultipartFile file;
    private UUID uploadedBy;      // id usuario (opcional si lo tomas del JWT)
    private UUID projectId;       // opcional
}
