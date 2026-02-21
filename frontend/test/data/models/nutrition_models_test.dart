import 'package:flutter_test/flutter_test.dart';
import 'package:diabeaty_mobile/data/models/nutrition_models.dart';

void main() {
  group('Nutrition Models JSON Serialization', () {
    test('BolusCalculationRequest serialization', () {
      final request = BolusCalculationRequest(
        currentGlucose: 190.0,
        targetGlucose: 100.0,
        ingredients: [
          IngredientInput(ingredientId: "uid-1234", weightGrams: 50.0),
        ],
        icr: 10.0,
        isf: 50.0,
      );

      final jsonMap = request.toJson();
      
      expect(jsonMap['current_glucose'], 190.0);
      expect(jsonMap['target_glucose'], 100.0);
      expect(jsonMap['icr'], 10.0);
      expect(jsonMap['isf'], 50.0);
      expect((jsonMap['ingredients'] as List).length, 1);
      expect(jsonMap['ingredients'][0]['ingredient_id'], "uid-1234");
      expect(jsonMap['ingredients'][0]['weight_grams'], 50.0);
    });

    test('BolusCalculationResponse deserialization', () {
      final jsonResponse = {
        "total_carbs_grams": 45.0,
        "recommended_bolus_units": 6.3
      };

      final response = BolusCalculationResponse.fromJson(jsonResponse);
      
      expect(response.totalCarbsGrams, 45.0);
      expect(response.recommendedBolusUnits, 6.3);
    });
  });
}
