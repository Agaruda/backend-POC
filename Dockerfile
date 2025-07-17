FROM ghcr.io/astral-sh/uv:python3.11-bookworm-slim
WORKDIR /app

# 1. Install dependencies first (cache layer)
COPY pyproject.toml uv.lock ./
RUN uv sync --locked --no-editable --compile-bytecode     # → /app/.venv

# 2. Copy application code
COPY . .

# 3. Add .venv/bin to PATH
ENV PATH="/app/.venv/bin:$PATH"

EXPOSE 8080
CMD ["uv", "run", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]