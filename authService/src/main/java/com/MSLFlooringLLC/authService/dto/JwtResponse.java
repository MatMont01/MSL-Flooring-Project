// authService/src/main/java/com/MSLFlooringLLC/authService/dto/JwtResponse.java

package com.MSLFlooringLLC.authService.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

import java.util.List;

@Data
@AllArgsConstructor  // Esto genera automáticamente el constructor con todos los campos
public class JwtResponse {
    private String token;
    private String tokenType = "Bearer";
    private String userId;      // 👈 Este campo ya existe
    private String username;
    private List<String> roles;
}