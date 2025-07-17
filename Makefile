# ----------------- Basic targets -----------------
.PHONY: install run clean docker-build docker-up

# 1. Install or update dependencies (automatically creates .venv)
install:                  ## Sync deps from uv.lock → .venv
	uv sync --locked --no-editable --compile-bytecode

# 2. Run locally (using .venv)
run:                      ## Run FastAPI locally (127.0.0.1:8000)
	uv run -- uvicorn app.main:app --host 127.0.0.1 --port 8000 --reload

# 3. Remove virtual environment
clean:                    ## Remove local .venv
	rm -rf .venv

# 4. Build Docker image (buildx + local cache; tag=local)
docker-build:             ## Build image: python-ci-image:local
	docker buildx build -t python-ci-image:local --load .

# 5. Start/restart Docker Compose (hot-reload version)
docker-up:                ## docker-compose.dev.yml up --build
	docker compose -f docker-compose.dev.yml up -d --build