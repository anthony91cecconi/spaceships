FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    libgles2 \
    libfontconfig1 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY relises/server/rapid-server-0.0.5.x86_64 .
COPY relises/server/rapid-server-0.0.5.pck .

RUN chmod +x rapid-server-0.0.5.x86_64

EXPOSE 7777
EXPOSE 7778

ENTRYPOINT ["./rapid-server-0.0.5.x86_64", "--headless"]