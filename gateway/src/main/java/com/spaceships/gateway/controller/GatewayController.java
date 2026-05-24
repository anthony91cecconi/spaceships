package com.spaceships.gateway.controller;

import com.spaceships.gateway.model.GameServer;
import com.spaceships.gateway.model.RegisterRequest;
import com.spaceships.gateway.service.ServerRegistryService;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

@RestController
@RequestMapping("/servers")
public class GatewayController {


    private static final Logger log = (Logger) LoggerFactory.getLogger(ServerRegistryService.class);

    private final ServerRegistryService registryService;

    public GatewayController(ServerRegistryService registryService) {
        this.registryService = registryService;
    }

    // -----------------------------------------------------------
    // Il game server si annuncia al gateway
    // POST /servers/register
    // Body: { "name": "Server1", "ip": "192.168.1.10", "port": 7777, "maxPlayers": 100 }
    // -----------------------------------------------------------
    @PostMapping("/register")
    public ResponseEntity<GameServer> register(@RequestBody RegisterRequest request) {
        log.info("Dati ricevuti: name="+request.getName()+" ip="+request.getIp()+" port="+request.getPort()+" pingport="+request.getPingport());
        GameServer server = registryService.registra(request);
        return ResponseEntity.ok(server);
    }

    // -----------------------------------------------------------
    // Il client chiede la lista dei server attivi
    // GET /servers
    // -----------------------------------------------------------
    @GetMapping
    public ResponseEntity<Object> getServers() {
        List<GameServer> attivi = registryService.getServerAttivi();

        if (attivi.isEmpty()) {
            return ResponseEntity.ok(Map.of("message", "Nessun server attivo al momento. Riprova più tardi."));
        }

        return ResponseEntity.ok(attivi);
    }
}
