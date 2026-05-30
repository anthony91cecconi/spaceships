package com.authservice.controller;

import com.authservice.dto.*;
import com.authservice.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    /**
     * Registrazione classica (username + email + password)
     */
    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(authService.register(request));
    }

    /**
     * Login classico → restituisce JWT
     */
    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        return ResponseEntity.ok(authService.login(request));
    }

    /**
     * Login/Register tramite Google ID Token → restituisce JWT interno
     */
    @PostMapping("/google")
    public ResponseEntity<AuthResponse> googleLogin(@Valid @RequestBody GoogleLoginRequest request) {
        return ResponseEntity.ok(authService.googleLogin(request));
    }

    /**
     * Validazione token — usato dagli altri servizi.
     * Accetta il token come query param o come Authorization header.
     * Restituisce i dati utente se il token è valido.
     */
    @GetMapping("/validate")
    public ResponseEntity<ValidateResponse> validate(
            @RequestParam(required = false) String token,
            @RequestHeader(value = "Authorization", required = false) String authHeader
    ) {
        String resolvedToken = token;
        if (resolvedToken == null && authHeader != null && authHeader.startsWith("Bearer ")) {
            resolvedToken = authHeader.substring(7);
        }

        ValidateResponse response = authService.validate(resolvedToken);
        int status = response.isValid() ? 200 : 401;
        return ResponseEntity.status(status).body(response);
    }

    /**
     * Health check
     */
    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("Auth service operativo");
    }
}
