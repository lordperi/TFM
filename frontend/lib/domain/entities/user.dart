import 'package:equatable/equatable.dart';

// ==========================================
// USER ENTITY (Domain Model)
// ==========================================

class User extends Equatable {
  final String id;
  final String email;
  final String? fullName;
  final bool isActive;
  final UserHealthProfile? healthProfile;

  const User({
    required this.id,
    required this.email,
    this.fullName,
    required this.isActive,
    this.healthProfile,
  });

  @override
  List<Object?> get props => [id, email, fullName, isActive, healthProfile];
}

class UserHealthProfile extends Equatable {
  final String userId;
  final DiabetesType diabetesType;
  final double insulinSensitivity;
  final double carbRatio;
  final int targetGlucose;

  const UserHealthProfile({
    required this.userId,
    required this.diabetesType,
    required this.insulinSensitivity,
    required this.carbRatio,
    required this.targetGlucose,
  });

  @override
  List<Object?> get props => [
        userId,
        diabetesType,
        insulinSensitivity,
        carbRatio,
        targetGlucose,
      ];
}

enum DiabetesType {
  type1,
  type2,
  gestational,
  lada,
  mody;

  String toApiValue() {
    switch (this) {
      case DiabetesType.type1:
        return 'type_1';
      case DiabetesType.type2:
        return 'type_2';
      case DiabetesType.gestational:
        return 'gestational';
      case DiabetesType.lada:
        return 'lada';
      case DiabetesType.mody:
        return 'mody';
    }
  }

  static DiabetesType fromApiValue(String value) {
    switch (value) {
      case 'type_1':
        return DiabetesType.type1;
      case 'type_2':
        return DiabetesType.type2;
      case 'gestational':
        return DiabetesType.gestational;
      case 'lada':
        return DiabetesType.lada;
      case 'mody':
        return DiabetesType.mody;
      default:
        throw ArgumentError('Unknown diabetes type: $value');
    }
  }
}
