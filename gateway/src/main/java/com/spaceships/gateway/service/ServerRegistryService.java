package com.spaceships.gateway.service;

import com.spaceships.gateway.model.GameServer;
import com.spaceships.gateway.model.RegisterRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.InetAddress;
import java.net.URL;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class ServerRegistryService {

    private static final Logger log = LoggerFactory.getLogger(ServerRegistryService.class);

    // Secondi senza heartbeat prima di considerare il server morto
    private static final int TIMEOUT_SECONDI = 60;

    // Ogni quanti secondi il gateway controlla i server registrati
    private static final int CHECK_INTERVAL_MS = 30_000;

    private final Map<String, GameServer> servers = new ConcurrentHashMap<>();

    // -------------------------------------------------------
    // Registrazione
    // -------------------------------------------------------

    public GameServer registra(RegisterRequest request) {
        String id = UUID.randomUUID().toString();
        GameServer server = new GameServer(id, request.getName(), request.getIp(), request.getPort(), request.getMaxPlayers(),request.getPingport());
        servers.put(id, server);
        log.info("Server registrato: {} ({}:{}) - id: {}", server.getName(), server.getIp(), server.getPort(), id);
        return server;
    }

    // -------------------------------------------------------
    // Lista server attivi
    // -------------------------------------------------------

    public List<GameServer> getServerAttivi() {
        return new ArrayList<>(servers.values());
    }

    // -------------------------------------------------------
    // Controllo periodico - il gateway bussa a ogni server
    // -------------------------------------------------------

    @Scheduled(fixedDelay = CHECK_INTERVAL_MS)
    public void controllaServerAttivi() {
        if (servers.isEmpty()) {
            log.info("Nessun server registrato, nulla da controllare.");
            return;
        }

        log.info("Controllo periodico: {} server registrati.", servers.size());
        Instant adesso = Instant.now();

        servers.forEach((id, server) -> {
            boolean risponde = pingServer(server);

            if (risponde) {
                server.aggiornaHeartbeat();
                log.info("  ✓ {} ({}:{}) - online", server.getName(), server.getIp(), server.getPort());
            } else {
                long secondiSilenzio = ChronoUnit.SECONDS.between(server.getLastHeartbeat(), adesso);
                log.warn("  ✗ {} ({}:{}) - non risponde da {}s", server.getName(), server.getIp(), server.getPort(), secondiSilenzio);

                if (secondiSilenzio >= TIMEOUT_SECONDI) {
                    servers.remove(id);
                    log.warn("  → Server rimosso per timeout: {}", server.getName());
                }
            }
        });
    }

    // -------------------------------------------------------
    // Ping HTTP verso il game server (endpoint /ping)
    // -------------------------------------------------------

    private boolean pingServer(GameServer server) {
        try {
            String ipDaPingare = server.getIp();
            
            // Se il server è sulla stessa macchina, usa localhost
            String myIp = InetAddress.getLocalHost().getHostAddress();
            if (server.getIp().equals(myIp) || server.getIp().equals(getPublicIp())) {
                ipDaPingare = "127.0.0.1";
            }
            
            String urlStr = "http://" + ipDaPingare + ":" + server.getPingport() + "/ping";
            log.info("sto pingando questo:\n " + urlStr);
            HttpURLConnection conn = (HttpURLConnection) new URL(urlStr).openConnection();
            conn.setConnectTimeout(5000);
            conn.setReadTimeout(5000);
            conn.setRequestMethod("GET");
            int responseCode = conn.getResponseCode();
            conn.disconnect();
            return responseCode == 200;
        } catch (IOException e) {
            return false;
        }
    }

    private String getPublicIp() {
        try {
            HttpURLConnection conn = (HttpURLConnection) new URL("https://api.ipify.org").openConnection();
            conn.setConnectTimeout(3000);
            conn.setReadTimeout(3000);
            BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream()));
            String ip = reader.readLine().trim();
            reader.close();
            return ip;
        } catch (IOException e) {
            return "";
        }
    }
}
