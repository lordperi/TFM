import 'package:json_annotation/json_annotation.dart';

part 'nutrition_models.g.dart';

// ==========================================
// INGREDIENTS
// ==========================================

@JsonSerializable()
class Ingredient {
  final String id; // UUID string — el backend devuelve UUID como string
  final String name;
  @JsonKey(name: 'glycemic_index')
  final int glycemicIndex;
  final double carbs; // Carbs per 100g (campo 'carbs' en la API)

  Ingredient({
    required this.id,
    required this.name,
    required this.glycemicIndex,
    required this.carbs,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) => _$IngredientFromJson(json);
  Map<String, dynamic> toJson() => _$IngredientToJson(this);
}

// ==========================================
// BOLUS CALCULATION
// ==========================================

@JsonSerializable()
class IngredientInput {
  @JsonKey(name: 'ingredient_id')
  final String ingredientId;
  
  @JsonKey(name: 'weight_grams')
  final double weightGrams;

  IngredientInput({
    required this.ingredientId,
    required this.weightGrams,
  });

  factory IngredientInput.fromJson(Map<String, dynamic> json) => _$IngredientInputFromJson(json);
  Map<String, dynamic> toJson() => _$IngredientInputToJson(this);
}

@JsonSerializable(explicitToJson: true)
class BolusCalculationRequest {
  @JsonKey(name: 'current_glucose')
  final double currentGlucose;
  
  @JsonKey(name: 'target_glucose')
  final double targetGlucose;
  
  final List<IngredientInput> ingredients;
  
  final double icr;
  final double isf;

  BolusCalculationRequest({
    required this.currentGlucose,
    required this.targetGlucose,
    required this.ingredients,
    this.icr = 10.0,
    this.isf = 50.0,
  });

  factory BolusCalculationRequest.fromJson(Map<String, dynamic> json) => _$BolusCalculationRequestFromJson(json);
  Map<String, dynamic> toJson() => _$BolusCalculationRequestToJson(this);
}

@JsonSerializable()
class BolusCalculationResponse {
  @JsonKey(name: 'total_carbs_grams')
  final double totalCarbsGrams;
  
  @JsonKey(name: 'recommended_bolus_units')
  final double recommendedBolusUnits;
  
  // Keep these if frontend really needs them, but backend doesn't send them currently
  @JsonKey(name: 'reason', defaultValue: '')
  final String reason;

  BolusCalculationResponse({
    required this.totalCarbsGrams,
    required this.recommendedBolusUnits,
    this.reason = '',
  });

  factory BolusCalculationResponse.fromJson(Map<String, dynamic> json) =>
      _$BolusCalculationResponseFromJson(json);
}

// ==========================================
// MEAL LOG HISTORY
// ==========================================

@JsonSerializable()
class MealLogEntry {
  final String id;

  @JsonKey(name: 'patient_id')
  final String patientId;

  @JsonKey(name: 'total_carbs_grams')
  final double totalCarbsGrams;

  @JsonKey(name: 'total_glycemic_load')
  final double totalGlycemicLoad;

  @JsonKey(name: 'bolus_units_administered')
  final double? bolusUnitsAdministered;

  final String? timestamp;

  MealLogEntry({
    required this.id,
    required this.patientId,
    required this.totalCarbsGrams,
    required this.totalGlycemicLoad,
    this.bolusUnitsAdministered,
    this.timestamp,
  });

  DateTime? get parsedTimestamp =>
      timestamp != null ? DateTime.tryParse(timestamp!) : null;

  factory MealLogEntry.fromJson(Map<String, dynamic> json) =>
      _$MealLogEntryFromJson(json);
  Map<String, dynamic> toJson() => _$MealLogEntryToJson(this);
}

// ==========================================
// MEAL TRAY (multi-ingrediente, solo UI)
// ==========================================

/// Representa un ingrediente con su cantidad dentro de la bandeja activa.
/// No necesita serialización JSON — es estado efímero de UI/BLoC.
class TrayItem {
  final Ingredient ingredient;
  final double grams;

  const TrayItem(this.ingredient, this.grams);

  /// Carbohidratos netos según los gramos indicados
  double get carbs => (ingredient.carbs * grams) / 100;

  /// Carga glucémica = (IG × CHO) / 100
  double get glycemicLoad => (ingredient.glycemicIndex * carbs) / 100;

  @override
  bool operator ==(Object other) =>
      other is TrayItem &&
      other.ingredient.id == ingredient.id &&
      other.grams == grams;

  @override
  int get hashCode => Object.hash(ingredient.id, grams);
}
