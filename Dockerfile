# alertmanager-dark — a dark theme for the Prometheus Alertmanager web UI.
#
# An nginx reverse proxy sits in front of Alertmanager and injects a dark
# stylesheet via sub_filter. The Alertmanager binary and its embedded UI are
# NOT recompiled or modified, so this works across UI versions and adds no
# runtime overhead beyond a lightweight proxy.
#
# The alertmanager/amtool binaries are copied unmodified from the official
# upstream image prom/alertmanager (Apache 2.0). See NOTICE for attribution.
# Override the version at build time: --build-arg AM_VERSION=v0.27.0
ARG AM_VERSION=v0.33.1

FROM prom/alertmanager:${AM_VERSION} AS am

FROM nginx:alpine

LABEL org.opencontainers.image.title="alertmanager-dark" \
      org.opencontainers.image.description="Dark theme for the Prometheus Alertmanager web UI, injected via an nginx proxy. Alertmanager itself is unmodified." \
      org.opencontainers.image.source="https://github.com/schnippi78/alertmanager-dark" \
      org.opencontainers.image.licenses="MIT"

# Alertmanager-Binaries uebernehmen (statisch gelinkt -> laeuft auf alpine)
COPY --from=am /bin/alertmanager /bin/alertmanager
COPY --from=am /bin/amtool       /bin/amtool
# Default-Config wie im Upstream-Image
COPY --from=am /etc/alertmanager/alertmanager.yml /etc/alertmanager/alertmanager.yml

# Darkmode-Assets + Proxy-Konfiguration
COPY am-dark.css   /usr/share/am-dark/am-dark.css
COPY nginx.conf    /etc/nginx/nginx.conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh /bin/alertmanager /bin/amtool

# Storage-Verzeichnis fuer Alertmanager, schreibbar fuer nobody
RUN mkdir -p /alertmanager && chown -R nobody:nobody /alertmanager /usr/share/am-dark

EXPOSE 9093
USER nobody

ENTRYPOINT ["/entrypoint.sh"]
# Wie Upstream: greift, wenn der Stack kein eigenes command setzt
CMD ["--config.file=/etc/alertmanager/alertmanager.yml", "--storage.path=/alertmanager"]
