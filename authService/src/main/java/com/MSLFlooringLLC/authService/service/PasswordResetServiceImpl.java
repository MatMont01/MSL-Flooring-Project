package com.MSLFlooringLLC.authService.service;

import com.MSLFlooringLLC.authService.domain.PasswordResetToken;
import com.MSLFlooringLLC.authService.domain.User;
import com.MSLFlooringLLC.authService.exceptions.AuthException;
import com.MSLFlooringLLC.authService.repository.PasswordResetTokenRepository;
import com.MSLFlooringLLC.authService.repository.UserRepository;
import lombok.RequiredArgsConstructor;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class PasswordResetServiceImpl implements PasswordResetService {

    private final UserRepository userRepository;
    private final PasswordResetTokenRepository tokenRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public void requestPasswordReset(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new AuthException("Usuario no encontrado con ese correo"));

        PasswordResetToken token = PasswordResetToken.builder()
                .user(user)
                .expiresAt(Instant.now().plus(15, ChronoUnit.MINUTES))
                .build();

        tokenRepository.save(token);
        // TODO: enviar por correo electrónico token.getToken()
        System.out.println("Token para restablecer contraseña: " + token.getToken());
    }

    @Override
    public void resetPassword(String tokenStr, String newPassword) {
        UUID tokenUUID = UUID.fromString(tokenStr);
        PasswordResetToken token = tokenRepository.findByTokenAndUsedFalse(tokenUUID)
                .orElseThrow(() -> new AuthException("Token inválido o expirado"));

        if (token.getExpiresAt().isBefore(Instant.now())) {
            throw new AuthException("El token ha expirado");
        }

        User user = token.getUser();
        user.setPasswordHash(passwordEncoder.encode(newPassword));
        userRepository.save(user);

        token.setUsed(true);
        tokenRepository.save(token);
    }
}