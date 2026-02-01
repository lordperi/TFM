# Stage 1: Builder
FROM python:3.12-slim as builder

WORKDIR /tmp

# Upgrade pip and generate wheels
# Cache Busting: Only invalidate this layer if requirements.txt changes
RUN pip install --upgrade pip
COPY requirements.txt .
RUN pip wheel --no-cache-dir --no-deps --wheel-dir /tmp/wheels -r requirements.txt

# Stage 2: Runtime
FROM python:3.12-slim

# Create a non-root user for security (DevSecOps requirement)
RUN groupadd -r appgroup && useradd -r -g appgroup appuser

WORKDIR /app

# Install dependencies from builder
# This layer is cached unless requirements.txt or builder changed
COPY --from=builder /tmp/wheels /tmp/wheels
COPY requirements.txt .
RUN pip install --no-cache-dir --no-index --find-links=/tmp/wheels -r requirements.txt \
    && rm -rf /tmp/wheels

# Copy application code
# This is the most frequent change, so it comes last
COPY src ./src
COPY alembic.ini .
COPY alembic ./alembic
COPY entrypoint.sh .

# Ensure permissions
RUN chown -R appuser:appgroup /app
RUN chmod +x entrypoint.sh

# Switch context to non-root user
USER appuser

# Expose API port
EXPOSE 8000

# Run commands via entrypoint
CMD ["./entrypoint.sh"]
