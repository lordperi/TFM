"""
Simple script to export OpenAPI schema.
Run with: docker-compose exec backend python scripts/export_swagger.py
Or in local venv: python scripts/export_swagger.py
"""
import json
import os
import sys

# Ensure environment variables are set
os.environ.setdefault("ENCRYPTION_KEY", "TXlTdXBlclNlY3JldEtleTMyYnl0ZXM9PT09PT09PT0=")
os.environ.setdefault("DATABASE_URL", "sqlite:///:memory:")

# Add src to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

try:
    from src.main import app
    
    # Get OpenAPI schema
    schema = app.openapi()
    
    # Write to docs/swagger.json
    output_path = os.path.join(os.path.dirname(__file__), '..', '..', 'docs', 'swagger.json')
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(schema, f, indent=2, ensure_ascii=False)
    
    # Count endpoints
    total_endpoints = sum(len(methods) for methods in schema.get('paths', {}).values())
    
    print(f"✅ OpenAPI schema exported to: {output_path}")
    print(f"📊 Total endpoints: {total_endpoints}")
    print(f"🏷️  API Version: {schema.get('info', {}).get('version')}")
    
except ImportError as e:
    print(f"❌ Error: {e}")
    print("� Run this script inside Docker or with dependencies installed:")
    print("   docker-compose exec backend python scripts/export_swagger.py")
    sys.exit(1)
