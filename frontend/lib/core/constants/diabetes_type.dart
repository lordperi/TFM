enum DiabetesType {
  none('NONE', 'Sin diabetes'),
  type1('T1', 'Diabetes Tipo 1'),
  type2('T2', 'Diabetes Tipo 2');

  const DiabetesType(this.value, this.displayName);
  
  final String value;
  final String displayName;
  
  static DiabetesType fromString(String value) {
    return DiabetesType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => DiabetesType.none,
    );
  }
}
