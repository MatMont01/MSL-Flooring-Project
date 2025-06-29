package com.example.notification_service.service;

import com.example.notification_service.domain.Notification;
import com.example.notification_service.dto.NotificationRequest;
import com.example.notification_service.dto.NotificationResponse;
import com.example.notification_service.repository.NotificationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import java.time.ZonedDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@RequiredArgsConstructor
@Service
public class NotificationServiceImpl implements NotificationService {
    private final NotificationRepository notificationRepository;
    private final SimpMessagingTemplate messagingTemplate;

    @Override
    public NotificationResponse createNotification(NotificationRequest req) {
        Notification notification = Notification.builder()
                .title(req.getTitle())
                .message(req.getMessage())
                .type(req.getType())
                .createdAt(ZonedDateTime.now())
                .targetWorkerId(req.getTargetWorkerId())
                .targetRole(req.getTargetRole())
                .build();
        NotificationResponse response = toResponse(notificationRepository.save(notification));

        // Envía a todos si no hay destinatario específico
        if (req.getTargetWorkerId() != null) {
            messagingTemplate.convertAndSend(
                    "/topic/notifications.worker." + req.getTargetWorkerId(),
                    response
            );
        } else if (req.getTargetRole() != null) {
            messagingTemplate.convertAndSend(
                    "/topic/notifications.role." + req.getTargetRole().toLowerCase(),
                    response
            );
        } else {
            // Notificación global
            messagingTemplate.convertAndSend("/topic/notifications", response);
        }

        return response;
    }


    @Override
    public List<NotificationResponse> getAllNotifications() {
        return notificationRepository.findAll()
                .stream().map(this::toResponse).collect(Collectors.toList());
    }

    @Override
    public List<NotificationResponse> getLatestNotifications(int limit) {
        return notificationRepository.findTop10ByOrderByCreatedAtDesc()
                .stream().limit(limit).map(this::toResponse).collect(Collectors.toList());
    }

    @Override
    public List<NotificationResponse> getNotificationsByType(String type) {
        return notificationRepository.findByType(type)
                .stream().map(this::toResponse).collect(Collectors.toList());
    }

    @Override
    public void deleteNotification(UUID id) {
        notificationRepository.deleteById(id);
    }

    private NotificationResponse toResponse(Notification n) {
        return NotificationResponse.builder()
                .id(n.getId())
                .title(n.getTitle())
                .message(n.getMessage())
                .type(n.getType())
                .createdAt(n.getCreatedAt())
                .build();
    }
}
