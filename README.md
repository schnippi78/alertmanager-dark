# alertmanager-dark

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Docker Image](https://img.shields.io/badge/Docker%20Hub-schnippi78%2Falertmanager--dark-2496ED?logo=docker&logoColor=white)](https://hub.docker.com/r/schnippi78/alertmanager-dark)
[![Based on Alertmanager](https://img.shields.io/badge/based%20on-Prometheus%20Alertmanager-E6522C?logo=prometheus&logoColor=white)](https://github.com/prometheus/alertmanager)

A **dark theme for the [Prometheus Alertmanager](https://github.com/prometheus/alertmanager) web UI** — as a drop-in Docker image.

> **This is an independent, community-made theme. It is not affiliated with,
> endorsed by, or sponsored by the Prometheus project.** All credit for
> Alertmanager itself goes to [The Prometheus Authors](https://github.com/prometheus/alertmanager/graphs/contributors).

## How it works

Alertmanager's web UI is compiled into the binary, so there is no CSS file to
swap out. Instead of forking and rebuilding Alertmanager, this image puts a tiny
**nginx reverse proxy** in front of it that injects one dark stylesheet into the
HTML (`sub_filter` adds a `<link>` before `</head>`).

That means:

- **Alertmanager runs completely unmodified** — same binary, same behaviour, same version you choose.
- **Version-independent** — no rebuild when you bump Alertmanager; just change one build arg.
- **No lock-in** — stop using it and you are back to stock Alertmanager instantly.

```
browser ──▶ nginx :9093 ──▶ alertmanager :9095 (unmodified)
                │
                └─ injects /am-dark.css into the page
```

## Quick start

It is a drop-in replacement for `prom/alertmanager` — same flags, same port `9093`:

```bash
docker run -d \
  -p 9093:9093 \
  -v $(pwd)/alertmanager.yml:/etc/alertmanager/alertmanager.yml:ro \
  schnippi78/alertmanager-dark:latest
```

Open <http://localhost:9093> and enjoy the dark UI. See
[`docker-compose.example.yml`](docker-compose.example.yml) for a Compose setup.

## Choosing the Alertmanager version

The image bundles the upstream binary; pick the version at build time:

```bash
docker build --build-arg AM_VERSION=v0.27.0 -t alertmanager-dark:v0.27.0 .
```

The stylesheet targets the Bootstrap-based Alertmanager web UI. If a future
Alertmanager ships a redesigned UI, the theme may need small tweaks —
PRs welcome.

## What is and isn't changed

| | |
| --- | --- |
| Alertmanager binary / config / API | **untouched** — stock upstream |
| Web UI markup & behaviour | **untouched** — only a stylesheet is added on top |
| Added by this project | `am-dark.css`, an nginx proxy, a small entrypoint |

## Credits & license

- **Prometheus Alertmanager** — © The Prometheus Authors, licensed under
  Apache 2.0. This image redistributes its unmodified binaries; see [NOTICE](NOTICE).
- The theme and glue code in this repo are original work by **schnippi78**,
  licensed under the [MIT License](LICENSE).

If this saved your eyes at 2 a.m. during an incident, that's the whole point. 🌙
