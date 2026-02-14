"""
XP (Experience Points) and Achievement System Domain Models

This module defines the domain models for the gamification system:
- XPTransaction: Records of XP gains/losses
- Achievement: Available achievements in the system
- UserAchievement: User's unlocked achievements
- Level calculation utilities
"""

from datetime import datetime
from uuid import UUID, uuid4
from pydantic import BaseModel, Field, ConfigDict
from enum import Enum


class XPReason(str, Enum):
    """Reasons for XP transactions"""
    MEAL_LOGGED = "meal_logged"
    BOLUS_CALCULATED = "bolus_calculated"
    DAILY_LOGIN = "daily_login"
    PERFECT_GLUCOSE = "perfect_glucose"
    WEEK_STREAK = "week_streak"
    ACHIEVEMENT_UNLOCKED = "achievement_unlocked"
    MANUAL_ADJUSTMENT = "manual_adjustment"


class AchievementCategory(str, Enum):
    """Categories for achievements"""
    CONSISTENCY = "consistency"
    HEALTH = "health"
    LEARNING = "learning"
    SOCIAL = "social"
    MILESTONE = "milestone"


# --- XP Transaction Models ---

class XPTransactionBase(BaseModel):
    """Base model for XP transactions"""
    amount: int = Field(..., description="XP amount (positive for gains, negative for losses)")
    reason: XPReason
    description: str = Field(..., max_length=255, description="Human-readable description")


class XPTransactionCreate(XPTransactionBase):
    """Model for creating XP transactions"""
    pass


class XPTransaction(XPTransactionBase):
    """Complete XP transaction with metadata"""
    id: UUID = Field(default_factory=uuid4)
    user_id: UUID
    timestamp: datetime = Field(default_factory=datetime.utcnow)
    
    model_config = ConfigDict(from_attributes=True)


# --- Achievement Models ---

class AchievementBase(BaseModel):
    """Base model for achievements"""
    name: str = Field(..., max_length=100)
    description: str = Field(..., max_length=255)
    category: AchievementCategory
    icon: str = Field(..., max_length=50, description="Icon identifier")
    xp_reward: int = Field(..., ge=0, description="XP awarded when unlocked")


class AchievementCreate(AchievementBase):
    """Model for creating achievements"""
    pass


class Achievement(AchievementBase):
    """Complete achievement definition"""
    id: UUID = Field(default_factory=uuid4)
    
    model_config = ConfigDict(from_attributes=True)


# --- User Achievement Models ---

class UserAchievementBase(BaseModel):
    """Base model for user achievements"""
    achievement_id: UUID
    

class UserAchievementCreate(UserAchievementBase):
    """Model for unlocking achievements"""
    pass


class UserAchievement(UserAchievementBase):
    """Complete user achievement record"""
    id: UUID = Field(default_factory=uuid4)
    user_id: UUID
    unlocked_at: datetime = Field(default_factory=datetime.utcnow)
    achievement: Achievement | None = None  # Populated via join
    
    model_config = ConfigDict(from_attributes=True)


# --- Level Calculation Utilities ---

def calculate_level(total_xp: int) -> int:
    """
    Calculate user level from total XP.
    
    Formula: Level increases every 500 XP
    - Level 1: 0-499 XP
    - Level 2: 500-999 XP
    - Level 3: 1000-1499 XP
    - etc.
    
    Args:
        total_xp: Total experience points
        
    Returns:
        Current level (minimum 1)
    """
    if total_xp < 0:
        return 1
    return (total_xp // 500) + 1


def xp_for_next_level(current_xp: int) -> int:
    """
    Calculate XP needed to reach next level.
    
    Args:
        current_xp: Current experience points
        
    Returns:
        XP needed for next level
    """
    current_level = calculate_level(current_xp)
    next_level_threshold = current_level * 500
    return next_level_threshold - current_xp


def xp_progress_percentage(current_xp: int) -> float:
    """
    Calculate percentage progress to next level.
    
    Args:
        current_xp: Current experience points
        
    Returns:
        Percentage (0.0 to 1.0) of progress to next level
    """
    current_level = calculate_level(current_xp)
    level_start_xp = (current_level - 1) * 500
    xp_in_current_level = current_xp - level_start_xp
    return xp_in_current_level / 500.0


# --- User XP Summary ---

class UserXPSummary(BaseModel):
    """Summary of user's XP status"""
    total_xp: int
    current_level: int
    xp_to_next_level: int
    progress_percentage: float
    recent_transactions: list[XPTransaction] = Field(default_factory=list)
    
    @classmethod
    def from_total_xp(cls, total_xp: int, recent_transactions: list[XPTransaction] = None):
        """Create summary from total XP"""
        return cls(
            total_xp=total_xp,
            current_level=calculate_level(total_xp),
            xp_to_next_level=xp_for_next_level(total_xp),
            progress_percentage=xp_progress_percentage(total_xp),
            recent_transactions=recent_transactions or []
        )
