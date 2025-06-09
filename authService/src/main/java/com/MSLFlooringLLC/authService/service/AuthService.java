package com.MSLFlooringLLC.authService.service;


import com.MSLFlooringLLC.authService.domain.User;
import com.MSLFlooringLLC.authService.dto.JwtResponse;
import com.MSLFlooringLLC.authService.dto.LoginRequest;
import com.MSLFlooringLLC.authService.dto.RegisterRequest;

public interface AuthService {
    JwtResponse login(LoginRequest loginRequest);

    User register(RegisterRequest registerRequest);

    void logout(String token);

    boolean validateToken(String token);

    User getUserFromToken(String token);

}