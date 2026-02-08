"""add_missing_patient_columns

Revision ID: 007
Revises: 006
Create Date: 2026-02-08 18:05:00.000000

"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '007'
down_revision: Union[str, None] = '006'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Add missing columns to patients table
    op.add_column('patients', sa.Column('role', sa.String(), nullable=False, server_default='DEPENDENT'))
    op.add_column('patients', sa.Column('pin_hash', sa.String(), nullable=True))


def downgrade() -> None:
    # Drop columns
    op.drop_column('patients', 'pin_hash')
    op.drop_column('patients', 'role')
