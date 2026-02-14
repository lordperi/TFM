"""add_basal_insulin_and_therapy

Revision ID: 010
Revises: 009_add_xp_system
Create Date: 2026-02-14 13:30:00.000000

Añade soporte para:
- therapy_type: Tipo de tratamiento (INSULIN, ORAL, MIXED, NONE)
- basal_insulin_type: Tipo de insulina basal (Lantus, Levemir, etc.)
- basal_insulin_units: Unidades de insulina basal (CIFRADO)
- basal_insulin_time: Hora de administración
"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '010'
down_revision: Union[str, None] = '009_add_xp_system'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # 1. Crear ENUM para therapy_type
    therapy_type_enum = sa.Enum(
        'INSULIN', 'ORAL_MEDICATION', 'MIXED', 'NONE',
        name='therapy_type_enum',
        create_type=True
    )
    therapy_type_enum.create(op.get_bind(), checkfirst=True)
    
    # 2. Añadir columnas a health_profiles
    op.add_column('health_profiles', 
        sa.Column('therapy_type', therapy_type_enum, nullable=True))
    
    op.add_column('health_profiles',
        sa.Column('basal_insulin_type', sa.String(), nullable=True))
    
    # NOTA: basal_insulin_units se cifra a nivel de aplicación con EncryptedString
    # En la DB se almacena como LargeBinary (el TypeDecorator lo maneja)
    # Por eso usamos String aquí, el modelo SQLAlchemy aplicará EncryptedString
    op.add_column('health_profiles',
        sa.Column('basal_insulin_units', sa.String(), nullable=True))
    
    op.add_column('health_profiles',
        sa.Column('basal_insulin_time', sa.Time(), nullable=True))


def downgrade() -> None:
    # Eliminar columnas en orden inverso
    op.drop_column('health_profiles', 'basal_insulin_time')
    op.drop_column('health_profiles', 'basal_insulin_units')
    op.drop_column('health_profiles', 'basal_insulin_type')
    op.drop_column('health_profiles', 'therapy_type')
    
    # Eliminar enum
    sa.Enum(name='therapy_type_enum').drop(op.get_bind(), checkfirst=True)
