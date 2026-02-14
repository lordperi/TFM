enum TherapyType {
  insulin('INSULIN', 'Insulina Inyectable'),
  oral('ORAL_MEDICATION', 'Medicación Oral'),
  mixed('MIXED', 'Mixto (Insulina + Oral)'),
  none('NONE', 'Sin tratamiento');

  const TherapyType(this.value, this.displayName);
  
  final String value;
  final String displayName;
  
  static TherapyType fromString(String value) {
    return TherapyType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TherapyType.none,
    );
  }
  
  /// Returns true if this therapy type requires insulin fields (ISF, ICR, Target)
  bool requiresInsulinFields() {
    return this == TherapyType.insulin || this == TherapyType.mixed;
  }
}
