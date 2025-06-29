package com.example.notification_service.service;

import com.example.notification_service.dto.NotificationRequest;
import com.example.notification_service.dto.NotificationResponse;

import java.util.List;
import java.util.UUID;

public interface NotificationService {
    NotificationResponse createNotification(NotificationRequest request);

    List<NotificationResponse> getAllNotifications();

    List<NotificationResponse> getLatestNotifications(int limit);

    List<NotificationResponse> getNotificationsByType(String type);

    void deleteNotification(UUID id);
}
