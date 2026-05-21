FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

COPY target/gateway-0.0.1.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
