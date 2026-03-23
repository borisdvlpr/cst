# CST (Container Stress Test)

> *Stress the shit out of your friends containers*

CST is a lightweight, Debian-based container designed to continuously generate load and verify connectivity across various subsystems. It runs multiple parallel probes in the background to stress-test your container infrastructure.

Redis runs **inside the container** and is managed by `supervisord`, which acts as PID 1 and keeps all processes alive automatically.

## Probes Included

The container runs the following stress tests continuously:

- **HTTP**: Makes periodic `curl` requests to a target URL.
- **Redis**: Performs `SET`/`GET` operations against the in-container Redis instance.
- **File I/O**: Generates and deletes random files to test disk operations.
- **CPU**: Computes heavy floating-point arithmetic loops using `bc`.
- **DNS**: Continuously resolves target hostnames.

## Configuration

You can customize the stress test behavior by overriding these environment variables at runtime:

| Variable | Default Value | Description |
|----------|---------------|-------------|
| `PROBE_INTERVAL_SECONDS` | `5` | Delay between each probe iteration (in seconds). |
| `HTTP_TARGET` | `http://httpbin.org/get` | URL for the HTTP probe to request. |
| `REDIS_HOST` / `REDIS_PORT` | `localhost` / `6379` | Connection details for the Redis probe. |
| `IO_DIR` | `/tmp/smoketest` | Directory for the File I/O probe tests. |

## Repo Structure

```
k8s-smoke-gauntlet/
├── Dockerfile
├── supervisord.conf
└── entrypoint.sh
```

## Usage

Run the container using Docker, passing any environment variables you want to override:

```bash
docker build -t cst .

docker run -it \
  -e PROBE_INTERVAL_SECONDS="1" \
  -e HTTP_TARGET="https://example.com" \
  cst
```
