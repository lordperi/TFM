import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:diabeaty_mobile/presentation/bloc/auth/auth_bloc.dart';
import 'package:diabeaty_mobile/data/repositories/family_repository.dart';
import 'package:diabeaty_mobile/data/models/family_models.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Mocks
class MockFamilyRepository extends Mock implements FamilyRepository {}
class MockSecureStorage extends Mock implements FlutterSecureStorage {}
// Assume AuthApiClient mock exists or we create it
class MockAuthApiClient extends Mock implements AuthApiClient {}

void main() {
  late FamilyRepository familyRepository;
  late FlutterSecureStorage secureStorage;
  late AuthApiClient authApiClient;

  setUp(() {
    familyRepository = MockFamilyRepository();
    secureStorage = MockSecureStorage();
    authApiClient = MockAuthApiClient();
  });

  group('AuthBloc - Family Logic', () {
    final testProfile = PatientProfile(
      id: '123',
      displayName: 'Test Child',
      themePreference: 'child',
      role: 'DEPENDENT',
      isProtected: false,
      birthDate: '2015-01-01',
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthAuthenticated] with selectedProfile when SelectProfile added',
      build: () => AuthBloc(
        authApiClient: authApiClient, 
        secureStorage: secureStorage,
        familyRepository: familyRepository
      ),
      seed: () => const AuthAuthenticated(accessToken: 'token'),
      act: (bloc) => bloc.add(SelectProfile(testProfile)),
      expect: () => [
        isA<AuthAuthenticated>().having(
          (s) => s.selectedProfile,
          'selectedProfile',
          testProfile,
        ),
      ],
      verify: (_) {
        verify(() => secureStorage.write(
          key: 'selected_patient_id', 
          value: '123'
        )).called(1);
      },
    );
  });
}
