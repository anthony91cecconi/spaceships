package com.authservice.service;

import com.authservice.dto.*;
import com.authservice.entity.AuthProvider;
import com.authservice.entity.User;
import com.authservice.repository.UserRepository;
import com.authservice.security.GoogleTokenVerifier;
import com.authservice.security.JwtService;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final GoogleTokenVerifier googleTokenVerifier;

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new IllegalArgumentException("Email già registrata: " + request.getEmail());
        }

        User user = User.builder()
                .username(request.getUsername())
                .email(request.getEmail().toLowerCase())
                .password(passwordEncoder.encode(request.getPassword()))
                .provider(AuthProvider.LOCAL)
                .build();

        user = userRepository.save(user);
        log.info("Nuovo utente registrato: id={}, email={}", user.getId(), user.getEmail());

        return buildAuthResponse(user);
    }

    public AuthResponse login(LoginRequest request) {
        User user = userRepository.findByEmail(request.getEmail().toLowerCase())
                .orElseThrow(() -> new BadCredentialsException("Credenziali non valide"));

        if (user.getProvider() != AuthProvider.LOCAL) {
            throw new BadCredentialsException(
                "Account registrato tramite " + user.getProvider() + ". Usa il login corrispondente."
            );
        }

        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new BadCredentialsException("Credenziali non valide");
        }

        log.info("Login riuscito: id={}, email={}", user.getId(), user.getEmail());
        return buildAuthResponse(user);
    }

    @Transactional
    public AuthResponse googleLogin(GoogleLoginRequest request) {
        if (!googleTokenVerifier.isEnabled()) {
            throw new UnsupportedOperationException("Login Google non configurato sul server");
        }

        GoogleIdToken.Payload payload = googleTokenVerifier.verify(request.getIdToken())
                .orElseThrow(() -> new BadCredentialsException("Google ID token non valido o scaduto"));

        String googleSubject = payload.getSubject();
        String email = payload.getEmail().toLowerCase();
        String name = (String) payload.get("name");
        if (name == null || name.isBlank()) {
            name = email.split("@")[0];
        }

        // Cerca prima per Google subject ID, poi per email
        User user = userRepository.findByProviderIdAndProvider(googleSubject, AuthProvider.GOOGLE)
                .orElseGet(() -> userRepository.findByEmail(email)
                        .map(existing -> {
                            // Utente esistente con stessa email ma provider diverso
                            if (existing.getProvider() != AuthProvider.GOOGLE) {
                                throw new IllegalArgumentException(
                                    "Email già registrata con metodo classico. Usa email e password."
                                );
                            }
                            return existing;
                        })
                        .orElse(null));

        if (user == null) {
            // Primo accesso Google: crea l'utente
            final String finalName = name;
            user = User.builder()
                    .username(finalName)
                    .email(email)
                    .provider(AuthProvider.GOOGLE)
                    .providerId(googleSubject)
                    .build();
            user = userRepository.save(user);
            log.info("Nuovo utente Google registrato: id={}, email={}", user.getId(), email);
        } else {
            log.info("Login Google riuscito: id={}, email={}", user.getId(), email);
        }

        return buildAuthResponse(user);
    }

    public ValidateResponse validate(String token) {
        if (token == null || token.isBlank()) {
            return ValidateResponse.builder()
                    .valid(false)
                    .message("Token mancante")
                    .build();
        }

        if (!jwtService.isTokenValid(token)) {
            return ValidateResponse.builder()
                    .valid(false)
                    .message("Token non valido o scaduto")
                    .build();
        }

        try {
            Long userId = jwtService.extractUserId(token);
            User user = userRepository.findById(userId)
                    .orElse(null);

            if (user == null) {
                return ValidateResponse.builder()
                        .valid(false)
                        .message("Utente non trovato")
                        .build();
            }

            return ValidateResponse.builder()
                    .valid(true)
                    .userId(user.getId())
                    .username(user.getUsername())
                    .email(user.getEmail())
                    .provider(user.getProvider().name())
                    .build();

        } catch (Exception e) {
            log.debug("Errore validazione token: {}", e.getMessage());
            return ValidateResponse.builder()
                    .valid(false)
                    .message("Errore nel parsing del token")
                    .build();
        }
    }

    private AuthResponse buildAuthResponse(User user) {
        String token = jwtService.generateToken(user);
        return AuthResponse.builder()
                .token(token)
                .tokenType("Bearer")
                .expiresIn(jwtService.getExpirationMs())
                .user(AuthResponse.UserInfo.builder()
                        .id(user.getId())
                        .username(user.getUsername())
                        .email(user.getEmail())
                        .provider(user.getProvider().name())
                        .build())
                .build();
    }
}
