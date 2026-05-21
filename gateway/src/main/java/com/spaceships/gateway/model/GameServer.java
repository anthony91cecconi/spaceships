package com.spaceships.gateway.model;

import java.time.Instant;

public class GameServer {

    private String id;
    private String name;
    private String ip;
    private int port;
    private int currentPlayers;
    private int maxPlayers;
    private Instant registeredAt;
    private Instant lastHeartbeat;

    public GameServer() {}

    public GameServer(String id, String name, String ip, int port, int maxPlayers) {
        this.id = id;
        this.name = name;
        this.ip = ip;
        this.port = port;
        this.currentPlayers = 0;
        this.maxPlayers = maxPlayers;
        this.registeredAt = Instant.now();
        this.lastHeartbeat = Instant.now();
    }

    // Getters e Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getIp() { return ip; }
    public void setIp(String ip) { this.ip = ip; }

    public int getPort() { return port; }
    public void setPort(int port) { this.port = port; }

    public int getCurrentPlayers() { return currentPlayers; }
    public void setCurrentPlayers(int currentPlayers) { this.currentPlayers = currentPlayers; }

    public int getMaxPlayers() { return maxPlayers; }
    public void setMaxPlayers(int maxPlayers) { this.maxPlayers = maxPlayers; }

    public Instant getRegisteredAt() { return registeredAt; }
    public void setRegisteredAt(Instant registeredAt) { this.registeredAt = registeredAt; }

    public Instant getLastHeartbeat() { return lastHeartbeat; }
    public void setLastHeartbeat(Instant lastHeartbeat) { this.lastHeartbeat = lastHeartbeat; }

    public void aggiornaHeartbeat() {
        this.lastHeartbeat = Instant.now();
    }
}
