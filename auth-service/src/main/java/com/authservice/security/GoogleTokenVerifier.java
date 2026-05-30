package com.authservice.security;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import jakarta.annotation.PostConstruct;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.Optional;

@Slf4j
@Service
public class GoogleTokenVerifier {

    @Value("${google.client-id}")
    private String clientId;

    private GoogleIdTokenVerifier verifier;

    @PostConstruct
    public void init() {
        if (clientId == null || clientId.isBlank()) {
            log.warn("GOOGLE_CLIENT_ID non configurato — login Google disabilitato");
            return;
        }
        verifier = new GoogleIdTokenVerifier.Builder(
                new NetHttpTransport(),
                GsonFactory.getDefaultInstance()
        )
                .setAudience(Collections.singletonList(clientId))
                .build();
        log.info("Google Token Verifier inizializzato per client: {}", clientId);
    }

    /**
     * Verifica l'ID token Google e restituisce il payload se valido.
     */
    public Optional<GoogleIdToken.Payload> verify(String idTokenString) {
        if (verifier == null) {
            log.error("Google verifier non inizializzato: GOOGLE_CLIENT_ID mancante");
            return Optional.empty();
        }
        try {
            GoogleIdToken idToken = verifier.verify(idTokenString);
            if (idToken != null) {
                return Optional.of(idToken.getPayload());
            }
        } catch (Exception e) {
            log.debug("Verifica Google token fallita: {}", e.getMessage());
        }
        return Optional.empty();
    }

    public boolean isEnabled() {
        return verifier != null;
    }
}
