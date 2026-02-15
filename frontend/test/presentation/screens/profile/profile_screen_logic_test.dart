import 'package:bloc_test/bloc_test.dart';
import 'package:diabeaty_mobile/presentation/bloc/auth/auth_bloc.dart';
import 'package:diabeaty_mobile/presentation/bloc/profile/profile_bloc.dart';
import 'package:diabeaty_mobile/presentation/bloc/theme/theme_bloc.dart';
import 'package:diabeaty_mobile/presentation/screens/profile/profile_screen.dart';
import 'package:diabeaty_mobile/presentation/screens/profile/adult_profile_screen.dart';
import 'package:diabeaty_mobile/presentation/screens/profile/child_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:diabeaty_mobile/data/models/auth_models.dart';
import 'package:diabeaty_mobile/core/constants/app_constants.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}
class MockProfileBloc extends MockBloc<ProfileEvent, ProfileState> implements ProfileBloc {}
class MockThemeBloc extends MockBloc<ThemeEvent, ThemeState> implements ThemeBloc {}

class FakeProfileEvent extends Fake implements ProfileEvent {}
class FakeThemeEvent extends Fake implements ThemeEvent {}
class FakeAuthEvent extends Fake implements AuthEvent {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockProfileBloc mockProfileBloc;
  late MockThemeBloc mockThemeBloc;

  setUpAll(() {
    registerFallbackValue(FakeProfileEvent());
    registerFallbackValue(FakeThemeEvent());
    registerFallbackValue(FakeAuthEvent());
  });

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockProfileBloc = MockProfileBloc();
    mockThemeBloc = MockThemeBloc();

    // Default Stubs
    when(() => mockAuthBloc.state).thenReturn(const AuthAuthenticated(
      accessToken: 'token',
      user: UserPublicResponse(id: '1', email: 'test@test.com', isActive: true),
    ));
    when(() => mockProfileBloc.state).thenReturn(const ProfileLoaded(
      user: UserPublicResponse(id: '1', email: 'test@test.com', isActive: true),
    ));
  });

  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: mockAuthBloc),
        BlocProvider<ProfileBloc>.value(value: mockProfileBloc), // Inject mock logic
        BlocProvider<ThemeBloc>.value(value: mockThemeBloc),
      ],
      child: const MaterialApp(
        home: ProfileView(),
      ),
    );
  }

  testWidgets('renders AdultProfileScreen when ThemeState is ADULT', (tester) async {
    // Arrange
    when(() => mockThemeBloc.state).thenReturn(const ThemeState(uiMode: UiMode.adult));

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(); // For Builder

    // Assert
    // Currently fails because ProfileScreen uses _ProfileModeSelector with internal state defaulting to Child
    expect(find.byType(AdultProfileScreen), findsOneWidget);
    expect(find.byType(ChildProfileScreen), findsNothing);
    expect(find.byType(Switch), findsNothing); // Should not have toggle
  });

  testWidgets('renders ChildProfileScreen when ThemeState is CHILD', (tester) async {
    // Arrange
    when(() => mockThemeBloc.state).thenReturn(const ThemeState(uiMode: UiMode.child));

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    // Assert
    expect(find.byType(ChildProfileScreen), findsOneWidget);
    expect(find.byType(AdultProfileScreen), findsNothing);
    expect(find.byType(Switch), findsNothing);
  });
}
