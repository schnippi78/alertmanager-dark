#!/bin/sh
# PID 1 = diese Shell. Sie faengt Stop-Signale ab und faehrt nginx + Alertmanager
# sauber runter (kein Go-SIGQUIT-Stacktrace beim Stoppen).
set -e

shutdown() {
    [ -n "$AM_PID" ]    && kill -TERM "$AM_PID"    2>/dev/null || true
    [ -n "$NGINX_PID" ] && kill -QUIT "$NGINX_PID" 2>/dev/null || true
    wait "$AM_PID" 2>/dev/null || true
    exit 0
}
trap shutdown TERM INT QUIT

# nginx (Reverse-Proxy + Darkmode-Injection) auf :9093
nginx -g 'daemon off;' &
NGINX_PID=$!

# Alertmanager intern auf :9095; alle CMD-Argumente werden durchgereicht
/bin/alertmanager --web.listen-address=127.0.0.1:9095 "$@" &
AM_PID=$!

# Stirbt Alertmanager, endet der Container (Swarm startet neu).
# Stirbt nur nginx, schlaegt der Healthcheck auf :9093 fehl -> Swarm startet neu.
wait "$AM_PID"
