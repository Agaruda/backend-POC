# Agaruda Backend API

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

1. **Initialize the project**
   ```bash
   uv init --app
   ```

2. **Add FastAPI dependency**
   ```bash
   uv add fastapi --extra standard
   ```

3. **Sync dependencies**
   ```bash
   uv sync
   ```

### Running the Application

**Correct way to run:**

```bash
uv run uvicorn app.main:app
```

### Verify the Application

After the service starts, you can access the following endpoints:

- **API Root**: http://127.0.0.1:8000/
- **API Documentation**: http://127.0.0.1:8000/docs

## Project Structure

```
backend-POC/
├── app/
│   └── main.py          # FastAPI application main file
├── pyproject.toml       # Project configuration and dependencies
├── uv.lock             # Dependency lock file
└── README.md           # Project documentation
```

## Troubleshooting

### Common Issues

1. **fastapi command not found**
   ```
   RuntimeError: To use the fastapi command, please install "fastapi[standard]"
   ```
   
   **Solution:**
   - Don't use the `fastapi dev` command
   - Use `uvicorn` to run FastAPI applications

2. **Dependency installation issues**
   ```bash
   # Re-sync dependencies
   uv sync
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