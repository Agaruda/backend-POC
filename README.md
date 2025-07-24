# Agaruda Backend API test

This is a backend API service developed using the FastAPI framework, serving as the backend prototype for the Agaruda project.

## Features

- High-performance API framework based on FastAPI
- Auto-generated API documentation (Swagger UI)
- Hot reload development mode
- Health check endpoint
- Python 3.11+ support

## Quick Start

### Prerequisites

- Python 3.11 or higher
- uv package manager
- Git

### Complete Setup Guide

For new users, follow these steps to get started:

```bash
# 1. Clone the repository
git clone <repository-url>
cd backend-POC

# 2. Install uv (if not already installed)
curl -Ls https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.cargo/bin:$PATH"

# 3. Install all dependencies
uv sync --group dev

# 4. Install development tools (optional)
./scripts/install-tools.sh

# 5. Run the application
make run
```

Then visit http://127.0.0.1:8000/docs to see the API documentation.

### Installing uv

If you haven't installed uv yet, please install it first:

```bash
# macOS / Linux
curl -Ls https://astral.sh/uv/install.sh | sh

# Or using pip & Windows (via WSL or PowerShell):
pip install uv
or
iwr -useb https://astral.sh/uv/install.ps1 | iex
```

### Project Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd backend-POC
   ```

2. **Install dependencies**
   ```bash
   # Install all dependencies (including dev dependencies)
   uv sync --group dev
   ```

3. **Install development tools (optional but recommended)**
   ```bash
   # Install tools for local CI checks
   ./scripts/install-tools.sh
   ```

### Running the Application

**Using Makefile (recommended):**
```bash
make run
```

**Or directly with uv:**
```bash
uv run uvicorn app.main:app --host 127.0.0.1 --port 8000 --reload
```

### Verify the Application

After the service starts, you can access the following endpoints:

- **API Root**: http://127.0.0.1:8000/
- **API Documentation**: http://127.0.0.1:8000/docs

### Docker Development (Alternative)

If you prefer using Docker for development:

```bash
# Build Docker image
make docker-build

# Start with Docker Compose (hot-reload)
make docker-up
```

## Project Structure

```
backend-POC/
├── app/
│   └── main.py          # FastAPI application main file
├── scripts/             # Local CI scripts
│   ├── local-ci.sh      # Main CI script
│   ├── install-tools.sh # Tool installation script
│   ├── format.sh        # Quick formatting script
│   └── README.md        # Script documentation
├── pyproject.toml       # Project configuration and dependencies
├── uv.lock             # Dependency lock file
├── Makefile            # Development shortcuts
└── README.md           # Project documentation
```

## Troubleshooting

### Common Issues

1. **uv command not found**
   ```bash
   # Install uv
   curl -Ls https://astral.sh/uv/install.sh | sh
   export PATH="$HOME/.cargo/bin:$PATH"
   ```

2. **Dependency installation issues**
   ```bash
   # Re-sync dependencies
   uv sync --group dev
   ```

3. **Permission denied on scripts**
   ```bash
   # Make scripts executable
   chmod +x scripts/*.sh
   ```

4. **Port 8000 already in use**
   ```bash
   # Use a different port
   uv run uvicorn app.main:app --host 127.0.0.1 --port 8001 --reload
   ```

5. **Docker not running**
   ```bash
   # Start Docker Desktop (macOS) or Docker service (Linux)
   # Then try Docker commands again
   make docker-build
   ```

## API Endpoints

| Endpoint | Method | Description | Response |
|----------|--------|-------------|----------|
| `/` | GET | Root directory | `{"message": "Hello from Agaruda Backend!"}` |
| `/docs` | GET | API documentation | Swagger UI interface |

## Tech Stack

- **Framework**: FastAPI
- **ASGI Server**: Uvicorn
- **Package Manager**: uv
- **Python Version**: 3.11+

## Local Development & CI

### Local CI Scripts

**🚨 IMPORTANT: Before pushing PR, you MUST run local checks first!**

```bash
# Install development tools (first time only)
./scripts/install-tools.sh

# 🚨 REQUIRED: Run all CI checks before PR submission
make check

# Or use the script directly
./scripts/local-ci.sh

# Other useful commands
make format         # Format code
make lint           # Run linting only
make security       # Run security checks only
make build          # Run build checks only
make fix            # Auto-fix formatting issues
```

### Available Commands

| Command | Description |
|---------|-------------|
| **`make check`** | **🚨 REQUIRED: Run all CI checks before PR submission** |
| `make run` | Run FastAPI locally (127.0.0.1:8000) |
| `make format` | Format code with Black |
| `make lint` | Run linting checks (Flake8, Ruff, Mypy) |
| `make security` | Run security checks (Semgrep, Trivy, License) |
| `make build` | Run build checks (Docker, App startup) |
| `make fix` | Auto-fix formatting issues |
| `make install-tools` | Install development tools |
| `make docker-build` | Build Docker image (python-ci-image:local) |
| `make docker-up` | Start/restart Docker Compose (hot-reload) |
| `make clean` | Clean up temporary files |

### Script Options

```bash
# Run specific checks
./scripts/local-ci.sh --format-only    # Only formatting
./scripts/local-ci.sh --lint-only      # Only linting
./scripts/local-ci.sh --security-only  # Only security
./scripts/local-ci.sh --build-only     # Only build checks

# Auto-fix issues
./scripts/local-ci.sh --auto-fix       # Auto-fix formatting

# Get help
./scripts/local-ci.sh --help
```

### What Gets Checked

- **Code Quality**: Black formatting, Flake8 linting, Ruff checking, Mypy type checking
- **Build**: Dockerfile linting, Docker build test, FastAPI app startup test
- **Security**: Semgrep security scan, Trivy vulnerability scan, License check
- **Environment**: Python version, uv package manager, Docker availability

See `scripts/README.md` for detailed documentation.