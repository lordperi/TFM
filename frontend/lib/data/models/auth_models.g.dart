// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) => LoginRequest(
      username: json['username'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
    };

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    LoginResponse(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
    );

Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'token_type': instance.tokenType,
    };

UserCreateRequest _$UserCreateRequestFromJson(Map<String, dynamic> json) =>
    UserCreateRequest(
      email: json['email'] as String,
      password: json['password'] as String,
      fullName: json['full_name'] as String?,
      healthProfile: HealthProfileCreate.fromJson(
          json['health_profile'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserCreateRequestToJson(UserCreateRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'full_name': instance.fullName,
      'health_profile': instance.healthProfile,
    };

HealthProfileCreate _$HealthProfileCreateFromJson(Map<String, dynamic> json) =>
    HealthProfileCreate(
      diabetesType: json['diabetes_type'] as String,
      insulinSensitivity: (json['insulin_sensitivity'] as num).toDouble(),
      carbRatio: (json['carb_ratio'] as num).toDouble(),
      targetGlucose: (json['target_glucose'] as num?)?.toInt() ?? 100,
    );

Map<String, dynamic> _$HealthProfileCreateToJson(
        HealthProfileCreate instance) =>
    <String, dynamic>{
      'diabetes_type': instance.diabetesType,
      'insulin_sensitivity': instance.insulinSensitivity,
      'carb_ratio': instance.carbRatio,
      'target_glucose': instance.targetGlucose,
    };

UserPublicResponse _$UserPublicResponseFromJson(Map<String, dynamic> json) =>
    UserPublicResponse(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      isActive: json['is_active'] as bool,
      healthProfile: json['health_profile'] == null
          ? null
          : HealthProfile.fromJson(
              json['health_profile'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserPublicResponseToJson(UserPublicResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'full_name': instance.fullName,
      'is_active': instance.isActive,
      'health_profile': instance.healthProfile,
    };

HealthProfile _$HealthProfileFromJson(Map<String, dynamic> json) =>
    HealthProfile(
      userId: json['user_id'] as String,
      diabetesType: json['diabetes_type'] as String,
      insulinSensitivity: (json['insulin_sensitivity'] as num).toDouble(),
      carbRatio: (json['carb_ratio'] as num).toDouble(),
      targetGlucose: (json['target_glucose'] as num).toInt(),
    );

Map<String, dynamic> _$HealthProfileToJson(HealthProfile instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'diabetes_type': instance.diabetesType,
      'insulin_sensitivity': instance.insulinSensitivity,
      'carb_ratio': instance.carbRatio,
      'target_glucose': instance.targetGlucose,
    };
