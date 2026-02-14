import 'package:json_annotation/json_annotation.dart';

part 'auth_models.g.dart';

// ==========================================
// LOGIN REQUEST
// ==========================================

@JsonSerializable()
class LoginRequest {
  final String username; // Email según swagger
  final String password;

  const LoginRequest({
    required this.username,
    required this.password,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

// ==========================================
// LOGIN RESPONSE
// ==========================================

@JsonSerializable()
class LoginResponse {
  @JsonKey(name: 'access_token')
  final String accessToken;
  
  @JsonKey(name: 'token_type')
  final String tokenType;

  const LoginResponse({
    required this.accessToken,
    required this.tokenType,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

// ==========================================
// USER REGISTRATION
// ==========================================

@JsonSerializable()
class UserCreateRequest {
  final String email;
  final String password;
  
  @JsonKey(name: 'full_name')
  final String? fullName;
  
  @JsonKey(name: 'health_profile')
  final HealthProfileCreate healthProfile;

  const UserCreateRequest({
    required this.email,
    required this.password,
    this.fullName,
    required this.healthProfile,
  });

  factory UserCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$UserCreateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UserCreateRequestToJson(this);
}

@JsonSerializable()
class HealthProfileCreate {
  @JsonKey(name: 'diabetes_type')
  final String diabetesType;
  
  @JsonKey(name: 'therapy_type')
  final String? therapyType;
  
  @JsonKey(name: 'insulin_sensitivity')
  final double? insulinSensitivity;
  
  @JsonKey(name: 'carb_ratio')
  final double? carbRatio;
  
  @JsonKey(name: 'target_glucose')
  final int? targetGlucose;
  
  @JsonKey(name: 'target_range_low')
  final int? targetRangeLow;
  
  @JsonKey(name: 'target_range_high')
  final int? targetRangeHigh;
  
  @JsonKey(name: 'basal_insulin')
  final BasalInsulinInfo? basalInsulin;

  const HealthProfileCreate({
    required this.diabetesType,
    this.therapyType,
    this.insulinSensitivity,
    this.carbRatio,
    this.targetGlucose,
    this.targetRangeLow,
    this.targetRangeHigh,
    this.basalInsulin,
  });

  factory HealthProfileCreate.fromJson(Map<String, dynamic> json) =>
      _$HealthProfileCreateFromJson(json);

  Map<String, dynamic> toJson() => _$HealthProfileCreateToJson(this);
}

// ==========================================
// USER PUBLIC RESPONSE
// ==========================================

@JsonSerializable()
class UserPublicResponse {
  final String id;
  final String email;
  
  @JsonKey(name: 'full_name')
  final String? fullName;
  
  @JsonKey(name: 'is_active')
  final bool isActive;
  
  @JsonKey(name: 'health_profile')
  final HealthProfile? healthProfile;

  const UserPublicResponse({
    required this.id,
    required this.email,
    this.fullName,
    required this.isActive,
    this.healthProfile,
  });

  factory UserPublicResponse.fromJson(Map<String, dynamic> json) =>
      _$UserPublicResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserPublicResponseToJson(this);
}

@JsonSerializable()
class HealthProfile {
  @JsonKey(name: 'user_id')
  final String userId;
  
  @JsonKey(name: 'diabetes_type')
  final String diabetesType;
  
  @JsonKey(name: 'therapy_type')
  final String? therapyType;
  
  @JsonKey(name: 'insulin_sensitivity')
  final double? insulinSensitivity;
  
  @JsonKey(name: 'carb_ratio')
  final double? carbRatio;
  
  @JsonKey(name: 'target_glucose')
  final int? targetGlucose;
  
  @JsonKey(name: 'target_range_low')
  final int? targetRangeLow;
  
  @JsonKey(name: 'target_range_high')
  final int? targetRangeHigh;
  
  @JsonKey(name: 'basal_insulin')
  final BasalInsulinInfo? basalInsulin;

  const HealthProfile({
    required this.userId,
    required this.diabetesType,
    this.therapyType,
    this.insulinSensitivity,
    this.carbRatio,
    this.targetGlucose,
    this.targetRangeLow,
    this.targetRangeHigh,
    this.basalInsulin,
  });

  factory HealthProfile.fromJson(Map<String, dynamic> json) =>
      _$HealthProfileFromJson(json);

  Map<String, dynamic> toJson() => _$HealthProfileToJson(this);
}

// ==========================================
// BASAL INSULIN INFO
// ==========================================

@JsonSerializable()
class BasalInsulinInfo {
  final String? type;
  final double? units;
  
  @JsonKey(name: 'administration_time')
  final String? administrationTime;

  const BasalInsulinInfo({
    this.type,
    this.units,
    this.administrationTime,
  });

  factory BasalInsulinInfo.fromJson(Map<String, dynamic> json) =>
      _$BasalInsulinInfoFromJson(json);

  Map<String, dynamic> toJson() => _$BasalInsulinInfoToJson(this);
}
