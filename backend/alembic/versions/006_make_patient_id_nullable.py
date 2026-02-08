"""make_patient_id_nullable

Revision ID: 006
Revises: 005
Create Date: 2026-02-08 17:50:00.000000

"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '006'
down_revision: Union[str, None] = '005'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Make patient_id nullable in health_profiles
    op.alter_column('health_profiles', 'patient_id', nullable=True)


def downgrade() -> None:
    # Revert to not nullable (WARNING: Might fail if nulls exist)
    op.alter_column('health_profiles', 'patient_id', nullable=False)
