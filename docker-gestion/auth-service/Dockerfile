# ---- Stage 1: Build ----
FROM maven:3.9.6-eclipse-temurin-17 AS builder

WORKDIR /build

# Cache dependencies - Copia il pom.xml dalla cartella del servizio
COPY auth-service/pom.xml .
RUN mvn dependency:go-offline -q

# Build - Copia i sorgenti dalla cartella del servizio
COPY auth-service/src ./src
RUN mvn clean package -DskipTests -q

# ---- Stage 2: Runtime ----
FROM eclipse-temurin:17-jre-jammy

WORKDIR /app

# Utente non-root per sicurezza
RUN groupadd -r appgroup && useradd -r -g appgroup appuser

# Copia il jar generato nello stage precedente
COPY --from=builder /build/target/auth-service-1.0.0.jar app.jar

RUN chown appuser:appgroup app.jar

USER appuser

EXPOSE 8080

# Health check interno al container
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/auth/health || exit 1

ENTRYPOINT ["java", "-jar", \
  "-Djava.security.egd=file:/dev/./urandom", \
  "-XX:+UseContainerSupport", \
  "-XX:MaxRAMPercentage=75.0", \
  "app.jar"]