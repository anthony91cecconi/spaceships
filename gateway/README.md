# Spaceships Gateway

Servizio gateway per il bilanciamento e la discovery dei game server dell'MMO Spaceships.

## Funzionamento

- I **game server** si registrano chiamando `POST /servers/register`
- Il **gateway** controlla ogni 30 secondi che i server registrati rispondano su `/ping`
- I **client** chiamano `GET /servers` e ricevono la lista dei server attivi
- Se un server non risponde per 60 secondi consecutivi viene rimosso automaticamente

## Endpoint

### Registrazione server
```
POST /servers/register
Content-Type: application/json

{
  "name": "Server Alpha",
  "ip": "192.168.1.10",
  "port": 7777,
  "maxPlayers": 100
}
```

### Lista server attivi (chiamata dal client)
```
GET /servers
```
Risposta con server disponibili:
```json
[
  {
    "id": "uuid",
    "name": "Server Alpha",
    "ip": "192.168.1.10",
    "port": 7777,
    "currentPlayers": 0,
    "maxPlayers": 100
  }
]
```
Risposta senza server attivi:
```json
{ "message": "Nessun server attivo al momento. Riprova più tardi." }
```

## Build e Deploy con Podman

### 1. Build del JAR
```bash
./mvnw clean package -DskipTests
```

### 2. Build dell'immagine
```bash
podman build -t spaceships-gateway .
```

### 3. Avvio del container
```bash
podman run -d \
  --name spaceships-gateway \
  -p 8080:8080 \
  spaceships-gateway
```

### 4. Verifica
```bash
curl http://localhost:8080/servers
```

## Versione
`0.0.1` — Registry in memoria, heartbeat HTTP ogni 30s, timeout 60s.
