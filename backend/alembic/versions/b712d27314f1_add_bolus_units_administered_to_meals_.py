"""add_bolus_units_administered_to_meals_log

Revision ID: b712d27314f1
Revises: 011
Create Date: 2026-02-21 14:05:45.449229

"""
from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = 'b712d27314f1'
down_revision = '011'
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column('meals_log', sa.Column('bolus_units_administered', sa.Float(), nullable=True))


def downgrade() -> None:
    op.drop_column('meals_log', 'bolus_units_administered')
