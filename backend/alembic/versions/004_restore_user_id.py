"""restore_user_id

Revision ID: 004
Revises: 003
Create Date: 2026-02-08 17:30:00.000000

"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = '004'
down_revision: Union[str, None] = '003'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Add user_id column back to health_profiles
    op.add_column('health_profiles', sa.Column('user_id', sa.Uuid(), nullable=True))
    
    # Create Foreign Key
    op.create_foreign_key(None, 'health_profiles', 'users', ['user_id'], ['id'])
    
    # Create Index/Unique constraint
    op.create_index(op.f('ix_health_profiles_user_id'), 'health_profiles', ['user_id'], unique=True)


def downgrade() -> None:
    # Drop index
    op.drop_index(op.f('ix_health_profiles_user_id'), table_name='health_profiles')
    
    # Drop FK
    op.drop_constraint(None, 'health_profiles', type_='foreignkey')
    
    # Drop column
    op.drop_column('health_profiles', 'user_id')
