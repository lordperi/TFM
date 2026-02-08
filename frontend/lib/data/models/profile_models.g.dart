// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

XPTransaction _$XPTransactionFromJson(Map<String, dynamic> json) =>
    XPTransaction(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      amount: (json['amount'] as num).toInt(),
      reason: json['reason'] as String,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$XPTransactionToJson(XPTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'amount': instance.amount,
      'reason': instance.reason,
      'description': instance.description,
      'timestamp': instance.timestamp.toIso8601String(),
    };

Achievement _$AchievementFromJson(Map<String, dynamic> json) => Achievement(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      icon: json['icon'] as String,
      xpReward: (json['xp_reward'] as num).toInt(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$AchievementToJson(Achievement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'category': instance.category,
      'icon': instance.icon,
      'xp_reward': instance.xpReward,
      'created_at': instance.createdAt?.toIso8601String(),
    };

UserAchievement _$UserAchievementFromJson(Map<String, dynamic> json) =>
    UserAchievement(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      achievementId: json['achievement_id'] as String,
      unlockedAt: DateTime.parse(json['unlocked_at'] as String),
      achievement: json['achievement'] == null
          ? null
          : Achievement.fromJson(json['achievement'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserAchievementToJson(UserAchievement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'achievement_id': instance.achievementId,
      'unlocked_at': instance.unlockedAt.toIso8601String(),
      'achievement': instance.achievement,
    };

UserXPSummary _$UserXPSummaryFromJson(Map<String, dynamic> json) =>
    UserXPSummary(
      totalXp: (json['total_xp'] as num).toInt(),
      currentLevel: (json['current_level'] as num).toInt(),
      xpToNextLevel: (json['xp_to_next_level'] as num).toInt(),
      progressPercentage: (json['progress_percentage'] as num).toDouble(),
      recentTransactions: (json['recent_transactions'] as List<dynamic>?)
              ?.map((e) => XPTransaction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$UserXPSummaryToJson(UserXPSummary instance) =>
    <String, dynamic>{
      'total_xp': instance.totalXp,
      'current_level': instance.currentLevel,
      'xp_to_next_level': instance.xpToNextLevel,
      'progress_percentage': instance.progressPercentage,
      'recent_transactions': instance.recentTransactions,
    };

AchievementsResponse _$AchievementsResponseFromJson(
        Map<String, dynamic> json) =>
    AchievementsResponse(
      unlocked: (json['unlocked'] as List<dynamic>)
          .map((e) => UserAchievement.fromJson(e as Map<String, dynamic>))
          .toList(),
      locked: (json['locked'] as List<dynamic>)
          .map((e) => Achievement.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AchievementsResponseToJson(
        AchievementsResponse instance) =>
    <String, dynamic>{
      'unlocked': instance.unlocked,
      'locked': instance.locked,
    };

HealthProfileUpdate _$HealthProfileUpdateFromJson(Map<String, dynamic> json) =>
    HealthProfileUpdate(
      diabetesType: json['diabetes_type'] as String?,
      insulinSensitivity: (json['insulin_sensitivity'] as num?)?.toDouble(),
      carbRatio: (json['carb_ratio'] as num?)?.toDouble(),
      targetGlucose: (json['target_glucose'] as num?)?.toInt(),
    );

Map<String, dynamic> _$HealthProfileUpdateToJson(
        HealthProfileUpdate instance) =>
    <String, dynamic>{
      'diabetes_type': instance.diabetesType,
      'insulin_sensitivity': instance.insulinSensitivity,
      'carb_ratio': instance.carbRatio,
      'target_glucose': instance.targetGlucose,
    };

PasswordChangeRequest _$PasswordChangeRequestFromJson(
        Map<String, dynamic> json) =>
    PasswordChangeRequest(
      oldPassword: json['old_password'] as String,
      newPassword: json['new_password'] as String,
      confirmPassword: json['confirm_password'] as String,
    );

Map<String, dynamic> _$PasswordChangeRequestToJson(
        PasswordChangeRequest instance) =>
    <String, dynamic>{
      'old_password': instance.oldPassword,
      'new_password': instance.newPassword,
      'confirm_password': instance.confirmPassword,
    };
