# ---- Stage 1: Build ----
FROM eclipse-temurin:21-jdk-alpine AS build

# Installa Maven
RUN apk add --no-cache maven

WORKDIR /build

# Copia prima solo il pom.xml per sfruttare la cache di Docker
# (le dipendenze non vengono riscaricate se il pom non cambia)
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copia il sorgente e builda
COPY src src
RUN mvn clean package -DskipTests -B

# ---- Stage 2: Runtime ----
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Copia solo il JAR prodotto dallo stage di build
COPY --from=build /build/target/gateway-0.0.1.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
