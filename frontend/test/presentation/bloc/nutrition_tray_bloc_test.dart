import 'package:bloc_test/bloc_test.dart';
import 'package:diabeaty_mobile/data/datasources/nutrition_api_client.dart';
import 'package:diabeaty_mobile/data/models/nutrition_models.dart';
import 'package:diabeaty_mobile/presentation/bloc/nutrition/nutrition_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockNutritionApiClient extends Mock implements NutritionApiClient {}
class FakeBolusCalculationRequest extends Fake implements BolusCalculationRequest {}

// ── Datos de test ──────────────────────────────────────────────────────────
final _arroz = Ingredient(id: 1, name: 'Arroz', glycemicIndex: 70, carbs: 28.0);
final _manzana = Ingredient(id: 2, name: 'Manzana', glycemicIndex: 38, carbs: 14.0);

final _bolusResponse = BolusCalculationResponse(
  totalCarbsGrams: 52.0,
  recommendedBolusUnits: 4.5,
);

void main() {
  late MockNutritionApiClient mockApi;

  setUpAll(() {
    registerFallbackValue(FakeBolusCalculationRequest());
  });

  setUp(() {
    mockApi = MockNutritionApiClient();
  });

  group('NutritionBloc — bandeja multi-ingrediente', () {
    blocTest<NutritionBloc, NutritionState>(
      'AddIngredientToTray emite MealTrayUpdated con el ingrediente añadido',
      build: () => NutritionBloc(apiClient: mockApi),
      act: (bloc) => bloc.add(AddIngredientToTray(_arroz, 150)),
      expect: () => [
        isA<MealTrayUpdated>()
            .having((s) => s.tray.length, 'tray.length', 1)
            .having((s) => s.tray.first.ingredient.name, 'nombre', 'Arroz')
            .having((s) => s.tray.first.grams, 'gramos', 150.0),
      ],
    );

    blocTest<NutritionBloc, NutritionState>(
      'AddIngredientToTray múltiples veces acumula los ingredientes',
      build: () => NutritionBloc(apiClient: mockApi),
      act: (bloc) {
        bloc.add(AddIngredientToTray(_arroz, 150));
        bloc.add(AddIngredientToTray(_manzana, 120));
      },
      expect: () => [
        isA<MealTrayUpdated>().having((s) => s.tray.length, 'tray.length', 1),
        isA<MealTrayUpdated>().having((s) => s.tray.length, 'tray.length', 2),
      ],
    );

    blocTest<NutritionBloc, NutritionState>(
      'RemoveIngredientFromTray elimina el ítem en el índice indicado',
      build: () => NutritionBloc(apiClient: mockApi),
      seed: () => MealTrayUpdated(
        tray: [TrayItem(_arroz, 150), TrayItem(_manzana, 120)],
        searchResults: [],
      ),
      act: (bloc) => bloc.add(const RemoveIngredientFromTray(0)),
      expect: () => [
        isA<MealTrayUpdated>()
            .having((s) => s.tray.length, 'tray.length', 1)
            .having((s) => s.tray.first.ingredient.name, 'nombre', 'Manzana'),
      ],
    );

    blocTest<NutritionBloc, NutritionState>(
      'CalculateBolusForTray llama a la API con todos los ingredientes de la bandeja',
      build: () {
        when(() => mockApi.calculateBolus(any())).thenAnswer((_) async => _bolusResponse);
        return NutritionBloc(apiClient: mockApi);
      },
      seed: () => MealTrayUpdated(
        tray: [TrayItem(_arroz, 150), TrayItem(_manzana, 120)],
        searchResults: [],
      ),
      act: (bloc) => bloc.add(const CalculateBolusForTray(
        currentGlucose: 120,
        icr: 10.0,
        isf: 50.0,
        targetGlucose: 100.0,
      )),
      expect: () => [
        isA<NutritionLoading>(),
        isA<TrayBolusCalculated>()
            .having((s) => s.result.recommendedBolusUnits, 'bolus', 4.5)
            .having((s) => s.tray.length, 'tray.length', 2),
      ],
      verify: (_) {
        // La request debe incluir AMBOS ingredientes
        final captured = verify(() => mockApi.calculateBolus(captureAny())).captured;
        final req = captured.first as BolusCalculationRequest;
        expect(req.ingredients.length, 2);
      },
    );

    blocTest<NutritionBloc, NutritionState>(
      'TrayItem calcula correctamente los carbohidratos según los gramos',
      build: () => NutritionBloc(apiClient: mockApi),
      act: (bloc) => bloc.add(AddIngredientToTray(_arroz, 200)), // 200g de arroz a 28g CHO/100g
      verify: (bloc) {
        final state = bloc.state as MealTrayUpdated;
        // 200g * 28 / 100 = 56g de CHO
        expect(state.tray.first.carbs, closeTo(56.0, 0.01));
      },
    );

    blocTest<NutritionBloc, NutritionState>(
      'ClearTray vuelve a NutritionInitial',
      build: () => NutritionBloc(apiClient: mockApi),
      seed: () => MealTrayUpdated(
        tray: [TrayItem(_arroz, 150)],
        searchResults: [],
      ),
      act: (bloc) => bloc.add(ClearTray()),
      expect: () => [isA<NutritionInitial>()],
    );
  });
}
