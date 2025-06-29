package com.example.notification_service.repository;

import com.example.notification_service.domain.Notification;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface NotificationRepository extends JpaRepository<Notification, UUID> {
    List<Notification> findByType(String type);

    List<Notification> findByTitleContainingIgnoreCase(String title);

    List<Notification> findTop10ByOrderByCreatedAtDesc();
}