package com.rapidgateway.gateway.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.rapidgateway.gateway.model.GameServer;
import com.rapidgateway.gateway.model.RegisterRequest;
import com.rapidgateway.gateway.service.ServerRegistryService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.File;
import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/servers")
public class GatewayController {

    private static final Logger log = LoggerFactory.getLogger(GatewayController.class);
    private final ObjectMapper objectMapper = new ObjectMapper();
    private final ServerRegistryService registryService;

    // Prende il percorso dalla variabile d'ambiente 'VERSION_JSON_PATH'.
    // Se non passata, usa il valore di default dopo i due punti.
    @Value("${version.json.path:/config/version.json}")
    private String jsonPath;

    public GatewayController(ServerRegistryService registryService) {
        this.registryService = registryService;
    }

    @PostMapping("/register")
    public ResponseEntity<GameServer> register(@RequestBody RegisterRequest request) {
        log.info("Dati ricevuti: name={} ip={} port={} pingport={}", request.getName(), request.getIp(), request.getPort(), request.getPingport());
        GameServer server = registryService.registra(request);
        return ResponseEntity.ok(server);
    }

    @GetMapping
    public ResponseEntity<Object> getServers() {
        List<GameServer> attivi = registryService.getServerAttivi();
        if (attivi.isEmpty()) {
            return ResponseEntity.ok(Map.of("message", "Nessun server attivo al momento. Riprova più tardi."));
        }
        return ResponseEntity.ok(attivi);
    }

    @GetMapping("/version")
    public ResponseEntity<?> getVersion() {
        try {
            File jsonFile = new File(jsonPath);
            
            if (!jsonFile.exists()) {
                log.error("Il file delle versioni non esiste al percorso: {}", jsonPath);
                return ResponseEntity.status(404).body(Map.of("error", "File version.json non trovato nel container."));
            }

            @SuppressWarnings("unchecked")
            Map<String, String> versionData = objectMapper.readValue(jsonFile, Map.class);
            return ResponseEntity.ok(versionData);
            
        } catch (IOException e) {
            log.error("Errore durante la lettura del file JSON della versione: ", e);
            return ResponseEntity.status(500).body(Map.of(
                "error", "Impossibile leggere il file di configurazione delle versioni.",
                "details", e.getMessage()
            ));
        }
    }

    @GetMapping("/download/{filename}")
    public ResponseEntity<Resource> download(@PathVariable String filename) throws IOException {
        Path path = Paths.get("/relises/" + filename);
        Resource resource = new UrlResource(path.toUri());
        if (!resource.exists()) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok()
            .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=" + filename)
            .header(HttpHeaders.CONTENT_TYPE, "application/vnd.android.package-archive")
            .contentLength(path.toFile().length())
            .body(resource);
    }

    @PatchMapping("/{id}/players")
    public ResponseEntity<?> aggiornaGiocatori(@PathVariable String id, @RequestBody Map<String, Integer> body) {
        Integer count = body.get("currentPlayers");
        if (count == null) return ResponseEntity.badRequest().build();
        GameServer server = registryService.aggiornaGiocatori(id, count);
        if (server == null) return ResponseEntity.notFound().build();
        return ResponseEntity.ok(server);
    }
}