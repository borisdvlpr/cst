# CST (Container Stress Test)

> *Stress the shit out of your friends containers*

CST is a lightweight, Debian-based container designed to continuously generate load and verify connectivity across various subsystems. It runs multiple parallel probes in the background to stress-test your container infrastructure.

## Probes Included

The container runs the following stress tests continuously:

- **HTTP**: Makes periodic `curl` requests to a target URL.
- **Redis**: Performs `SET`/`GET` operations against the in-container Redis instance.
- **File I/O**: Generates and deletes random files to test disk operations.
- **CPU**: Computes heavy floating-point arithmetic loops using `bc`.
- **DNS**: Continuously resolves target hostnames.

Redis runs **inside the container** and is managed by `supervisord`, a process manager to run multiple services side-by-side within a single container. Supervisor acts as the container's main init process, simultaneously launching a local Redis server and the custom bash probes. This ensures that all testing components run reliably in parallel, with their logs aggregated and automatic restarts handled if any process unexpectedly crashes.

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
cst/
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
