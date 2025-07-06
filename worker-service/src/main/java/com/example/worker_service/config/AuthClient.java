package com.example.worker_service.config;

import com.example.worker_service.dto.UserResponse;
import com.example.worker_service.dto.WorkerRequest;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.*;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

import java.util.Map;

@Component
public class AuthClient {

    @Value("${auth.service.url}")
    private String authServiceUrl;

    private final RestTemplate restTemplate = new RestTemplate();

    public Map<String, Object> getUserInfo(String token) {
        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "Bearer " + token);
        HttpEntity<Void> entity = new HttpEntity<Void>(headers);

        ResponseEntity<Map<String, Object>> response = restTemplate.exchange(
                authServiceUrl + "/api/auth/validate",
                HttpMethod.GET,
                entity,
                new ParameterizedTypeReference<Map<String, Object>>() {
                }
        );
        return response.getBody();
    }

    public UserResponse registerWorkerInAuthService(WorkerRequest req) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        Map<String, Object> body = Map.of(
                "username", req.getEmail(),
                "email", req.getEmail(),
                "password", req.getPassword()
        );

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(body, headers);

        try {
            // Esperamos un UserResponse en lugar de Void
            ResponseEntity<UserResponse> response = restTemplate.postForEntity(
                    authServiceUrl + "/api/auth/register",
                    entity,
                    UserResponse.class
            );
            return response.getBody(); // Devolvemos el cuerpo de la respuesta
        } catch (Exception e) {
            // Si falla, devolvemos null o lanzamos una excepción más específica
            return null;
        }
    }
}