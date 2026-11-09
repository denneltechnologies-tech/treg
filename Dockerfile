# Stage 1: Build the frontend dashboard
FROM node:22-bookworm-slim AS frontend-builder
WORKDIR /app

# Copy package files and install dependencies
COPY frontend/package*.json ./frontend/
RUN cd frontend && npm ci

# Copy sources needed for frontend build
COPY frontend/ ./frontend/
COPY src/treg/web/ ./src/treg/web/

# Build dashboard and copy runtime assets
RUN cd frontend && npm run build

# Stage 2: Production Python Runtime
FROM python:3.12-slim-bookworm

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PORT=18790 \
    TREG_DATABASE_URL=sqlite+aiosqlite:////data/treg.db \
    TREG_SINGLE_USER=true \
    PATH="/app/.venv/bin:$PATH"

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install uv for fast, reliable, reproducible dependency resolution (>=0.12)
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Copy dependency files and build script
COPY pyproject.toml uv.lock README.md LICENSE hatch_build.py ./

# Step 1: Install 3rd-party dependencies first without building the project
RUN uv sync --no-install-project --locked --no-dev --extra server --extra proxy

# Copy compiled frontend & web assets from stage 1
COPY --from=frontend-builder /app/src/treg/web/dashboard ./src/treg/web/dashboard
COPY --from=frontend-builder /app/src/treg/web/vendor ./src/treg/web/vendor

# Copy application source
COPY . /app

# Step 2: Install project itself (dashboard assets now present for hatch_build.py)
RUN uv sync --locked --no-dev --extra server --extra proxy

# Ensure data directory exists for persistent sqlite and cache storage
RUN mkdir -p /data

EXPOSE 18790

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD curl -fsS http://localhost:${PORT:-18790}/meta || exit 1

CMD ["sh", "-c", "python -m treg upgrade && python -m treg"]
