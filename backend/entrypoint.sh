#!/bin/sh

# Exit immediately if a command exits with a non-zero status
set -e

# Run migrations
echo "Running database migrations..."
alembic upgrade head

# Start application
echo "Starting application..."
exec uvicorn src.main:app --host 0.0.0.0 --port 8000
