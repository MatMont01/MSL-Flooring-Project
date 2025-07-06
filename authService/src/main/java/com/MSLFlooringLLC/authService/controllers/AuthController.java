package com.MSLFlooringLLC.authService.controllers;

import com.MSLFlooringLLC.authService.domain.Role;
import com.MSLFlooringLLC.authService.domain.User;
import com.MSLFlooringLLC.authService.dto.JwtResponse;
import com.MSLFlooringLLC.authService.dto.LoginRequest;
import com.MSLFlooringLLC.authService.dto.RegisterRequest;
import com.MSLFlooringLLC.authService.dto.UserResponse;
import com.MSLFlooringLLC.authService.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/login")
    public ResponseEntity<JwtResponse> login(@Valid @RequestBody LoginRequest request) {
        JwtResponse jwt = authService.login(request);
        return ResponseEntity.ok(jwt);
    }

    @PostMapping("/register")
    public ResponseEntity<UserResponse> register(@Valid @RequestBody RegisterRequest request) {
        User registeredUser = authService.register(request);
        // Devolvemos el usuario creado con un código de estado 201
        return new ResponseEntity<>(UserResponse.fromEntity(registeredUser), HttpStatus.CREATED);
    }

    @PostMapping("/logout")
    public ResponseEntity<Void> logout(@RequestHeader("Authorization") String authHeader) {
        String token = authHeader.startsWith("Bearer ") ? authHeader.substring(7) : authHeader;
        authService.logout(token);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/validate")
    public ResponseEntity<?> validateAndExtract(@RequestHeader("Authorization") String tokenHeader) {
        String token = tokenHeader.startsWith("Bearer ") ? tokenHeader.substring(7) : tokenHeader;

        if (!authService.validateToken(token)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        User user = authService.getUserFromToken(token);
        Map<String, Object> response = new HashMap<>();
        response.put("username", user.getUsername());
        response.put("roles", user.getRoles().stream().map(Role::getName).toList());
        response.put("userId", user.getId().toString());
        return ResponseEntity.ok(response);
    }


}