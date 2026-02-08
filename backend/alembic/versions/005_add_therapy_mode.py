"""add_therapy_mode

Revision ID: 005
Revises: 004
Create Date: 2026-02-08 17:40:00.000000

"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '005'
down_revision: Union[str, None] = '004'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Add therapy_mode column to health_profiles
    op.add_column('health_profiles', sa.Column('therapy_mode', sa.String(), nullable=True))


def downgrade() -> None:
    # Drop column
    op.drop_column('health_profiles', 'therapy_mode')
