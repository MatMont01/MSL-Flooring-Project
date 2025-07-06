// authService/src/main/java/com/MSLFlooringLLC/authService/dto/UserResponse.java
package com.MSLFlooringLLC.authService.dto;

import com.MSLFlooringLLC.authService.domain.User;
import lombok.Builder;
import lombok.Data;
import java.util.UUID;

@Data
@Builder
public class UserResponse {
    private UUID id;
    private String username;
    private String email;

    public static UserResponse fromEntity(User user) {
        return UserResponse.builder()
                .id(user.getId())
                .username(user.getUsername())
                .email(user.getEmail())
                .build();
    }
}