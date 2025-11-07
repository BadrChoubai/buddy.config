# hello-api

## Running the application locally

### 1. Locally using `go` commands 

```bash
go run ./cmd/api/main.go
```

Or, build and run the binary

```bash
mkdir -p ./bin
go build -o ./bin/api .
./bin/api
```

### 2. Building and running a Docker container

```bash
docker build -t hello-api:local .
docker run --rm -d -p '8080:8080' hello-api:local 
```

Verify it's running with: `curl localhost:8080/healthz`

## Using Docker compose

### Build the application

1. `make docker` - builds our container image
2. `make docker-push` - pushes our docker image to a registry (default: `localhost:5000`)

### Run the application with Docker Compose

To start the API, Prometheus, and Grafana together:

```bash
docker compose up
```

Access the services:

- **Hello API:** [http://localhost:8080](http://localhost:8080)
- **Prometheus:** [http://localhost:9090](http://localhost:9090)
- **Grafana:** [http://localhost:3000](http://localhost:3000)
  - Use default credentials: `admin` / `admin`

You can stop the stack with:

```bash
docker compose down
```

### Running Makefile tasks

To view all available tasks, run `make help`

- `make` (same as `make all`) - run tasks to package application for deployment
- `make build` - build app locally using `go build`
- `make clean` - clean build artifacts
- `make docs` - generate API documentation using `swag`
- `make deps` - tidy and get dependencies 
- `make image` - build container image for app using `docker`
- `make image-push` - push container image to registry defined in `Makefile` or in `.env` 
- `make lint` - run linters using `golangci-lint`
- `make test` - run unit tests locally
- `make version` - prints application version

