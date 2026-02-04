class PatientProfile {
  final String id;
  final String displayName;
  final String themePreference; // 'child' | 'adult'
  final String? loginCode;

  PatientProfile({
    required this.id,
    required this.displayName,
    required this.themePreference,
    this.loginCode,
  });

  factory PatientProfile.fromJson(Map<String, dynamic> json) {
    return PatientProfile(
      id: json['id'],
      displayName: json['display_name'],
      themePreference: json['theme_preference'],
      loginCode: json['login_code'],
    );
  }
  
  bool get isChild => themePreference == 'child';
}

class CreatePatientRequest {
  final String displayName;
  final String themePreference;
  final String diabetesType;
  final String insulinSensitivity;
  final String carbRatio;
  final String targetGlucose;

  CreatePatientRequest({
     required this.displayName,
     this.themePreference = 'child',
     required this.diabetesType,
     required this.insulinSensitivity,
     required this.carbRatio,
     required this.targetGlucose,
  });

  Map<String, dynamic> toJson() => {
    'display_name': displayName,
    'theme_preference': themePreference,
    'diabetes_type': diabetesType,
    'insulin_sensitivity': insulinSensitivity,
    'carb_ratio': carbRatio,
    'target_glucose': targetGlucose,
  };
}
