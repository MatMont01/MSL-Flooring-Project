package com.MSLFlooringLLC.authService.repository;

import com.MSLFlooringLLC.authService.domain.RevokedToken;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface RevokedTokenRepository extends JpaRepository<RevokedToken, java.util.UUID> {
    Optional<RevokedToken> findByToken(String token);
}
