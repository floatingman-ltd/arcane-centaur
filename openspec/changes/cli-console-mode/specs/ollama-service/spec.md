## ADDED Requirements

### Requirement: Ollama Docker Compose service
A `docker-compose.yml` SHALL exist at `docker/ollama/docker-compose.yml` defining an
`ollama` service using the official `ollama/ollama` image. The service SHALL follow the
same structural pattern as existing services in `docker/`.

#### Scenario: Service file exists and is valid
- **WHEN** `docker compose -f docker/ollama/docker-compose.yml config` is run
- **THEN** it SHALL exit with code 0 and produce valid compose output

### Requirement: Port bound to loopback only
The ollama service SHALL bind port `11434` to `127.0.0.1` only, consistent with all
other Docker services in this config.

#### Scenario: Port binding is loopback-scoped
- **WHEN** the ollama service is running
- **THEN** port `11434` SHALL be accessible at `127.0.0.1:11434`
- **THEN** it SHALL NOT be accessible on external network interfaces

### Requirement: Model data persisted via named volume
The ollama service SHALL mount a named Docker volume at `/root/.ollama` inside the
container. Models downloaded into the running container SHALL persist across
`docker compose down` and `docker compose up` cycles.

#### Scenario: Models survive container restart
- **WHEN** a model is pulled via `docker compose exec ollama ollama pull <model>`
- **THEN** stopping and restarting the service SHALL not require re-pulling the model

### Requirement: GPU support is opt-in via documented annotation
The compose file SHALL include commented-out GPU resource annotations for NVIDIA. GPU
acceleration SHALL not be active by default. The guide SHALL document how to enable it.

#### Scenario: Default startup uses CPU only
- **WHEN** the service is started without modifying the compose file
- **THEN** it SHALL start successfully using CPU inference only

### Requirement: Service restarts automatically
The ollama service SHALL use `restart: unless-stopped` so it recovers automatically
after a system reboot, consistent with other services in `docker/`.

#### Scenario: Auto-restart on reboot
- **WHEN** Docker daemon starts after a reboot
- **THEN** the ollama service SHALL start automatically if it was running before shutdown
