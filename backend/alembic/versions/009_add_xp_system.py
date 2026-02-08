"""Add XP and achievements system

Revision ID: 009_add_xp_system
Revises: 008_make_health_fields_nullable
Create Date: 2026-02-08 23:56:00

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import UUID

# revision identifiers, used by Alembic.
revision = '009_add_xp_system'
down_revision = '008_make_health_fields_nullable'
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Create achievements table
    op.create_table(
        'achievements',
        sa.Column('id', UUID(as_uuid=True), primary_key=True, server_default=sa.text('gen_random_uuid()')),
        sa.Column('name', sa.String(100), nullable=False),
        sa.Column('description', sa.String(255), nullable=False),
        sa.Column('category', sa.String(50), nullable=False),
        sa.Column('icon', sa.String(50), nullable=False),
        sa.Column('xp_reward', sa.Integer, nullable=False),
        sa.Column('created_at', sa.DateTime, server_default=sa.text('CURRENT_TIMESTAMP')),
    )
    op.create_index('ix_achievements_category', 'achievements', ['category'])
    
    # Create xp_transactions table
    op.create_table(
        'xp_transactions',
        sa.Column('id', UUID(as_uuid=True), primary_key=True, server_default=sa.text('gen_random_uuid()')),
        sa.Column('user_id', UUID(as_uuid=True), nullable=False),
        sa.Column('amount', sa.Integer, nullable=False),
        sa.Column('reason', sa.String(50), nullable=False),
        sa.Column('description', sa.String(255), nullable=False),
        sa.Column('timestamp', sa.DateTime, nullable=False, server_default=sa.text('CURRENT_TIMESTAMP')),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
    )
    op.create_index('ix_xp_transactions_user_id', 'xp_transactions', ['user_id'])
    op.create_index('ix_xp_transactions_timestamp', 'xp_transactions', ['timestamp'])
    
    # Create user_achievements junction table
    op.create_table(
        'user_achievements',
        sa.Column('id', UUID(as_uuid=True), primary_key=True, server_default=sa.text('gen_random_uuid()')),
        sa.Column('user_id', UUID(as_uuid=True), nullable=False),
        sa.Column('achievement_id', UUID(as_uuid=True), nullable=False),
        sa.Column('unlocked_at', sa.DateTime, nullable=False, server_default=sa.text('CURRENT_TIMESTAMP')),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['achievement_id'], ['achievements.id'], ondelete='CASCADE'),
        sa.UniqueConstraint('user_id', 'achievement_id', name='uq_user_achievement'),
    )
    op.create_index('ix_user_achievements_user_id', 'user_achievements', ['user_id'])
    op.create_index('ix_user_achievements_achievement_id', 'user_achievements', ['achievement_id'])
    
    # Insert some default achievements
    op.execute("""
        INSERT INTO achievements (name, description, category, icon, xp_reward) VALUES
        ('First Steps', 'Log your first meal', 'milestone', '🎯', 100),
        ('Quick Start', 'Complete your profile setup', 'milestone', '⚡', 50),
        ('Consistency King', 'Log meals for 7 days straight', 'consistency', '👑', 500),
        ('Health Hero', 'Maintain glucose in target range for 24h', 'health', '❤️', 300),
        ('Learning Champ', 'Calculate 10 bolus doses', 'learning', '🎓', 200),
        ('Weekly Warrior', 'Check in every day for a week', 'consistency', '💪', 400),
        ('Perfect Day', 'Complete all daily goals in one day', 'health', '⭐', 250)
    """)


def downgrade() -> None:
    op.drop_table('user_achievements')
    op.drop_table('xp_transactions')
    op.drop_table('achievements')
