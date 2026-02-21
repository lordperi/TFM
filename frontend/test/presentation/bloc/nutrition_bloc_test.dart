import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:diabeaty_mobile/data/datasources/nutrition_api_client.dart';
import 'package:diabeaty_mobile/data/models/nutrition_models.dart';
import 'package:diabeaty_mobile/presentation/bloc/nutrition/nutrition_bloc.dart';

// ---------------------------------------------------------------------------
// Mock
// ---------------------------------------------------------------------------

class MockNutritionApiClient extends Mock implements NutritionApiClient {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

MealLogEntry _fakeMeal({double? bolus}) => MealLogEntry(
      id: 'meal-1',
      patientId: 'patient-1',
      totalCarbsGrams: 60.0,
      totalGlycemicLoad: 20.0,
      bolusUnitsAdministered: bolus,
      timestamp: '2026-02-21T12:00:00',
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockNutritionApiClient mockClient;

  setUp(() {
    mockClient = MockNutritionApiClient();
  });

  group('NutritionBloc — LoadMealHistory', () {
    blocTest<NutritionBloc, NutritionState>(
      'emits [NutritionLoading, MealHistoryLoaded] when API returns meals',
      build: () {
        when(
          () => mockClient.getMealHistory(
            'patient-1',
            limit: 20,
            offset: 0,
          ),
        ).thenAnswer((_) async => [
              _fakeMeal(bolus: 3.5),
              _fakeMeal(bolus: 1.0),
            ]);
        return NutritionBloc(apiClient: mockClient);
      },
      act: (bloc) =>
          bloc.add(const LoadMealHistory('patient-1', limit: 20, offset: 0)),
      expect: () => [
        isA<NutritionLoading>(),
        isA<MealHistoryLoaded>().having(
          (s) => s.meals.length,
          'meals count',
          2,
        ),
      ],
    );

    blocTest<NutritionBloc, NutritionState>(
      'emits [NutritionLoading, MealHistoryLoaded] with empty list when no meals',
      build: () {
        when(
          () => mockClient.getMealHistory(
            'patient-1',
            limit: 20,
            offset: 0,
          ),
        ).thenAnswer((_) async => []);
        return NutritionBloc(apiClient: mockClient);
      },
      act: (bloc) =>
          bloc.add(const LoadMealHistory('patient-1')),
      expect: () => [
        isA<NutritionLoading>(),
        isA<MealHistoryLoaded>().having(
          (s) => s.meals,
          'empty meals',
          isEmpty,
        ),
      ],
    );

    blocTest<NutritionBloc, NutritionState>(
      'emits [NutritionLoading, NutritionError] when API throws',
      build: () {
        when(
          () => mockClient.getMealHistory(
            any(),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenThrow(Exception('network error'));
        return NutritionBloc(apiClient: mockClient);
      },
      act: (bloc) => bloc.add(const LoadMealHistory('patient-1')),
      expect: () => [
        isA<NutritionLoading>(),
        isA<NutritionError>(),
      ],
    );

    test('MealHistoryLoaded holds meals with bolusUnitsAdministered', () {
      final meal = _fakeMeal(bolus: 4.2);
      final state = MealHistoryLoaded([meal]);
      expect(state.meals.first.bolusUnitsAdministered, 4.2);
    });

    test('MealLogEntry.parsedTimestamp parses ISO timestamp correctly', () {
      final meal = _fakeMeal(bolus: 1.0);
      expect(meal.parsedTimestamp, isA<DateTime>());
      expect(meal.parsedTimestamp!.year, 2026);
    });
  });
}
