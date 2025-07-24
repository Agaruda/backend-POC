# Makefile for Backend POC
# Provides convenient shortcuts for local development and CI

.PHONY: help install run clean docker-build docker-up check format lint security build fix install-tools

# Default target
help:
	@echo "Backend POC - Available Commands"
	@echo "================================="
	@echo ""
	@echo "Development:"
	@echo "  install        Install dependencies"
	@echo "  run            Run FastAPI locally (127.0.0.1:8000)"
	@echo "  install-tools  Install development tools"
	@echo "  format         Format code with Black"
	@echo ""
	@echo "CI Checks:"
	@echo "  check          Run all CI checks (REQUIRED before PR)"
	@echo "  lint           Run linting checks only"
	@echo "  security       Run security checks only"
	@echo "  build          Run build checks only"
	@echo ""
	@echo "Docker:"
	@echo "  docker-build   Build Docker image (python-ci-image:local)"
	@echo "  docker-up      Start/restart Docker Compose (hot-reload)"
	@echo ""
	@echo "Utilities:"
	@echo "  clean          Clean up temporary files"
	@echo "  fix            Auto-fix formatting issues"
	@echo "  help           Show this help message"
	@echo ""

# ----------------- Basic targets -----------------

# 1. Install or update dependencies (automatically creates .venv)
install:                  ## Sync deps from uv.lock → .venv
	uv sync --locked --no-editable --compile-bytecode

# 2. Run locally (using .venv)
run:                      ## Run FastAPI locally (127.0.0.1:8000)
	uv run -- uvicorn app.main:app --host 127.0.0.1 --port 8000 --reload

# 3. Remove virtual environment
clean:                    ## Remove local .venv
	rm -rf .venv
	rm -f .local-ci.log
	find . -type f -name "*.pyc" -delete
	find . -type d -name "__pycache__" -delete
	find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true

# 4. Build Docker image (buildx + local cache; tag=local)
docker-build:             ## Build image: python-ci-image:local
	docker buildx build -t python-ci-image:local --load .

# 5. Start/restart Docker Compose (hot-reload version)
docker-up:                ## docker-compose.dev.yml up --build
	docker compose -f docker-compose.dev.yml up -d --build

# ----------------- CI targets -----------------

# Install development tools
install-tools:
	./scripts/install-tools.sh

# Format code
format:
	./scripts/format.sh

# Run all CI checks (REQUIRED before PR)
check:
	@echo "🚨 IMPORTANT: Running all CI checks before PR submission..."
	./scripts/local-ci.sh

# Run linting checks only
lint:
	./scripts/local-ci.sh --lint-only

# Run security checks only
security:
	./scripts/local-ci.sh --security-only

# Run build checks only
build:
	./scripts/local-ci.sh --build-only

# Auto-fix formatting issues
fix:
	./scripts/local-ci.sh --auto-fix