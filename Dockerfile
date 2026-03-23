FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    redis-server \
    redis-tools \
    dnsutils \
    bc \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

ENV HTTP_TARGET="http://httpbin.org/get" \
    REDIS_HOST="127.0.0.1" \
    REDIS_PORT="6379" \
    PROBE_INTERVAL_SECONDS="5" \
    IO_DIR="/tmp/smoketest"

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entrypoint.sh    /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
