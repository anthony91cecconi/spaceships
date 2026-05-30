# Auth Service

Servizio di autenticazione Spring Boot con JWT e supporto Google OAuth2.

## Avvio rapido

```bash
# 1. Copia il file env
cp .env.example .env

# 2. Modifica i valori (soprattutto JWT_SECRET e le password DB)
nano .env

# 3. Avvia
docker compose up --build -d
```

Il servizio sarà disponibile su `http://localhost:8080`.

---

## Endpoint

### `POST /auth/register`
Registrazione classica.

**Body:**
```json
{
  "username": "mario",
  "email": "mario@example.com",
  "password": "password123"
}
```

**Response 201:**
```json
{
  "token": "eyJ...",
  "tokenType": "Bearer",
  "expiresIn": 43200000,
  "user": { "id": 1, "username": "mario", "email": "mario@example.com", "provider": "LOCAL" }
}
```

---

### `POST /auth/login`
Login classico.

**Body:**
```json
{
  "email": "mario@example.com",
  "password": "password123"
}
```

**Response 200:** stessa struttura di `/register`

---

### `POST /auth/google`
Login / registrazione tramite Google ID Token (ottenuto lato client con Google Sign-In SDK).

**Body:**
```json
{
  "idToken": "<Google ID Token>"
}
```

**Response 200:** stessa struttura di `/register`

> Richiede `GOOGLE_CLIENT_ID` configurato nel `.env`.

---

### `GET /auth/validate`
Valida un JWT e restituisce i dati utente. Usato dagli altri servizi.

**Opzione A — Query param:**
```
GET /auth/validate?token=eyJ...
```

**Opzione B — Authorization header:**
```
GET /auth/validate
Authorization: Bearer eyJ...
```

**Response 200 (valido):**
```json
{
  "valid": true,
  "userId": 1,
  "username": "mario",
  "email": "mario@example.com",
  "provider": "LOCAL"
}
```

**Response 401 (non valido):**
```json
{
  "valid": false,
  "message": "Token non valido o scaduto"
}
```

---

### `GET /auth/health`
Health check. Risponde `200 OK` quando il servizio è operativo.

---

## Configurazione

| Variabile         | Default                              | Descrizione                      |
|-------------------|--------------------------------------|----------------------------------|
| `DB_HOST`         | `localhost`                          | Host MySQL                       |
| `DB_PORT`         | `3306`                               | Porta MySQL                      |
| `DB_NAME`         | `authdb`                             | Nome database                    |
| `DB_USER`         | `authuser`                           | Utente DB                        |
| `DB_PASSWORD`     | `authpassword`                       | Password DB                      |
| `JWT_SECRET`      | *(default insicuro)*                 | **Cambiare in produzione!**       |
| `GOOGLE_CLIENT_ID`| *(vuoto = Google disabilitato)*      | Client ID da Google Cloud Console|

---

## Tabella `users`

```sql
CREATE TABLE users (
  id          BIGINT AUTO_INCREMENT PRIMARY KEY,
  username    VARCHAR(64)  NOT NULL,
  email       VARCHAR(128) NOT NULL UNIQUE,
  password    VARCHAR(256),          -- NULL per utenti Google
  provider    VARCHAR(16)  NOT NULL DEFAULT 'LOCAL',
  provider_id VARCHAR(128),          -- Google subject ID
  created_at  DATETIME,
  updated_at  DATETIME
);
```

La tabella viene creata automaticamente da Hibernate al primo avvio.

---

## Integrazione con altri servizi

L'altro servizio non ha accesso alla tabella `users`. Per identificare un utente:

```http
GET http://auth-service:8080/auth/validate
Authorization: Bearer <token ricevuto dal client>
```

Se `valid: true`, usa `userId` come chiave esterna nelle tue tabelle.

---

## Note produzione

- Imposta `JWT_SECRET` con una stringa casuale di almeno 32 caratteri
- Usa HTTPS davanti al servizio (nginx / traefik / load balancer)
- `ddl-auto: update` va bene per sviluppo; in produzione valuta `validate` + Flyway/Liquibase
