#!/usr/bin/env bash
set -euo pipefail

log() { echo "[$(date -u +%H:%M:%S)] [$1] $2"; }

wait_for_services() {
  log "INIT" "Waiting for Redis..."
  until redis-cli -h "$REDIS_HOST" -p "$REDIS_PORT" ping > /dev/null 2>&1; do sleep 1; done
  log "INIT" "Redis ready"
}

probe_http() {
  while true; do
    if curl -sf --max-time 5 "$HTTP_TARGET" -o /dev/null; then
      log "HTTP" "OK -> $HTTP_TARGET"
    else
      log "HTTP" "FAIL -> $HTTP_TARGET"
    fi
    sleep "$PROBE_INTERVAL_SECONDS"
  done
}

probe_redis() {
  while true; do
    KEY="smoke:$(date +%s)"
    if redis-cli -h "$REDIS_HOST" -p "$REDIS_PORT" SET "$KEY" "gauntlet" EX 30 > /dev/null 2>&1 && \
       redis-cli -h "$REDIS_HOST" -p "$REDIS_PORT" GET "$KEY" > /dev/null 2>&1; then
      log "REDIS" "SET/GET OK"
    else
      log "REDIS" "FAIL (is Redis reachable at $REDIS_HOST:$REDIS_PORT?)"
    fi
    sleep "$PROBE_INTERVAL_SECONDS"
  done
}

probe_fileio() {
  while true; do
    F="$IO_DIR/probe-$(date +%s%N)"
    dd if=/dev/urandom of="$F" bs=1K count=512 status=none
    rm -f "$F"
    log "FILE_IO" "Write/read/delete OK"
    sleep "$PROBE_INTERVAL_SECONDS"
  done
}

probe_cpu() {
  while true; do
    result=$(echo "scale=4; $(seq 1 5000 | tr '\n' '+' | sed 's/+$//') " | bc -l 2>/dev/null || echo "0")
    log "CPU" "Arithmetic loop done (sum=$result)"
    sleep "$PROBE_INTERVAL_SECONDS"
  done
}

probe_dns() {
  while true; do
    if nslookup "$REDIS_HOST" > /dev/null 2>&1; then
      log "DNS" "Resolved $REDIS_HOST OK"
    else
      log "DNS" "FAIL resolving $REDIS_HOST"
    fi
    sleep "$PROBE_INTERVAL_SECONDS"
  done
}

mkdir -p "$IO_DIR"
wait_for_services

log "CST" "Starting probes (interval=${PROBE_INTERVAL_SECONDS}s)"
probe_http   &
probe_redis  &
probe_fileio &
probe_cpu    &
probe_dns    &
wait
