package com.rapidgateway.gateway.model;

import java.time.Instant;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class GameServer {

    private String id;
    private String name;
    private String ip;
    private int port;
    private int pingport;
    private int currentPlayers;
    private int maxPlayers;
    private Instant registeredAt;
    private Instant lastHeartbeat;

    public GameServer(String id, String name, String ip, int port, int maxPlayers,int pingport) {
        this.id = id;
        this.name = name;
        this.ip = ip;
        this.port = port;
        this.currentPlayers = 0;
        this.maxPlayers = maxPlayers;
        this.registeredAt = Instant.now();
        this.lastHeartbeat = Instant.now();
        this.pingport = pingport;
    }

    public void aggiornaHeartbeat() {
        this.lastHeartbeat = Instant.now();
    }
}
