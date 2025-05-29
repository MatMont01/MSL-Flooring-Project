package com.MSLFlooringLLC.authService.domain;

import jakarta.persistence.*;
import lombok.*;


import java.time.ZonedDateTime;
import java.util.Set;

@Entity
@Table(name = "roles")
@Data
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Role {
    @Id
    @GeneratedValue(generator = "UUID")
    @Column(name = "id", updatable = false, nullable = false)
    @EqualsAndHashCode.Include
    private java.util.UUID id;

    @Column(nullable = false, unique = true, length = 50)
    @EqualsAndHashCode.Include
    private String name;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(name = "created_at", nullable = false)
    private ZonedDateTime createdAt;

    @EqualsAndHashCode.Exclude
    @ToString.Exclude
    @ManyToMany(mappedBy = "roles")
    private Set<User> users;
}