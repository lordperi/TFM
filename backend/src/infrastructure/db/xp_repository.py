"""
XP Repository

Repository for XP and achievement data access operations.
Handles all database interactions for the gamification system.
"""

from uuid import UUID
from datetime import datetime, timedelta
from sqlalchemy import select, func, desc
from sqlalchemy.orm import Session, selectinload

from src.domain.xp_models import (
    XPTransaction,
    XPTransactionCreate,
    Achievement,
    AchievementCreate,
    UserAchievement,
    UserAchievementCreate,
    UserXPSummary,
)
from src.infrastructure.db.models import (
    XPTransactionModel,
    AchievementModel,
    UserAchievementModel,
)


class XPRepository:
    """Repository for XP and achievements"""
    
    def __init__(self, db: Session):
        self.db = db
    
    # --- XP Transaction Operations ---
    
    def add_xp(
        self,
        user_id: UUID,
        amount: int,
        reason: str,
        description: str
    ) -> XPTransaction:
        """
        Add XP transaction for a user.
        
        Args:
            user_id: User's UUID
            amount: XP amount (positive or negative)
            reason: XPReason enum value
            description: Human-readable description
            
        Returns:
            Created XP transaction
        """
        transaction_model = XPTransactionModel(
            user_id=user_id,
            amount=amount,
            reason=reason,
            description=description,
            timestamp=datetime.utcnow()
        )
        self.db.add(transaction_model)
        self.db.commit()
        self.db.refresh(transaction_model)
        
        return XPTransaction.model_validate(transaction_model)
    
    def get_user_xp_history(
        self,
        user_id: UUID,
        limit: int = 50,
        skip: int = 0
    ) -> list[XPTransaction]:
        """
        Get XP transaction history for a user.
        
        Args:
            user_id: User's UUID
            limit: Maximum number of transactions to return
            skip: Number of transactions to skip (for pagination)
            
        Returns:
            List of XP transactions, ordered by timestamp descending
        """
        stmt = (
            select(XPTransactionModel)
            .where(XPTransactionModel.user_id == user_id)
            .order_by(desc(XPTransactionModel.timestamp))
            .limit(limit)
            .offset(skip)
        )
        
        results = self.db.execute(stmt).scalars().all()
        return [XPTransaction.model_validate(r) for r in results]
    
    def get_user_total_xp(self, user_id: UUID) -> int:
        """
        Calculate total XP for a user.
        
        Args:
            user_id: User's UUID
            
        Returns:
            Total XP (sum of all transaction amounts)
        """
        stmt = (
            select(func.coalesce(func.sum(XPTransactionModel.amount), 0))
            .where(XPTransactionModel.user_id == user_id)
        )
        
        result = self.db.execute(stmt).scalar()
        return int(result)
    
    def get_user_xp_summary(self, user_id: UUID) -> UserXPSummary:
        """
        Get complete XP summary for a user.
        
        Args:
            user_id: User's UUID
            
        Returns:
            UserXPSummary with total XP, level, progress, and recent transactions
        """
        total_xp = self.get_user_total_xp(user_id)
        recent_transactions = self.get_user_xp_history(user_id, limit=10)
        
        return UserXPSummary.from_total_xp(total_xp, recent_transactions)
    
    # --- Achievement Operations ---
    
    def get_all_achievements(self) -> list[Achievement]:
        """
        Get all available achievements.
        
        Returns:
            List of all achievements
        """
        stmt = select(AchievementModel)
        results = self.db.execute(stmt).scalars().all()
        return [Achievement.model_validate(r) for r in results]
    
    def get_achievement_by_id(self, achievement_id: UUID) -> Achievement | None:
        """
        Get achievement by ID.
        
        Args:
            achievement_id: Achievement's UUID
            
        Returns:
            Achievement if found, None otherwise
        """
        stmt = select(AchievementModel).where(AchievementModel.id == achievement_id)
        result = self.db.execute(stmt).scalar_one_or_none()
        return Achievement.model_validate(result) if result else None
    
    def create_achievement(self, achievement: AchievementCreate) -> Achievement:
        """
        Create a new achievement.
        
        Args:
            achievement: Achievement data
            
        Returns:
            Created achievement
        """
        achievement_model = AchievementModel(**achievement.model_dump())
        self.db.add(achievement_model)
        self.db.commit()
        self.db.refresh(achievement_model)
        
        return Achievement.model_validate(achievement_model)
    
    # --- User Achievement Operations ---
    
    def unlock_achievement(
        self,
        user_id: UUID,
        achievement_id: UUID
    ) -> UserAchievement | None:
        """
        Unlock an achievement for a user.
        
        Args:
            user_id: User's UUID
            achievement_id: Achievement's UUID
            
        Returns:
            UserAchievement if successfully unlocked, None if already unlocked
        """
        # Check if already unlocked
        existing = self.is_achievement_unlocked(user_id, achievement_id)
        if existing:
            return None
        
        # Create user achievement record
        user_achievement_model = UserAchievementModel(
            user_id=user_id,
            achievement_id=achievement_id,
            unlocked_at=datetime.utcnow()
        )
        self.db.add(user_achievement_model)
        
        # Award XP for the achievement
        achievement = self.get_achievement_by_id(achievement_id)
        if achievement and achievement.xp_reward > 0:
            self.add_xp(
                user_id=user_id,
                amount=achievement.xp_reward,
                reason="achievement_unlocked",
                description=f"Unlocked: {achievement.name}"
            )
        
        self.db.commit()
        self.db.refresh(user_achievement_model)
        
        # Load achievement relationship
        stmt = (
            select(UserAchievementModel)
            .options(selectinload(UserAchievementModel.achievement))
            .where(UserAchievementModel.id == user_achievement_model.id)
        )
        loaded_model = self.db.execute(stmt).scalar_one()
        
        return UserAchievement.model_validate(loaded_model)
    
    def is_achievement_unlocked(self, user_id: UUID, achievement_id: UUID) -> bool:
        """
        Check if user has unlocked an achievement.
        
        Args:
            user_id: User's UUID
            achievement_id: Achievement's UUID
            
        Returns:
            True if unlocked, False otherwise
        """
        stmt = (
            select(UserAchievementModel)
            .where(
                UserAchievementModel.user_id == user_id,
                UserAchievementModel.achievement_id == achievement_id
            )
        )
        result = self.db.execute(stmt).scalar_one_or_none()
        return result is not None
    
    def get_user_achievements(self, user_id: UUID) -> list[UserAchievement]:
        """
        Get all achievements unlocked by a user.
        
        Args:
            user_id: User's UUID
            
        Returns:
            List of user achievements with achievement details
        """
        stmt = (
            select(UserAchievementModel)
            .options(selectinload(UserAchievementModel.achievement))
            .where(UserAchievementModel.user_id == user_id)
            .order_by(desc(UserAchievementModel.unlocked_at))
        )
        
        results = self.db.execute(stmt).scalars().all()
        return [UserAchievement.model_validate(r) for r in results]
    
    def get_user_locked_achievements(self, user_id: UUID) -> list[Achievement]:
        """
        Get achievements that user hasn't unlocked yet.
        
        Args:
            user_id: User's UUID
            
        Returns:
            List of locked achievements
        """
        # Subquery for unlocked achievement IDs
        unlocked_ids_stmt = (
            select(UserAchievementModel.achievement_id)
            .where(UserAchievementModel.user_id == user_id)
        )
        
        # Get achievements not in unlocked list
        stmt = (
            select(AchievementModel)
            .where(AchievementModel.id.not_in(unlocked_ids_stmt))
        )
        
        results = self.db.execute(stmt).scalars().all()
        return [Achievement.model_validate(r) for r in results]
