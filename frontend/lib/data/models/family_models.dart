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
  final String? therapyType; // Renamed
  final double? insulinSensitivity;
  final double? carbRatio;
  final double? targetGlucose;
  final int? targetRangeLow;
  final int? targetRangeHigh;
  // Basal Insulin
  final String? basalInsulinType;
  final double? basalInsulinUnits;
  final String? basalInsulinTime;

  PatientProfile({
    required this.id,
    required this.displayName,
    required this.themePreference,
    this.loginCode,
    required this.role,
    required this.isProtected,
    this.birthDate,
    this.diabetesType,
    this.therapyType,
    this.insulinSensitivity,
    this.carbRatio,
    this.targetGlucose,
    this.targetRangeLow,
    this.targetRangeHigh,
    this.basalInsulinType,
    this.basalInsulinUnits,
    this.basalInsulinTime,
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
      therapyType: json['therapy_type'],
      insulinSensitivity: json['insulin_sensitivity'] != null ? (json['insulin_sensitivity'] as num).toDouble() : null,
      carbRatio: json['carb_ratio'] != null ? (json['carb_ratio'] as num).toDouble() : null,
      targetGlucose: json['target_glucose'] != null ? (json['target_glucose'] as num).toDouble() : null,
      targetRangeLow: json['target_range_low'] as int?,
      targetRangeHigh: json['target_range_high'] as int?,
      basalInsulinType: json['basal_insulin_type'],
      basalInsulinUnits: json['basal_insulin_units'] != null ? (json['basal_insulin_units'] as num).toDouble() : null,
      basalInsulinTime: json['basal_insulin_time'],
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
  final String therapyType; // Renamed from therapyMode
  final String insulinSensitivity; 
  final String carbRatio;
  final String targetGlucose;
  final int? targetRangeLow;
  final int? targetRangeHigh;

  // Basal Insulin
  final String? basalInsulinType;
  final String? basalInsulinUnits;
  final String? basalInsulinTime;

  CreatePatientRequest({
     required this.displayName,
     this.themePreference = 'child',
     this.role = 'DEPENDENT',
     this.birthDate,
     this.pin,
     required this.diabetesType,
     this.therapyType = 'PEN',
     required this.insulinSensitivity,
     required this.carbRatio,
     required this.targetGlucose,
     this.targetRangeLow,
     this.targetRangeHigh,
     this.basalInsulinType,
     this.basalInsulinUnits,
     this.basalInsulinTime,
  });

  Map<String, dynamic> toJson() => {
    'display_name': displayName,
    'theme_preference': themePreference,
    'role': role,
    'birth_date': birthDate,
    'pin': pin,
    'diabetes_type': diabetesType,
    'therapy_type': therapyType,
    'insulin_sensitivity': double.tryParse(insulinSensitivity) ?? 0.0,
    'carb_ratio': double.tryParse(carbRatio) ?? 0.0,
    'target_glucose': double.tryParse(targetGlucose) ?? 0.0,
    'target_range_low': targetRangeLow,
    'target_range_high': targetRangeHigh,
    'basal_insulin_type': basalInsulinType,
    'basal_insulin_units': basalInsulinUnits != null ? double.tryParse(basalInsulinUnits!) : null,
    'basal_insulin_time': basalInsulinTime,
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
  final String? therapyType;
  final String? insulinSensitivity;
  final String? carbRatio;
  final String? targetGlucose;
  final int? targetRangeLow;
  final int? targetRangeHigh;
  
  final String? basalInsulinType;
  final String? basalInsulinUnits;
  final String? basalInsulinTime;

  PatientUpdateRequest({
     this.displayName,
     this.themePreference,
     this.role,
     this.birthDate,
     this.pin,
     this.diabetesType,
     this.therapyType,
     this.insulinSensitivity,
     this.carbRatio,
     this.targetGlucose,
     this.targetRangeLow,
     this.targetRangeHigh,
     this.basalInsulinType,
     this.basalInsulinUnits,
     this.basalInsulinTime,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (displayName != null) data['display_name'] = displayName;
    if (themePreference != null) data['theme_preference'] = themePreference;
    if (role != null) data['role'] = role;
    if (birthDate != null) data['birth_date'] = birthDate;
    if (pin != null) data['pin'] = pin;
    if (diabetesType != null) data['diabetes_type'] = diabetesType;
    if (therapyType != null) data['therapy_type'] = therapyType;
    if (insulinSensitivity != null) data['insulin_sensitivity'] = double.tryParse(insulinSensitivity!);
    if (carbRatio != null) data['carb_ratio'] = double.tryParse(carbRatio!);
    if (targetGlucose != null) data['target_glucose'] = double.tryParse(targetGlucose!);
    if (targetRangeLow != null) data['target_range_low'] = targetRangeLow;
    if (targetRangeHigh != null) data['target_range_high'] = targetRangeHigh;
    
    if (basalInsulinType != null) data['basal_insulin_type'] = basalInsulinType;
    if (basalInsulinUnits != null) data['basal_insulin_units'] = double.tryParse(basalInsulinUnits!);
    if (basalInsulinTime != null) data['basal_insulin_time'] = basalInsulinTime;
    
    return data;
  }
}
