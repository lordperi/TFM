"""fix_basal_insulin_units_column_type_to_bytea

Revision ID: 012
Revises: b712d27314f1
Create Date: 2026-02-21 17:00:00.000000

Bug fix: La migración 010 creó la columna `basal_insulin_units` como VARCHAR (sa.String),
pero el ORM la define con EncryptedString (impl=LargeBinary → BYTEA en PostgreSQL).
Al leer cualquier fila con basal_insulin_units no-NULL, SQLAlchemy intentaba
bytes(str_value) sin encoding → TypeError → 500 en GET /api/v1/family/members/{id}.

Fix: Se convierte la columna a BYTEA. Los valores existentes se ponen a NULL porque
los datos almacenados como bytes en una columna VARCHAR son irrecuperables de forma fiable.
Los usuarios deberán reintroducir su insulina basal.
"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = '012'
down_revision: Union[str, None] = 'b712d27314f1'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Paso 1: Anular los valores existentes para evitar errores de conversión.
    # Los datos en VARCHAR eran bytes Fernet serializados de forma impredecible
    # y no son recuperables de forma fiable.
    op.execute("UPDATE health_profiles SET basal_insulin_units = NULL")

    # Paso 2: Cambiar el tipo de columna de VARCHAR a BYTEA.
    # La cláusula USING es necesaria para PostgreSQL; con valores NULL no hace nada.
    op.alter_column(
        'health_profiles',
        'basal_insulin_units',
        type_=sa.LargeBinary(),
        existing_nullable=True,
        postgresql_using='basal_insulin_units::bytea',
    )


def downgrade() -> None:
    # Revertir BYTEA → VARCHAR (los datos cifrados en BYTEA se perderán)
    op.execute("UPDATE health_profiles SET basal_insulin_units = NULL")
    op.alter_column(
        'health_profiles',
        'basal_insulin_units',
        type_=sa.String(),
        existing_nullable=True,
        postgresql_using='NULL',
    )
