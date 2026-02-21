import 'package:bloc_test/bloc_test.dart';
import 'package:diabeaty_mobile/data/models/auth_models.dart';
import 'package:diabeaty_mobile/data/models/family_models.dart';
import 'package:diabeaty_mobile/data/repositories/family_repository.dart';
import 'package:diabeaty_mobile/presentation/bloc/auth/auth_bloc.dart';
import 'package:diabeaty_mobile/presentation/bloc/profile/profile_bloc.dart';
import 'package:diabeaty_mobile/presentation/bloc/theme/theme_bloc.dart';
import 'package:diabeaty_mobile/presentation/screens/profile/adult_profile_screen.dart';
import 'package:diabeaty_mobile/presentation/screens/profile/child_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// ── Mocks ──────────────────────────────────────────────────────────────────
class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}
class MockProfileBloc extends MockBloc<ProfileEvent, ProfileState> implements ProfileBloc {}
class MockThemeBloc extends MockBloc<ThemeEvent, ThemeState> implements ThemeBloc {}
class MockFamilyRepository extends Mock implements FamilyRepository {}

class FakeAuthEvent extends Fake implements AuthEvent {}
class FakeProfileEvent extends Fake implements ProfileEvent {}
class FakeThemeEvent extends Fake implements ThemeEvent {}

// ── Test Data ──────────────────────────────────────────────────────────────
const _mainUser = UserPublicResponse(
  id: 'user-1',
  email: 'guardian@test.com',
  fullName: 'Main User Full Name',
  isActive: true,
);

final _guardianProfile = PatientProfile(
  id: 'profile-guardian',
  displayName: 'Papa Guardian',
  themePreference: 'adult',
  role: 'GUARDIAN',
  isProtected: false,
  diabetesType: 'type_1',
  insulinSensitivity: 40.0,
  carbRatio: 10.0,
  targetGlucose: 100.0,
  targetRangeLow: 70,
  targetRangeHigh: 180,
);

final _dependentProfile = PatientProfile(
  id: 'profile-child',
  displayName: 'Niño Dependiente',
  themePreference: 'child',
  role: 'DEPENDENT',
  isProtected: false,
  diabetesType: 'type_1',
  insulinSensitivity: 35.0,
  carbRatio: 8.0,
  targetGlucose: 90.0,
  targetRangeLow: 70,
  targetRangeHigh: 160,
);

// ── Helpers ────────────────────────────────────────────────────────────────
Widget _buildAdultScreen({
  required MockAuthBloc authBloc,
  required MockFamilyRepository familyRepo,
  MockProfileBloc? profileBloc,
}) {
  final pb = profileBloc ?? MockProfileBloc();
  when(() => pb.state).thenReturn(
    const ProfileLoaded(
      user: UserPublicResponse(id: '1', email: 'test@test.com', isActive: true),
    ),
  );
  when(() => pb.stream).thenAnswer((_) => const Stream.empty());

  return MultiBlocProvider(
    providers: [
      BlocProvider<AuthBloc>.value(value: authBloc),
      BlocProvider<ProfileBloc>.value(value: pb),
    ],
    child: RepositoryProvider<FamilyRepository>.value(
      value: familyRepo,
      child: const MaterialApp(
        home: Scaffold(body: AdultProfileScreen()),
      ),
    ),
  );
}

Widget _buildChildScreen({
  required MockAuthBloc authBloc,
  required MockProfileBloc profileBloc,
}) {
  return MultiBlocProvider(
    providers: [
      BlocProvider<AuthBloc>.value(value: authBloc),
      BlocProvider<ProfileBloc>.value(value: profileBloc),
    ],
    child: const MaterialApp(
      home: Scaffold(body: ChildProfileScreen()),
    ),
  );
}

// ── Tests ──────────────────────────────────────────────────────────────────
void main() {
  late MockAuthBloc mockAuthBloc;
  late MockProfileBloc mockProfileBloc;
  late MockFamilyRepository mockFamilyRepo;

  setUpAll(() {
    registerFallbackValue(FakeAuthEvent());
    registerFallbackValue(FakeProfileEvent());
    registerFallbackValue(FakeThemeEvent());
  });

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockProfileBloc = MockProfileBloc();
    mockFamilyRepo = MockFamilyRepository();
  });

  group('AdultProfileScreen - muestra datos del miembro activo', () {
    testWidgets(
        'muestra el displayName del selectedProfile, NO el fullName del usuario principal',
        (tester) async {
      // Arrange – guardian profile activo
      when(() => mockAuthBloc.state).thenReturn(AuthAuthenticated(
        accessToken: 'token',
        user: _mainUser,
        selectedProfile: _guardianProfile,
      ));

      // Act
      await tester.pumpWidget(
          _buildAdultScreen(authBloc: mockAuthBloc, familyRepo: mockFamilyRepo));
      await tester.pump();

      // Assert
      expect(find.text('Papa Guardian'), findsAtLeastNWidgets(1),
          reason: 'Debe mostrar el displayName del perfil activo');
      expect(find.text('Main User Full Name'), findsNothing,
          reason: 'NO debe mostrar el fullName del usuario principal');
    });

    testWidgets(
        'muestra botón "Cambiar Contraseña" cuando el perfil es GUARDIAN',
        (tester) async {
      when(() => mockAuthBloc.state).thenReturn(AuthAuthenticated(
        accessToken: 'token',
        user: _mainUser,
        selectedProfile: _guardianProfile,
      ));

      await tester.pumpWidget(
          _buildAdultScreen(authBloc: mockAuthBloc, familyRepo: mockFamilyRepo));
      await tester.pump();

      expect(find.text('Cambiar Contraseña'), findsOneWidget,
          reason: 'El tutor SÍ puede cambiar la contraseña');
    });

    testWidgets(
        'oculta botón "Cambiar Contraseña" cuando el perfil es DEPENDENT',
        (tester) async {
      // Arrange – perfil dependiente (niño con tema adulto)
      when(() => mockAuthBloc.state).thenReturn(AuthAuthenticated(
        accessToken: 'token',
        user: _mainUser,
        selectedProfile: _dependentProfile,
      ));

      await tester.pumpWidget(
          _buildAdultScreen(authBloc: mockAuthBloc, familyRepo: mockFamilyRepo));
      await tester.pump();

      expect(find.text('Cambiar Contraseña'), findsNothing,
          reason: 'El dependiente NO puede cambiar la contraseña');
    });

    testWidgets('pre-rellena el campo ISF con el valor del selectedProfile',
        (tester) async {
      when(() => mockAuthBloc.state).thenReturn(AuthAuthenticated(
        accessToken: 'token',
        user: _mainUser,
        selectedProfile: _guardianProfile,
      ));

      await tester.pumpWidget(
          _buildAdultScreen(authBloc: mockAuthBloc, familyRepo: mockFamilyRepo));
      await tester.pump();

      // ISF = 40.0 del guardianProfile
      expect(find.text('40.0'), findsAtLeastNWidgets(1),
          reason: 'El ISF debe pre-rellenarse desde el perfil activo');
    });
  });

  group('ChildProfileScreen - muestra nombre del miembro activo', () {
    testWidgets(
        'muestra el displayName del selectedProfile como saludo',
        (tester) async {
      when(() => mockAuthBloc.state).thenReturn(AuthAuthenticated(
        accessToken: 'token',
        user: _mainUser,
        selectedProfile: _dependentProfile,
      ));
      when(() => mockProfileBloc.state).thenReturn(ProfileLoaded(
        user: _mainUser,
      ));

      await tester.pumpWidget(
          _buildChildScreen(authBloc: mockAuthBloc, profileBloc: mockProfileBloc));
      await tester.pump();

      expect(find.textContaining('Niño Dependiente'), findsAtLeastNWidgets(1),
          reason: 'Debe mostrar el nombre del miembro, no el del usuario principal');
      expect(find.textContaining('Main User Full Name'), findsNothing,
          reason: 'NO debe mostrar el fullName del usuario principal');
    });
  });
}
