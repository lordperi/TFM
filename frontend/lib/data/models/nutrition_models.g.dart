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

IngredientInput _$IngredientInputFromJson(Map<String, dynamic> json) =>
    IngredientInput(
      ingredientId: json['ingredient_id'] as String,
      weightGrams: (json['weight_grams'] as num).toDouble(),
    );

Map<String, dynamic> _$IngredientInputToJson(IngredientInput instance) =>
    <String, dynamic>{
      'ingredient_id': instance.ingredientId,
      'weight_grams': instance.weightGrams,
    };

BolusCalculationRequest _$BolusCalculationRequestFromJson(
        Map<String, dynamic> json) =>
    BolusCalculationRequest(
      currentGlucose: (json['current_glucose'] as num).toDouble(),
      targetGlucose: (json['target_glucose'] as num).toDouble(),
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((e) => IngredientInput.fromJson(e as Map<String, dynamic>))
          .toList(),
      icr: (json['icr'] as num?)?.toDouble() ?? 10.0,
      isf: (json['isf'] as num?)?.toDouble() ?? 50.0,
    );

Map<String, dynamic> _$BolusCalculationRequestToJson(
        BolusCalculationRequest instance) =>
    <String, dynamic>{
      'current_glucose': instance.currentGlucose,
      'target_glucose': instance.targetGlucose,
      'ingredients': instance.ingredients.map((e) => e.toJson()).toList(),
      'icr': instance.icr,
      'isf': instance.isf,
    };

BolusCalculationResponse _$BolusCalculationResponseFromJson(
        Map<String, dynamic> json) =>
    BolusCalculationResponse(
      totalCarbsGrams: (json['total_carbs_grams'] as num).toDouble(),
      recommendedBolusUnits:
          (json['recommended_bolus_units'] as num).toDouble(),
      reason: json['reason'] as String? ?? '',
    );

Map<String, dynamic> _$BolusCalculationResponseToJson(
        BolusCalculationResponse instance) =>
    <String, dynamic>{
      'total_carbs_grams': instance.totalCarbsGrams,
      'recommended_bolus_units': instance.recommendedBolusUnits,
      'reason': instance.reason,
    };
