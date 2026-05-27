package com.rapidgateway.gateway.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class RegisterRequest {

    private String name;
    private String ip;
    private int port;
    private int maxPlayers;
    private int pingport;
}
