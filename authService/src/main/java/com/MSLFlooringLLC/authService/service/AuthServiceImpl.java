package com.MSLFlooringLLC.authService.service;

import com.MSLFlooringLLC.authService.domain.RevokedToken;
import com.MSLFlooringLLC.authService.domain.Role;
import com.MSLFlooringLLC.authService.domain.User;
import com.MSLFlooringLLC.authService.dto.JwtResponse;
import com.MSLFlooringLLC.authService.dto.LoginRequest;
import com.MSLFlooringLLC.authService.dto.RegisterRequest;
import com.MSLFlooringLLC.authService.exceptions.AuthException;
import com.MSLFlooringLLC.authService.repository.RevokedTokenRepository;
import com.MSLFlooringLLC.authService.repository.RoleRepository;
import com.MSLFlooringLLC.authService.repository.UserRepository;
import com.MSLFlooringLLC.authService.util.JwtUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import jakarta.transaction.Transactional;

import java.time.ZonedDateTime;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {
    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final RevokedTokenRepository revokedTokenRepository;
    private final JwtUtils jwtUtils;
    private final PasswordEncoder passwordEncoder;

    @Override
    public JwtResponse login(LoginRequest loginRequest) {
        User user = userRepository.findByUsername(loginRequest.getUsername())
                .orElseThrow(() -> new AuthException("Invalid credentials"));
        if (!passwordEncoder.matches(loginRequest.getPassword(), user.getPasswordHash())) {
            throw new AuthException("Invalid credentials");
        }
        String token = jwtUtils.generateToken(user);
        return new JwtResponse(
                token,
                "Bearer",
                user.getUsername(),
                user.getRoles().stream().map(Role::getName).collect(Collectors.toList())
        );
    }

    @Override
    @Transactional
    public User register(RegisterRequest registerRequest) {
        if (userRepository.existsByUsername(registerRequest.getUsername())) {
            throw new AuthException("Username already taken");
        }
        if (userRepository.existsByEmail(registerRequest.getEmail())) {
            throw new AuthException("Email already in use");
        }
        Role defaultRole = roleRepository.findByName("trabajador")
                .orElseThrow(() -> new AuthException("Default role not found"));
        User user = User.builder()
                .username(registerRequest.getUsername())
                .email(registerRequest.getEmail())
                .passwordHash(passwordEncoder.encode(registerRequest.getPassword()))
                .enabled(true)
                .createdAt(ZonedDateTime.now())
                .updatedAt(ZonedDateTime.now())
                .roles(Set.of(defaultRole))
                .build();
        return userRepository.save(user);
    }

    @Override
    public void logout(String token) {
        RevokedToken revoked = RevokedToken.builder()
                .token(token)
                .user(null)
                .revokedAt(ZonedDateTime.now())
                .expiresAt(jwtUtils.getExpirationDateFromToken(token))
                .build();
        revokedTokenRepository.save(revoked);
    }

    @Override
    public boolean validateToken(String token) {
        if (revokedTokenRepository.findByToken(token).isPresent()) {
            return false;
        }
        return jwtUtils.validateToken(token);
    }

    @Override
    public User getUserFromToken(String token) {
        String username = jwtUtils.getUsernameFromToken(token);
        return userRepository.findByUsername(username)
                .orElseThrow(() -> new AuthException("Usuario no encontrado"));
    }

}