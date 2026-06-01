package com.authservice.service;

import com.authservice.entity.RefreshToken;
import com.authservice.entity.User;
import com.authservice.repository.RefreshTokenRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class RefreshTokenService {

    private static final int EXPIRY_DAYS = 30;
    private static final int NEAR_EXPIRY_DAYS = 7;

    private final RefreshTokenRepository refreshTokenRepository;

    @Transactional
    public RefreshToken crea(User user) {
        // Elimina i token precedenti dello stesso utente
        refreshTokenRepository.deleteByUser(user);

        RefreshToken token = RefreshToken.builder()
                .token(UUID.randomUUID().toString())
                .user(user)
                .createdAt(LocalDateTime.now())
                .expiresAt(LocalDateTime.now().plusDays(EXPIRY_DAYS))
                .build();

        return refreshTokenRepository.save(token);
    }

    public Optional<RefreshToken> trova(String token) {
        return refreshTokenRepository.findByToken(token);
    }

    @Transactional
    public RefreshToken rinnova(RefreshToken old) {
        // Sliding expiration — crea un nuovo token con scadenza fresca
        refreshTokenRepository.delete(old);
        return crea(old.getUser());
    }

    @Transactional
    public void invalida(User user) {
        refreshTokenRepository.deleteByUser(user);
    }
}