import 'package:json_annotation/json_annotation.dart';

part 'nutrition_models.g.dart';

// ==========================================
// INGREDIENTS
// ==========================================

@JsonSerializable()
class Ingredient {
  final int id;
  final String name;
  @JsonKey(name: 'glycemic_index')
  final int glycemicIndex;
  final double carbs; // Carbs per 100g

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
class BolusCalculationRequest {
  @JsonKey(name: 'glucose_value')
  final int glucoseValue;
  
  @JsonKey(name: 'carbs_grams')
  final int carbsGrams;
  
  @JsonKey(name: 'meal_type')
  final String mealType; // 'breakfast', 'lunch', 'dinner', 'snack'

  BolusCalculationRequest({
    required this.glucoseValue,
    required this.carbsGrams,
    this.mealType = 'snack', // Default, simple logic for now
  });

  Map<String, dynamic> toJson() => _$BolusCalculationRequestToJson(this);
}

@JsonSerializable()
class BolusCalculationResponse {
  @JsonKey(name: 'total_bolus')
  final double totalBolus;
  
  @JsonKey(name: 'correction_bolus')
  final double correctionBolus;
  
  @JsonKey(name: 'meal_bolus')
  final double mealBolus;
  
  final String reason;

  BolusCalculationResponse({
    required this.totalBolus,
    required this.correctionBolus,
    required this.mealBolus,
    required this.reason,
  });

  factory BolusCalculationResponse.fromJson(Map<String, dynamic> json) => 
      _$BolusCalculationResponseFromJson(json);
}
