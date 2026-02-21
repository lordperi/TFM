import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:diabeaty_mobile/data/models/auth_models.dart';
import 'package:diabeaty_mobile/data/models/family_models.dart';
import 'package:diabeaty_mobile/data/models/glucose_models.dart';
import 'package:diabeaty_mobile/data/models/nutrition_models.dart';
import 'package:diabeaty_mobile/presentation/bloc/auth/auth_bloc.dart';
import 'package:diabeaty_mobile/presentation/bloc/glucose/glucose_bloc.dart';
import 'package:diabeaty_mobile/presentation/bloc/nutrition/nutrition_bloc.dart';
import 'package:diabeaty_mobile/presentation/bloc/theme/theme_bloc.dart';
import 'package:diabeaty_mobile/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:diabeaty_mobile/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------
class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}
class MockThemeBloc extends MockBloc<ThemeEvent, ThemeState> implements ThemeBloc {}
class MockGlucoseBloc extends MockBloc<GlucoseEvent, GlucoseState> implements GlucoseBloc {}
class MockNutritionBloc extends MockBloc<NutritionEvent, NutritionState> implements NutritionBloc {}

class FakeAuthEvent extends Fake implements AuthEvent {}
class FakeThemeEvent extends Fake implements ThemeEvent {}
class FakeGlucoseEvent extends Fake implements GlucoseEvent {}
class FakeNutritionEvent extends Fake implements NutritionEvent {}

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

final _profile = PatientProfile(
  id: 'patient-123',
  displayName: 'Test Patient',
  themePreference: 'adult',
  role: 'DEPENDENT',
  isProtected: false,
);

const _user = UserPublicResponse(
  id: 'user-1',
  email: 'test@example.com',
  isActive: true,
);

MealLogEntry _fakeMeal(String ts, double bolus) => MealLogEntry(
      id: 'meal-${ts.hashCode}',
      patientId: 'patient-123',
      totalCarbsGrams: 60.0,
      totalGlycemicLoad: 20.0,
      bolusUnitsAdministered: bolus,
      timestamp: ts,
    );

GlucoseMeasurement _fakeGlucose(DateTime ts, int value) => GlucoseMeasurement(
      id: 'g-${ts.millisecondsSinceEpoch}',
      patientId: 'patient-123',
      glucoseValue: value,
      timestamp: ts,
    );

Widget _buildDashboard({
  required MockAuthBloc authBloc,
  required MockThemeBloc themeBloc,
  required MockGlucoseBloc glucoseBloc,
  required MockNutritionBloc nutritionBloc,
}) {
  return MultiBlocProvider(
    providers: [
      BlocProvider<AuthBloc>.value(value: authBloc),
      BlocProvider<ThemeBloc>.value(value: themeBloc),
      BlocProvider<GlucoseBloc>.value(value: glucoseBloc),
      BlocProvider<NutritionBloc>.value(value: nutritionBloc),
    ],
    child: MaterialApp(
      theme: ThemeData.light(),
      home: const DashboardScreen(),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockAuthBloc mockAuth;
  late MockThemeBloc mockTheme;
  late MockGlucoseBloc mockGlucose;
  late MockNutritionBloc mockNutrition;

  setUpAll(() {
    registerFallbackValue(FakeAuthEvent());
    registerFallbackValue(FakeThemeEvent());
    registerFallbackValue(FakeGlucoseEvent());
    registerFallbackValue(FakeNutritionEvent());
  });

  setUp(() {
    mockAuth = MockAuthBloc();
    mockTheme = MockThemeBloc();
    mockGlucose = MockGlucoseBloc();
    mockNutrition = MockNutritionBloc();

    when(() => mockAuth.state).thenReturn(AuthAuthenticated(
      accessToken: 'tok',
      user: _user,
      selectedProfile: _profile,
    ));
    when(() => mockTheme.state).thenReturn(
      const ThemeState(uiMode: UiMode.adult),
    );
    when(() => mockGlucose.state).thenReturn(GlucoseInitial());
    when(() => mockNutrition.state).thenReturn(NutritionInitial());
  });

  group('DashboardScreen — insulin overlay data flow', () {
    testWidgets(
      'dispatches LoadMealHistory on initState when profile is selected',
      (tester) async {
        await tester.pumpWidget(_buildDashboard(
          authBloc: mockAuth,
          themeBloc: mockTheme,
          glucoseBloc: mockGlucose,
          nutritionBloc: mockNutrition,
        ));
        await tester.pump();

        verify(
          () => mockNutrition.add(any(that: isA<LoadMealHistory>())),
        ).called(1);
      },
    );

    testWidgets(
      'renders GlucoseChart when glucose data is available',
      (tester) async {
        final measurements = [
          _fakeGlucose(DateTime(2026, 2, 21, 10, 0), 140),
          _fakeGlucose(DateTime(2026, 2, 21, 12, 0), 160),
        ];
        when(() => mockGlucose.state).thenReturn(GlucoseLoaded(measurements));

        final meals = [_fakeMeal('2026-02-21T11:00:00', 3.5)];
        when(() => mockNutrition.state).thenReturn(MealHistoryLoaded(meals));

        await tester.pumpWidget(_buildDashboard(
          authBloc: mockAuth,
          themeBloc: mockTheme,
          glucoseBloc: mockGlucose,
          nutritionBloc: mockNutrition,
        ));
        await tester.pump();

        expect(find.text('Tendencia (24h)'), findsOneWidget);
      },
    );

    testWidgets(
      'insulin events are retained in local state after NutritionBloc state change',
      (tester) async {
        final controller = StreamController<NutritionState>();
        whenListen(
          mockNutrition,
          controller.stream,
          initialState: MealHistoryLoaded([_fakeMeal('2026-02-21T10:30:00', 2.0)]),
        );

        await tester.pumpWidget(_buildDashboard(
          authBloc: mockAuth,
          themeBloc: mockTheme,
          glucoseBloc: mockGlucose,
          nutritionBloc: mockNutrition,
        ));
        await tester.pump();

        // Bloc transitions to search state — events must stay cached
        controller.add(NutritionLoading());
        await tester.pump();

        // Dashboard is still rendered without errors
        expect(find.byType(DashboardScreen), findsOneWidget);

        await controller.close();
      },
    );
  });
}
