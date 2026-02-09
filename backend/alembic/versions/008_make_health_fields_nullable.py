"""make_health_fields_nullable

Revision ID: 008
Revises: 007
Create Date: 2026-02-08 18:25:00.000000

"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '008_make_health_fields_nullable'
down_revision: Union[str, None] = '007_add_missing_patient_columns'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Make health profile columns nullable to support non-diabetics (e.g. Guardians)
    op.alter_column('health_profiles', 'diabetes_type', nullable=True)
    op.alter_column('health_profiles', 'insulin_sensitivity', nullable=True)
    op.alter_column('health_profiles', 'carb_ratio', nullable=True)
    op.alter_column('health_profiles', 'target_glucose', nullable=True)


def downgrade() -> None:
    # Revert to not nullable (Warning: Valid only if no nulls exist)
    # We assume 'T1' and defaults for rollback if needed, but strictly:
    op.alter_column('health_profiles', 'diabetes_type', nullable=False)
    op.alter_column('health_profiles', 'insulin_sensitivity', nullable=False)
    op.alter_column('health_profiles', 'carb_ratio', nullable=False)
    op.alter_column('health_profiles', 'target_glucose', nullable=False)
