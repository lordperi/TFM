import 'package:bloc_test/bloc_test.dart';
import 'package:diabeaty_mobile/presentation/bloc/auth/auth_bloc.dart';
import 'package:diabeaty_mobile/presentation/bloc/glucose/glucose_bloc.dart';
import 'package:diabeaty_mobile/presentation/bloc/theme/theme_bloc.dart';
import 'package:diabeaty_mobile/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:diabeaty_mobile/data/models/family_models.dart';
import 'package:diabeaty_mobile/data/models/auth_models.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}
class MockGlucoseBloc extends MockBloc<GlucoseEvent, GlucoseState> implements GlucoseBloc {}
class MockThemeBloc extends MockBloc<ThemeEvent, ThemeState> implements ThemeBloc {}

// Fake classes to satisfy strict typing if needed, mostly for events
class FakeAuthEvent extends Fake implements AuthEvent {}
class FakeGlucoseEvent extends Fake implements GlucoseEvent {}
class FakeThemeEvent extends Fake implements ThemeEvent {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockGlucoseBloc mockGlucoseBloc;
  late MockThemeBloc mockThemeBloc;

  setUpAll(() {
    registerFallbackValue(FakeAuthEvent());
    registerFallbackValue(FakeGlucoseEvent());
    registerFallbackValue(FakeThemeEvent());
    registerFallbackValue(const LoadGlucoseHistory(''));
    registerFallbackValue(const SetUiMode(UiMode.adult));
  });

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockGlucoseBloc = MockGlucoseBloc();
    mockThemeBloc = MockThemeBloc();

    // Default stubs
    when(() => mockThemeBloc.state).thenReturn(const ThemeState());
    when(() => mockGlucoseBloc.state).thenReturn(GlucoseInitial());
  });

  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: mockAuthBloc),
        BlocProvider<GlucoseBloc>.value(value: mockGlucoseBloc),
        BlocProvider<ThemeBloc>.value(value: mockThemeBloc),
      ],
      child: const MaterialApp(
        home: DashboardScreen(),
      ),
    );
  }

  testWidgets('triggers LoadGlucoseHistory on init if authenticated with profile', (tester) async {
    final testProfile = PatientProfile(
      id: 'patient-123',
      displayName: 'Test',
      role: 'PATIENT',
      isProtected: false,
      themePreference: 'ADULT',
    );

    // Arrange: Valid Auth State
    when(() => mockAuthBloc.state).thenReturn(AuthAuthenticated(
      accessToken: 'token',
      selectedProfile: testProfile,
      user: const UserPublicResponse(
        id: 'user-123',
        email: 'test@test.com',
        isActive: true,
      ),
    ));

    // Act
    await tester.pumpWidget(createWidgetUnderTest());

    // Assert: Verify that LoadGlucoseHistory was added to GlucoseBloc
    verify(() => mockGlucoseBloc.add(const LoadGlucoseHistory('patient-123'))).called(1);
  });
}
