"""glucose_tracking_models

Revision ID: 011
Revises: 010
Create Date: 2026-02-14 16:00:00.000000

"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = '011'
down_revision: Union[str, None] = '010'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # 1. Create glucose_measurements table
    op.create_table('glucose_measurements',
        sa.Column('id', sa.UUID(), nullable=False),
        sa.Column('patient_id', sa.UUID(), nullable=False),
        sa.Column('glucose_value', sa.Integer(), nullable=False),
        sa.Column('timestamp', sa.DateTime(), nullable=True),
        sa.Column('measurement_type', sa.String(length=20), nullable=False),
        sa.Column('notes', sa.LargeBinary(), nullable=True), # EncryptedString
        sa.ForeignKeyConstraint(['patient_id'], ['patients.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_glucose_measurements_patient_id'), 'glucose_measurements', ['patient_id'], unique=False)
    op.create_index(op.f('ix_glucose_measurements_timestamp'), 'glucose_measurements', ['timestamp'], unique=False)

    # 2. Add target range columns to health_profiles
    op.add_column('health_profiles', sa.Column('target_range_low', sa.Integer(), nullable=True))
    op.add_column('health_profiles', sa.Column('target_range_high', sa.Integer(), nullable=True))


def downgrade() -> None:
    # Remove health_profiles columns
    op.drop_column('health_profiles', 'target_range_high')
    op.drop_column('health_profiles', 'target_range_low')

    # Remove glucose_measurements table
    op.drop_index(op.f('ix_glucose_measurements_timestamp'), table_name='glucose_measurements')
    op.drop_index(op.f('ix_glucose_measurements_patient_id'), table_name='glucose_measurements')
    op.drop_table('glucose_measurements')
