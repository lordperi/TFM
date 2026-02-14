import 'package:json_annotation/json_annotation.dart';

part 'profile_models.g.dart';

/// XP Transaction representing XP gains/losses
@JsonSerializable()
class XPTransaction {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  final int amount;
  final String reason;
  final String description;
  final DateTime timestamp;

  XPTransaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.reason,
    required this.description,
    required this.timestamp,
  });

  factory XPTransaction.fromJson(Map<String, dynamic> json) =>
      _$XPTransactionFromJson(json);

  Map<String, dynamic> toJson() => _$XPTransactionToJson(this);
}

/// Achievement definition
@JsonSerializable()
class Achievement {
  final String id;
  final String name;
  final String description;
  final String category;
  final String icon;
  @JsonKey(name: 'xp_reward')
  final int xpReward;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.icon,
    required this.xpReward,
    this.createdAt,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);

  Map<String, dynamic> toJson() => _$AchievementToJson(this);
}

/// User's unlocked achievement
@JsonSerializable()
class UserAchievement {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'achievement_id')
  final String achievementId;
  @JsonKey(name: 'unlocked_at')
  final DateTime unlockedAt;
  final Achievement? achievement;

  UserAchievement({
    required this.id,
    required this.userId,
    required this.achievementId,
    required this.unlockedAt,
    this.achievement,
  });

  factory UserAchievement.fromJson(Map<String, dynamic> json) =>
      _$UserAchievementFromJson(json);

  Map<String, dynamic> toJson() => _$UserAchievementToJson(this);
}

/// User XP Summary with level and progress
@JsonSerializable()
class UserXPSummary {
  @JsonKey(name: 'total_xp')
  final int totalXp;
  @JsonKey(name: 'current_level')
  final int currentLevel;
  @JsonKey(name: 'xp_to_next_level')
  final int xpToNextLevel;
  @JsonKey(name: 'progress_percentage')
  final double progressPercentage;
  @JsonKey(name: 'recent_transactions')
  final List<XPTransaction> recentTransactions;

  UserXPSummary({
    required this.totalXp,
    required this.currentLevel,
    required this.xpToNextLevel,
    required this.progressPercentage,
    this.recentTransactions = const [],
  });

  factory UserXPSummary.fromJson(Map<String, dynamic> json) =>
      _$UserXPSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$UserXPSummaryToJson(this);
}

/// Achievements response with unlocked and locked
@JsonSerializable()
class AchievementsResponse {
  final List<UserAchievement> unlocked;
  final List<Achievement> locked;

  AchievementsResponse({
    required this.unlocked,
    required this.locked,
  });

  factory AchievementsResponse.fromJson(Map<String, dynamic> json) =>
      _$AchievementsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AchievementsResponseToJson(this);
}

/// Health Profile Update request
@JsonSerializable()
class HealthProfileUpdate {
  @JsonKey(name: 'diabetes_type')
  final String? diabetesType;
  
  @JsonKey(name: 'therapy_type')
  final String? therapyType;
  
  @JsonKey(name: 'insulin_sensitivity')
  final double? insulinSensitivity;
  
  @JsonKey(name: 'carb_ratio')
  final double? carbRatio;
  
  @JsonKey(name: 'target_glucose')
  final int? targetGlucose;
  
  @JsonKey(name: 'basal_insulin_type')
  final String? basalInsulinType;
  
  @JsonKey(name: 'basal_insulin_units')
  final double? basalInsulinUnits;
  
  @JsonKey(name: 'basal_insulin_time')
  final String? basalInsulinTime;

  HealthProfileUpdate({
    this.diabetesType,
    this.therapyType,
    this.insulinSensitivity,
    this.carbRatio,
    this.targetGlucose,
    this.basalInsulinType,
    this.basalInsulinUnits,
    this.basalInsulinTime,
  });

  factory HealthProfileUpdate.fromJson(Map<String, dynamic> json) =>
      _$HealthProfileUpdateFromJson(json);

  Map<String, dynamic> toJson() => _$HealthProfileUpdateToJson(this);
}

/// Password change request
@JsonSerializable()
class PasswordChangeRequest {
  @JsonKey(name: 'old_password')
  final String oldPassword;
  @JsonKey(name: 'new_password')
  final String newPassword;
  @JsonKey(name: 'confirm_password')
  final String confirmPassword;

  PasswordChangeRequest({
    required this.oldPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  factory PasswordChangeRequest.fromJson(Map<String, dynamic> json) =>
      _$PasswordChangeRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PasswordChangeRequestToJson(this);
}
