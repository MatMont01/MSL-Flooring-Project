package com.example.notification_service.controller;

import com.example.notification_service.dto.NotificationResponse;
import com.example.notification_service.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class NotificationSocketController {

    private final SimpMessagingTemplate messagingTemplate;
    private final NotificationService notificationService;

    // Recibir notificación desde un cliente (o puedes llamarlo desde tu app directamente)
    @MessageMapping("/notify")
    public void sendNotification(NotificationResponse notification) {
        messagingTemplate.convertAndSend("/topic/notifications", notification);
    }

    // Si quieres enviar una notificación cuando se cree en la base de datos:
    public void broadcastNotification(NotificationResponse notification) {
        messagingTemplate.convertAndSend("/topic/notifications", notification);
    }
}
