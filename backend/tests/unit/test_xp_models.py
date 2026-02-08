"""
Tests for XP (Experience Points) Domain Models

Tests the XP transaction models, achievement models, and level calculation logic.
"""

import pytest
from datetime import datetime
from uuid import uuid4

from src.domain.xp_models import (
    XPReason,
    AchievementCategory,
    XPTransaction,
    XPTransactionCreate,
    Achievement,
    AchievementCreate,
    UserAchievement,
    UserAchievementCreate,
    calculate_level,
    xp_for_next_level,
    xp_progress_percentage,
    UserXPSummary,
)


class TestXPTransactionModels:
    """Test XP transaction models"""
    
    def test_xp_transaction_create_valid(self):
        """Test creating a valid XP transaction"""
        transaction = XPTransactionCreate(
            amount=50,
            reason=XPReason.MEAL_LOGGED,
            description="Logged breakfast"
        )
        assert transaction.amount == 50
        assert transaction.reason == XPReason.MEAL_LOGGED
        assert transaction.description == "Logged breakfast"
    
    def test_xp_transaction_negative_amount(self):
        """Test XP transaction with negative amount (penalty)"""
        transaction = XPTransactionCreate(
            amount=-10,
            reason=XPReason.MANUAL_ADJUSTMENT,
            description="Penalty for missed entry"
        )
        assert transaction.amount == -10
    
    def test_xp_transaction_full_model(self):
        """Test complete XP transaction model"""
        user_id = uuid4()
        transaction = XPTransaction(
            id=uuid4(),
            user_id=user_id,
            amount=100,
            reason=XPReason.ACHIEVEMENT_UNLOCKED,
            description="First achievement!",
            timestamp=datetime.utcnow()
        )
        assert transaction.user_id == user_id
        assert transaction.amount == 100


class TestAchievementModels:
    """Test achievement models"""
    
    def test_achievement_create_valid(self):
        """Test creating a valid achievement"""
        achievement = AchievementCreate(
            name="First Steps",
            description="Log your first meal",
            category=AchievementCategory.MILESTONE,
            icon="🎯",
            xp_reward=100
        )
        assert achievement.name == "First Steps"
        assert achievement.xp_reward == 100
        assert achievement.category == AchievementCategory.MILESTONE
    
    def test_achievement_full_model(self):
        """Test complete achievement model"""
        achievement = Achievement(
            id=uuid4(),
            name="Consistency King",
            description="Log meals for 7 days straight",
            category=AchievementCategory.CONSISTENCY,
           icon="👑",
            xp_reward=500
        )
        assert achievement.id is not None
        assert achievement.xp_reward == 500


class TestUserAchievementModels:
    """Test user achievement models"""
    
    def test_user_achievement_create(self):
        """Test creating user achievement"""
        achievement_id = uuid4()
        user_achievement = UserAchievementCreate(
            achievement_id=achievement_id
        )
        assert user_achievement.achievement_id == achievement_id
    
    def test_user_achievement_full_model(self):
        """Test complete user achievement with nested achievement"""
        user_id = uuid4()
        achievement_id = uuid4()
        
        achievement = Achievement(
            id=achievement_id,
            name="Quick Start",
            description="Complete profile setup",
            category=AchievementCategory.MILESTONE,
            icon="⚡",
            xp_reward=50
        )
        
        user_achievement = UserAchievement(
            id=uuid4(),
            user_id=user_id,
            achievement_id=achievement_id,
            unlocked_at=datetime.utcnow(),
            achievement=achievement
        )
        
        assert user_achievement.user_id == user_id
        assert user_achievement.achievement.name == "Quick Start"


class TestLevelCalculations:
    """Test level calculation utilities"""
    
    @pytest.mark.parametrize("total_xp,expected_level", [
        (0, 1),
        (100, 1),
        (499, 1),
        (500, 2),
        (999, 2),
        (1000, 3),
        (1499, 3),
        (1500, 4),
        (5000, 11),
    ])
    def test_calculate_level(self, total_xp, expected_level):
        """Test level calculation for various XP amounts"""
        assert calculate_level(total_xp) == expected_level
    
    def test_calculate_level_negative_xp(self):
        """Test level calculation with negative XP (should return 1)"""
        assert calculate_level(-100) == 1
    
    @pytest.mark.parametrize("current_xp,expected_xp_needed", [
        (0, 500),
        (250, 250),
        (499, 1),
        (500, 500),
        (750, 250),
        (1000, 500),
    ])
    def test_xp_for_next_level(self, current_xp, expected_xp_needed):
        """Test XP needed for next level"""
        assert xp_for_next_level(current_xp) == expected_xp_needed
    
    @pytest.mark.parametrize("current_xp,expected_percentage", [
        (0, 0.0),
        (250, 0.5),
        (499, 0.998),
        (500, 0.0),
        (750, 0.5),
        (1000, 0.0),
    ])
    def test_xp_progress_percentage(self, current_xp, expected_percentage):
        """Test progress percentage calculation"""
        result = xp_progress_percentage(current_xp)
        assert abs(result - expected_percentage) < 0.01


class TestUserXPSummary:
    """Test user XP summary model"""
    
    def test_user_xp_summary_creation(self):
        """Test creating XP summary from total XP"""
        summary = UserXPSummary.from_total_xp(750)
        
        assert summary.total_xp == 750
        assert summary.current_level == 2
        assert summary.xp_to_next_level == 250
        assert abs(summary.progress_percentage - 0.5) < 0.01
        assert summary.recent_transactions == []
    
    def test_user_xp_summary_with_transactions(self):
        """Test XP summary with recent transactions"""
        user_id = uuid4()
        transactions = [
            XPTransaction(
                id=uuid4(),
                user_id=user_id,
                amount=50,
                reason=XPReason.MEAL_LOGGED,
                description="Breakfast",
                timestamp=datetime.utcnow()
            ),
            XPTransaction(
                id=uuid4(),
                user_id=user_id,
                amount=30,
                reason=XPReason.BOLUS_CALCULATED,
                description="Calculated bolus",
                timestamp=datetime.utcnow()
            ),
        ]
        
        summary = UserXPSummary.from_total_xp(1200, transactions)
        
        assert summary.total_xp == 1200
        assert summary.current_level == 3
        assert len(summary.recent_transactions) == 2
        assert summary.recent_transactions[0].amount == 50
