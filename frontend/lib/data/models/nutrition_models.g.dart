// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ingredient _$IngredientFromJson(Map<String, dynamic> json) => Ingredient(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      glycemicIndex: (json['glycemic_index'] as num).toInt(),
      carbs: (json['carbs'] as num).toDouble(),
    );

Map<String, dynamic> _$IngredientToJson(Ingredient instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'glycemic_index': instance.glycemicIndex,
      'carbs': instance.carbs,
    };

BolusCalculationRequest _$BolusCalculationRequestFromJson(
        Map<String, dynamic> json) =>
    BolusCalculationRequest(
      glucoseValue: (json['glucose_value'] as num).toInt(),
      carbsGrams: (json['carbs_grams'] as num).toInt(),
      mealType: json['meal_type'] as String? ?? 'snack',
    );

Map<String, dynamic> _$BolusCalculationRequestToJson(
        BolusCalculationRequest instance) =>
    <String, dynamic>{
      'glucose_value': instance.glucoseValue,
      'carbs_grams': instance.carbsGrams,
      'meal_type': instance.mealType,
    };

BolusCalculationResponse _$BolusCalculationResponseFromJson(
        Map<String, dynamic> json) =>
    BolusCalculationResponse(
      totalBolus: (json['total_bolus'] as num).toDouble(),
      correctionBolus: (json['correction_bolus'] as num).toDouble(),
      mealBolus: (json['meal_bolus'] as num).toDouble(),
      reason: json['reason'] as String,
    );

Map<String, dynamic> _$BolusCalculationResponseToJson(
        BolusCalculationResponse instance) =>
    <String, dynamic>{
      'total_bolus': instance.totalBolus,
      'correction_bolus': instance.correctionBolus,
      'meal_bolus': instance.mealBolus,
      'reason': instance.reason,
    };
