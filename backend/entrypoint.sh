#!/bin/sh

# Exit immediately if a command exits with a non-zero status
set -e

# Reset database if requested
if [ "$RESET_DB" = "true" ]; then
    echo "RESET_DB is set to true. Resetting database..."
    python src/reset_db.py
fi

# Run migrations
echo "Running database migrations..."
alembic upgrade head

# Start application
echo "Starting application..."
exec uvicorn src.main:app --host 0.0.0.0 --port 8000
