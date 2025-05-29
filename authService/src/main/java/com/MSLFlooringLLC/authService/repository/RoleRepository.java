package com.MSLFlooringLLC.authService.repository;

import com.MSLFlooringLLC.authService.domain.Role;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface RoleRepository extends JpaRepository<Role, java.util.UUID> {
    Optional<Role> findByName(String name);
}