class PatientProfile {
  final String id;
  final String displayName;
  final String themePreference; // 'child' | 'adult'
  final String? loginCode;
  final String role; // 'GUARDIAN', 'DEPENDENT'
  final bool isProtected; // True if PIN is set
  
  // Detailed fields (optional, loaded on demand)
  final String? birthDate;
  final String? diabetesType;
  final String? therapyMode;
  final double? insulinSensitivity;
  final double? carbRatio;
  final double? targetGlucose;

  PatientProfile({
    required this.id,
    required this.displayName,
    required this.themePreference,
    this.loginCode,
    required this.role,
    required this.isProtected,
    this.birthDate,
    this.diabetesType,
    this.therapyMode,
    this.insulinSensitivity,
    this.carbRatio,
    this.targetGlucose,
  });

  factory PatientProfile.fromJson(Map<String, dynamic> json) {
    return PatientProfile(
      id: json['id'],
      displayName: json['display_name'],
      themePreference: json['theme_preference'],
      loginCode: json['login_code'],
      role: json['role'] ?? 'DEPENDENT',
      isProtected: json['is_protected'] ?? false,
      birthDate: json['birth_date'],
      diabetesType: json['diabetes_type'],
      therapyMode: json['therapy_mode'],
      insulinSensitivity: json['insulin_sensitivity'] != null ? (json['insulin_sensitivity'] as num).toDouble() : null,
      carbRatio: json['carb_ratio'] != null ? (json['carb_ratio'] as num).toDouble() : null,
      targetGlucose: json['target_glucose'] != null ? (json['target_glucose'] as num).toDouble() : null,
    );
  }
  
  bool get isChild => themePreference == 'child';
  bool get isGuardian => role == 'GUARDIAN';
}

class CreatePatientRequest {
  final String displayName;
  final String themePreference;
  final String role;
  final String? birthDate;
  final String? pin;
  
  // Health Data
  final String diabetesType;
  final String therapyMode; // 'PEN', 'PUMP'
  final String insulinSensitivity; // string for MVP/Controller
  final String carbRatio;
  final String targetGlucose;

  CreatePatientRequest({
     required this.displayName,
     this.themePreference = 'child',
     this.role = 'DEPENDENT',
     this.birthDate,
     this.pin,
     required this.diabetesType,
     this.therapyMode = 'PEN',
     required this.insulinSensitivity,
     required this.carbRatio,
     required this.targetGlucose,
  });

  Map<String, dynamic> toJson() => {
    'display_name': displayName,
    'theme_preference': themePreference,
    'role': role,
    'birth_date': birthDate,
    'pin': pin,
    'diabetes_type': diabetesType,
    'therapy_mode': therapyMode,
    'insulin_sensitivity': double.tryParse(insulinSensitivity) ?? 0.0, // Convert to number for API
    'carb_ratio': double.tryParse(carbRatio) ?? 0.0,
    'target_glucose': double.tryParse(targetGlucose) ?? 0.0,
  };
}

class PatientUpdateRequest {
  final String? displayName;
  final String? themePreference;
  final String? role;
  final String? birthDate;
  final String? pin;
  
  // Health Data
  final String? diabetesType;
  final String? therapyMode;
  final String? insulinSensitivity;
  final String? carbRatio;
  final String? targetGlucose;

  PatientUpdateRequest({
     this.displayName,
     this.themePreference,
     this.role,
     this.birthDate,
     this.pin,
     this.diabetesType,
     this.therapyMode,
     this.insulinSensitivity,
     this.carbRatio,
     this.targetGlucose,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (displayName != null) data['display_name'] = displayName;
    if (themePreference != null) data['theme_preference'] = themePreference;
    if (role != null) data['role'] = role;
    if (birthDate != null) data['birth_date'] = birthDate;
    if (pin != null) data['pin'] = pin;
    if (diabetesType != null) data['diabetes_type'] = diabetesType;
    if (therapyMode != null) data['therapy_mode'] = therapyMode;
    if (insulinSensitivity != null) data['insulin_sensitivity'] = double.tryParse(insulinSensitivity!);
    if (carbRatio != null) data['carb_ratio'] = double.tryParse(carbRatio!);
    if (targetGlucose != null) data['target_glucose'] = double.tryParse(targetGlucose!);
    return data;
  }
}
